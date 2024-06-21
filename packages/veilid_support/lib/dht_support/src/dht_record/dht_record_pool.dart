import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protobuf/protobuf.dart';

import '../../../../veilid_support.dart';

export 'package:fast_immutable_collections/fast_immutable_collections.dart'
    show Output;

part 'dht_record_pool.freezed.dart';
part 'dht_record_pool.g.dart';
part 'dht_record.dart';

const int watchBackoffMultiplier = 2;
const int watchBackoffMax = 30;

const int? defaultWatchDurationSecs = null; // 600
const int watchRenewalNumerator = 4;
const int watchRenewalDenominator = 5;

// Maximum number of concurrent DHT operations to perform on the network
const int maxDHTConcurrency = 8;

// DHT crypto domain
const String cryptoDomainDHT = 'dht';

typedef DHTRecordPoolLogger = void Function(String message);

/// Record pool that managed DHTRecords and allows for tagged deletion
/// String versions of keys due to IMap<> json unsupported in key
@freezed
class DHTRecordPoolAllocations with _$DHTRecordPoolAllocations {
  const factory DHTRecordPoolAllocations({
    @Default(IMapConst<String, ISet<TypedKey>>({}))
    IMap<String, ISet<TypedKey>> childrenByParent,
    @Default(IMapConst<String, TypedKey>({}))
    IMap<String, TypedKey> parentByChild,
    @Default(ISetConst<TypedKey>({})) ISet<TypedKey> rootRecords,
    @Default(IMapConst<String, String>({})) IMap<String, String> debugNames,
  }) = _DHTRecordPoolAllocations;

  factory DHTRecordPoolAllocations.fromJson(dynamic json) =>
      _$DHTRecordPoolAllocationsFromJson(json as Map<String, dynamic>);
}

/// Pointer to an owned record, with key, owner key and owner secret
/// Ensure that these are only serialized encrypted
@freezed
class OwnedDHTRecordPointer with _$OwnedDHTRecordPointer {
  const factory OwnedDHTRecordPointer({
    required TypedKey recordKey,
    required KeyPair owner,
  }) = _OwnedDHTRecordPointer;

  factory OwnedDHTRecordPointer.fromJson(dynamic json) =>
      _$OwnedDHTRecordPointerFromJson(json as Map<String, dynamic>);
}

/// Watch state
@immutable
class WatchState extends Equatable {
  const WatchState(
      {required this.subkeys,
      required this.expiration,
      required this.count,
      this.realExpiration,
      this.renewalTime});
  final List<ValueSubkeyRange>? subkeys;
  final Timestamp? expiration;
  final int? count;
  final Timestamp? realExpiration;
  final Timestamp? renewalTime;

  @override
  List<Object?> get props =>
      [subkeys, expiration, count, realExpiration, renewalTime];
}

/// Data shared amongst all DHTRecord instances
class SharedDHTRecordData {
  SharedDHTRecordData(
      {required this.recordDescriptor,
      required this.defaultWriter,
      required this.defaultRoutingContext});
  DHTRecordDescriptor recordDescriptor;
  KeyPair? defaultWriter;
  VeilidRoutingContext defaultRoutingContext;
  bool needsWatchStateUpdate = false;
  WatchState? unionWatchState;
}

// Per opened record data
class OpenedRecordInfo {
  OpenedRecordInfo(
      {required DHTRecordDescriptor recordDescriptor,
      required KeyPair? defaultWriter,
      required VeilidRoutingContext defaultRoutingContext})
      : shared = SharedDHTRecordData(
            recordDescriptor: recordDescriptor,
            defaultWriter: defaultWriter,
            defaultRoutingContext: defaultRoutingContext);
  SharedDHTRecordData shared;
  Set<DHTRecord> records = {};

  String get debugNames {
    final r = records.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return '[${r.map((x) => x.debugName).join(',')}]';
  }

  String get details {
    final r = records.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return '[${r.map((x) => "writer=${x._writer} "
        "defaultSubkey=${x._defaultSubkey}").join(',')}]';
  }

  String get sharedDetails => shared.toString();
}

class DHTRecordPool with TableDBBackedJson<DHTRecordPoolAllocations> {
  DHTRecordPool._(Veilid veilid, VeilidRoutingContext routingContext)
      : _state = const DHTRecordPoolAllocations(),
        _mutex = Mutex(),
        _opened = <TypedKey, OpenedRecordInfo>{},
        _markedForDelete = <TypedKey>{},
        _routingContext = routingContext,
        _veilid = veilid;

  // Logger
  DHTRecordPoolLogger? _logger;

  // Persistent DHT record list
  DHTRecordPoolAllocations _state;
  // Create/open Mutex
  final Mutex _mutex;
  // Which DHT records are currently open
  final Map<TypedKey, OpenedRecordInfo> _opened;
  // Which DHT records are marked for deletion
  final Set<TypedKey> _markedForDelete;
  // Default routing context to use for new keys
  final VeilidRoutingContext _routingContext;
  // Convenience accessor
  final Veilid _veilid;
  // If tick is already running or not
  bool _inTick = false;
  // Tick counter for backoff
  int _tickCount = 0;
  // Backoff timer
  int _watchBackoffTimer = 1;

  static DHTRecordPool? _singleton;

  //////////////////////////////////////////////////////////////
  /// AsyncTableDBBacked
  @override
  String tableName() => 'dht_record_pool';
  @override
  String tableKeyName() => 'pool_allocations';
  @override
  DHTRecordPoolAllocations valueFromJson(Object? obj) => obj != null
      ? DHTRecordPoolAllocations.fromJson(obj)
      : const DHTRecordPoolAllocations();
  @override
  Object? valueToJson(DHTRecordPoolAllocations? val) => val?.toJson();

  //////////////////////////////////////////////////////////////

  static DHTRecordPool get instance => _singleton!;

  static Future<void> init({DHTRecordPoolLogger? logger}) async {
    final routingContext = await Veilid.instance.routingContext();
    final globalPool = DHTRecordPool._(Veilid.instance, routingContext);
    globalPool
      .._logger = logger
      .._state = await globalPool.load() ?? const DHTRecordPoolAllocations();
    _singleton = globalPool;
  }

  static Future<void> close() async {
    if (_singleton != null) {
      _singleton!._routingContext.close();
      _singleton = null;
    }
  }

  Veilid get veilid => _veilid;

  void log(String message) {
    _logger?.call(message);
  }

  Future<OpenedRecordInfo> _recordCreateInner(
      {required String debugName,
      required VeilidRoutingContext dhtctx,
      required DHTSchema schema,
      KeyPair? writer,
      TypedKey? parent}) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    // Create the record
    final recordDescriptor = await dhtctx.createDHTRecord(schema);

    log('createDHTRecord: debugName=$debugName key=${recordDescriptor.key}');

    // Reopen if a writer is specified to ensure
    // we switch the default writer
    if (writer != null) {
      await dhtctx.openDHTRecord(recordDescriptor.key, writer: writer);
    }
    final openedRecordInfo = OpenedRecordInfo(
        recordDescriptor: recordDescriptor,
        defaultWriter: writer ?? recordDescriptor.ownerKeyPair(),
        defaultRoutingContext: dhtctx);
    _opened[recordDescriptor.key] = openedRecordInfo;

    // Register the dependency
    await _addDependencyInner(
      parent,
      recordDescriptor.key,
      debugName: debugName,
    );

    return openedRecordInfo;
  }

  Future<OpenedRecordInfo> _recordOpenInner(
      {required String debugName,
      required VeilidRoutingContext dhtctx,
      required TypedKey recordKey,
      KeyPair? writer,
      TypedKey? parent}) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    log('openDHTRecord: debugName=$debugName key=$recordKey');

    // If we are opening a key that already exists
    // make sure we are using the same parent if one was specified
    _validateParentInner(parent, recordKey);

    // See if this has been opened yet
    final openedRecordInfo = _opened[recordKey];
    if (openedRecordInfo == null) {
      // Fresh open, just open the record
      final recordDescriptor =
          await dhtctx.openDHTRecord(recordKey, writer: writer);
      final newOpenedRecordInfo = OpenedRecordInfo(
          recordDescriptor: recordDescriptor,
          defaultWriter: writer,
          defaultRoutingContext: dhtctx);
      _opened[recordDescriptor.key] = newOpenedRecordInfo;

      // Register the dependency
      await _addDependencyInner(
        parent,
        recordKey,
        debugName: debugName,
      );

      return newOpenedRecordInfo;
    }

    // Already opened

    // See if we need to reopen the record with a default writer and possibly
    // a different routing context
    if (writer != null && openedRecordInfo.shared.defaultWriter == null) {
      final newRecordDescriptor =
          await dhtctx.openDHTRecord(recordKey, writer: writer);
      openedRecordInfo.shared.defaultWriter = writer;
      openedRecordInfo.shared.defaultRoutingContext = dhtctx;
      if (openedRecordInfo.shared.recordDescriptor.ownerSecret == null) {
        openedRecordInfo.shared.recordDescriptor = newRecordDescriptor;
      }
    }

    // Register the dependency
    await _addDependencyInner(
      parent,
      recordKey,
      debugName: debugName,
    );

    return openedRecordInfo;
  }

  // Called when a DHTRecord is closed
  // Cleans up the opened record housekeeping and processes any late deletions
  Future<void> _recordClosed(DHTRecord record) async {
    await _mutex.protect(() async {
      final key = record.key;

      log('closeDHTRecord: debugName=${record.debugName} key=$key');

      final openedRecordInfo = _opened[key];
      if (openedRecordInfo == null ||
          !openedRecordInfo.records.remove(record)) {
        throw StateError('record already closed');
      }
      if (openedRecordInfo.records.isEmpty) {
        await _routingContext.closeDHTRecord(key);
        _opened.remove(key);

        await _checkForLateDeletesInner(key);
      }
    });
  }

  // Check to see if this key can finally be deleted
  // If any parents are marked for deletion, try them first
  Future<void> _checkForLateDeletesInner(TypedKey key) async {
    // Get parent list in bottom up order including our own key
    final parents = <TypedKey>[];
    TypedKey? nextParent = key;
    while (nextParent != null) {
      parents.add(nextParent);
      nextParent = getParentRecordKey(nextParent);
    }

    // If any parent is ready to delete all its children do it
    for (final parent in parents) {
      if (_markedForDelete.contains(parent)) {
        final deleted = await _deleteRecordInner(parent);
        if (!deleted) {
          // If we couldn't delete a child then no 'marked for delete' parents
          // above us will be ready to delete either
          break;
        }
      }
    }
  }

  // Collect all dependencies (including the record itself)
  // in reverse (bottom-up/delete order)
  List<TypedKey> _collectChildrenInner(TypedKey recordKey) {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    final allDeps = <TypedKey>[];
    final currentDeps = [recordKey];
    while (currentDeps.isNotEmpty) {
      final nextDep = currentDeps.removeLast();

      allDeps.add(nextDep);
      final childDeps =
          _state.childrenByParent[nextDep.toJson()]?.toList() ?? [];
      currentDeps.addAll(childDeps);
    }
    return allDeps.reversedView;
  }

  /// Collect all dependencies (including the record itself)
  /// in reverse (bottom-up/delete order)
  Future<List<TypedKey>> collectChildren(TypedKey recordKey) =>
      _mutex.protect(() async => _collectChildrenInner(recordKey));

  /// Print children
  String debugChildren(TypedKey recordKey, {List<TypedKey>? allDeps}) {
    allDeps ??= _collectChildrenInner(recordKey);
    // ignore: avoid_print
    var out =
        'Parent: $recordKey (${_state.debugNames[recordKey.toString()]})\n';
    for (final dep in allDeps) {
      if (dep != recordKey) {
        // ignore: avoid_print
        out += '  Child: $dep (${_state.debugNames[dep.toString()]})\n';
      }
    }
    return out;
  }

  // Actual delete function
  Future<void> _finalizeDeleteRecordInner(TypedKey recordKey) async {
    log('_finalizeDeleteRecordInner: key=$recordKey');

    // Remove this child from parents
    await _removeDependenciesInner([recordKey]);
    await _routingContext.deleteDHTRecord(recordKey);
    _markedForDelete.remove(recordKey);
  }

  // Deep delete mechanism inside mutex
  Future<bool> _deleteRecordInner(TypedKey recordKey) async {
    final toDelete = _readyForDeleteInner(recordKey);
    if (toDelete.isNotEmpty) {
      // delete now
      for (final deleteKey in toDelete) {
        await _finalizeDeleteRecordInner(deleteKey);
      }
      return true;
    }
    // mark for deletion
    _markedForDelete.add(recordKey);
    return false;
  }

  /// Delete a record and its children if they are all closed
  /// otherwise mark that record for deletion eventually
  /// Returns true if the deletion was processed immediately
  /// Returns false if the deletion was marked for later
  Future<bool> deleteRecord(TypedKey recordKey) async =>
      _mutex.protect(() async => _deleteRecordInner(recordKey));

  // If everything underneath is closed including itself, return the
  // list of children (and itself) to finally actually delete
  List<TypedKey> _readyForDeleteInner(TypedKey recordKey) {
    final allDeps = _collectChildrenInner(recordKey);
    for (final dep in allDeps) {
      if (_opened.containsKey(dep)) {
        return [];
      }
    }
    return allDeps;
  }

  void _validateParentInner(TypedKey? parent, TypedKey child) {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    final childJson = child.toJson();
    final existingParent = _state.parentByChild[childJson];
    if (parent == null) {
      if (existingParent != null) {
        throw StateError('Child is already parented: $child');
      }
    } else {
      if (_state.rootRecords.contains(child)) {
        throw StateError('Child already added as root: $child');
      }
      if (existingParent != null && existingParent != parent) {
        throw StateError('Child has two parents: $child <- $parent');
      }
    }
  }

  Future<void> _addDependencyInner(TypedKey? parent, TypedKey child,
      {required String debugName}) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    if (parent == null) {
      if (_state.rootRecords.contains(child)) {
        // Dependency already added
        return;
      }
      _state = await store(_state.copyWith(
          rootRecords: _state.rootRecords.add(child),
          debugNames: _state.debugNames.add(child.toJson(), debugName)));
    } else {
      final childrenOfParent =
          _state.childrenByParent[parent.toJson()] ?? ISet<TypedKey>();
      if (childrenOfParent.contains(child)) {
        // Dependency already added (consecutive opens, etc)
        return;
      }
      _state = await store(_state.copyWith(
          childrenByParent: _state.childrenByParent
              .add(parent.toJson(), childrenOfParent.add(child)),
          parentByChild: _state.parentByChild.add(child.toJson(), parent),
          debugNames: _state.debugNames.add(child.toJson(), debugName)));
    }
  }

  Future<void> _removeDependenciesInner(List<TypedKey> childList) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    var state = _state;

    for (final child in childList) {
      if (_state.rootRecords.contains(child)) {
        state = state.copyWith(
            rootRecords: state.rootRecords.remove(child),
            debugNames: state.debugNames.remove(child.toJson()));
      } else {
        final parent = state.parentByChild[child.toJson()];
        if (parent == null) {
          continue;
        }
        final children = state.childrenByParent[parent.toJson()]!.remove(child);
        if (children.isEmpty) {
          state = state.copyWith(
              childrenByParent: state.childrenByParent.remove(parent.toJson()),
              parentByChild: state.parentByChild.remove(child.toJson()),
              debugNames: state.debugNames.remove(child.toJson()));
        } else {
          state = state.copyWith(
              childrenByParent:
                  state.childrenByParent.add(parent.toJson(), children),
              parentByChild: state.parentByChild.remove(child.toJson()),
              debugNames: state.debugNames.remove(child.toJson()));
        }
      }
    }

    if (state != _state) {
      _state = await store(state);
    }
  }

  bool _isValidRecordKeyInner(TypedKey key) {
    if (_state.rootRecords.contains(key)) {
      return true;
    }
    if (_state.childrenByParent.containsKey(key.toJson())) {
      return true;
    }
    return false;
  }

  Future<bool> isValidRecordKey(TypedKey key) =>
      _mutex.protect(() async => _isValidRecordKeyInner(key));

  ///////////////////////////////////////////////////////////////////////

  /// Create a root DHTRecord that has no dependent records
  Future<DHTRecord> createRecord({
    required String debugName,
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    DHTSchema schema = const DHTSchema.dflt(oCnt: 1),
    int defaultSubkey = 0,
    VeilidCrypto? crypto,
    KeyPair? writer,
  }) async =>
      _mutex.protect(() async {
        final dhtctx = routingContext ?? _routingContext;

        final openedRecordInfo = await _recordCreateInner(
            debugName: debugName,
            dhtctx: dhtctx,
            schema: schema,
            writer: writer,
            parent: parent);

        final rec = DHTRecord._(
            debugName: debugName,
            routingContext: dhtctx,
            defaultSubkey: defaultSubkey,
            sharedDHTRecordData: openedRecordInfo.shared,
            writer: writer ??
                openedRecordInfo.shared.recordDescriptor.ownerKeyPair(),
            crypto: crypto ??
                await privateCryptoFromTypedSecret(openedRecordInfo
                    .shared.recordDescriptor
                    .ownerTypedSecret()!));

        openedRecordInfo.records.add(rec);

        return rec;
      });

  /// Open a DHTRecord readonly
  Future<DHTRecord> openRecordRead(TypedKey recordKey,
          {required String debugName,
          VeilidRoutingContext? routingContext,
          TypedKey? parent,
          int defaultSubkey = 0,
          VeilidCrypto? crypto}) async =>
      _mutex.protect(() async {
        final dhtctx = routingContext ?? _routingContext;

        final openedRecordInfo = await _recordOpenInner(
            debugName: debugName,
            dhtctx: dhtctx,
            recordKey: recordKey,
            parent: parent);

        final rec = DHTRecord._(
            debugName: debugName,
            routingContext: dhtctx,
            defaultSubkey: defaultSubkey,
            sharedDHTRecordData: openedRecordInfo.shared,
            writer: null,
            crypto: crypto ?? const VeilidCryptoPublic());

        openedRecordInfo.records.add(rec);

        return rec;
      });

  /// Open a DHTRecord writable
  Future<DHTRecord> openRecordWrite(
    TypedKey recordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    int defaultSubkey = 0,
    VeilidCrypto? crypto,
  }) async =>
      _mutex.protect(() async {
        final dhtctx = routingContext ?? _routingContext;

        final openedRecordInfo = await _recordOpenInner(
            debugName: debugName,
            dhtctx: dhtctx,
            recordKey: recordKey,
            parent: parent,
            writer: writer);

        final rec = DHTRecord._(
            debugName: debugName,
            routingContext: dhtctx,
            defaultSubkey: defaultSubkey,
            writer: writer,
            sharedDHTRecordData: openedRecordInfo.shared,
            crypto: crypto ??
                await privateCryptoFromTypedSecret(
                    TypedKey(kind: recordKey.kind, value: writer.secret)));

        openedRecordInfo.records.add(rec);

        return rec;
      });

  /// Open a DHTRecord owned
  /// This is the same as writable but uses an OwnedDHTRecordPointer
  /// for convenience and uses symmetric encryption on the key
  /// This is primarily used for backing up private content on to the DHT
  /// to synchronizing it between devices. Because it is 'owned', the correct
  /// parent must be specified.
  Future<DHTRecord> openRecordOwned(
    OwnedDHTRecordPointer ownedDHTRecordPointer, {
    required String debugName,
    required TypedKey parent,
    VeilidRoutingContext? routingContext,
    int defaultSubkey = 0,
    VeilidCrypto? crypto,
  }) =>
      openRecordWrite(
        ownedDHTRecordPointer.recordKey,
        ownedDHTRecordPointer.owner,
        debugName: debugName,
        routingContext: routingContext,
        parent: parent,
        defaultSubkey: defaultSubkey,
        crypto: crypto,
      );

  /// Get the parent of a DHTRecord key if it exists
  TypedKey? getParentRecordKey(TypedKey child) {
    final childJson = child.toJson();
    return _state.parentByChild[childJson];
  }

  /// Handle the DHT record updates coming from internal to this app
  void processLocalValueChange(TypedKey key, Uint8List data, int subkey) {
    // Change
    for (final kv in _opened.entries) {
      if (kv.key == key) {
        for (final rec in kv.value.records) {
          rec._addLocalValueChange(data, subkey);
        }
        break;
      }
    }
  }

  /// Generate default VeilidCrypto for a writer
  static Future<VeilidCrypto> privateCryptoFromTypedSecret(
          TypedKey typedSecret) async =>
      VeilidCryptoPrivate.fromTypedKey(typedSecret, cryptoDomainDHT);

  /// Handle the DHT record updates coming from Veilid
  void processRemoteValueChange(VeilidUpdateValueChange updateValueChange) {
    if (updateValueChange.subkeys.isNotEmpty && updateValueChange.count != 0) {
      // Change
      for (final kv in _opened.entries) {
        if (kv.key == updateValueChange.key) {
          for (final rec in kv.value.records) {
            rec._addRemoteValueChange(updateValueChange);
          }
          break;
        }
      }
    } else {
      final now = Veilid.instance.now().value;
      // Expired, process renewal if desired
      for (final entry in _opened.entries) {
        final openedKey = entry.key;
        final openedRecordInfo = entry.value;

        if (openedKey == updateValueChange.key) {
          // Renew watch state for each opened record
          for (final rec in openedRecordInfo.records) {
            // See if the watch had an expiration and if it has expired
            // otherwise the renewal will keep the same parameters
            final watchState = rec.watchState;
            if (watchState != null) {
              final exp = watchState.expiration;
              if (exp != null && exp.value < now) {
                // Has expiration, and it has expired, clear watch state
                rec.watchState = null;
              }
            }
          }
          openedRecordInfo.shared.needsWatchStateUpdate = true;
          break;
        }
      }
    }
  }

  WatchState? _collectUnionWatchState(Iterable<DHTRecord> records) {
    // Collect union of opened record watch states
    int? totalCount;
    Timestamp? maxExpiration;
    List<ValueSubkeyRange>? allSubkeys;
    Timestamp? earliestRenewalTime;

    var noExpiration = false;
    var everySubkey = false;
    var cancelWatch = true;

    for (final rec in records) {
      final ws = rec.watchState;
      if (ws != null) {
        cancelWatch = false;
        final wsCount = ws.count;
        if (wsCount != null) {
          totalCount = totalCount ?? 0 + min(wsCount, 0x7FFFFFFF);
          totalCount = min(totalCount, 0x7FFFFFFF);
        }
        final wsExp = ws.expiration;
        if (wsExp != null && !noExpiration) {
          maxExpiration = maxExpiration == null
              ? wsExp
              : wsExp.value > maxExpiration.value
                  ? wsExp
                  : maxExpiration;
        } else {
          noExpiration = true;
        }
        final wsSubkeys = ws.subkeys;
        if (wsSubkeys != null && !everySubkey) {
          allSubkeys = allSubkeys == null
              ? wsSubkeys
              : allSubkeys.unionSubkeys(wsSubkeys);
        } else {
          everySubkey = true;
        }
        final wsRenewalTime = ws.renewalTime;
        if (wsRenewalTime != null) {
          earliestRenewalTime = earliestRenewalTime == null
              ? wsRenewalTime
              : Timestamp(
                  value: (wsRenewalTime.value < earliestRenewalTime.value
                      ? wsRenewalTime.value
                      : earliestRenewalTime.value));
        }
      }
    }
    if (noExpiration) {
      maxExpiration = null;
    }
    if (everySubkey) {
      allSubkeys = null;
    }
    if (cancelWatch) {
      return null;
    }

    return WatchState(
        subkeys: allSubkeys,
        expiration: maxExpiration,
        count: totalCount,
        renewalTime: earliestRenewalTime);
  }

  void _updateWatchRealExpirations(Iterable<DHTRecord> records,
      Timestamp realExpiration, Timestamp renewalTime) {
    for (final rec in records) {
      final ws = rec.watchState;
      if (ws != null) {
        rec.watchState = WatchState(
            subkeys: ws.subkeys,
            expiration: ws.expiration,
            count: ws.count,
            realExpiration: realExpiration,
            renewalTime: renewalTime);
      }
    }
  }

  /// Ticker to check watch state change requests
  Future<void> tick() async {
    if (_tickCount < _watchBackoffTimer) {
      _tickCount++;
      return;
    }
    if (_inTick) {
      return;
    }
    _inTick = true;
    _tickCount = 0;
    final now = veilid.now();

    try {
      final allSuccess = await _mutex.protect(() async {
        // See if any opened records need watch state changes
        final unord = <Future<bool> Function()>[];

        for (final kv in _opened.entries) {
          final openedRecordKey = kv.key;
          final openedRecordInfo = kv.value;
          final dhtctx = openedRecordInfo.shared.defaultRoutingContext;

          var wantsWatchStateUpdate =
              openedRecordInfo.shared.needsWatchStateUpdate;

          // Check if we have reached renewal time for the watch
          if (openedRecordInfo.shared.unionWatchState != null &&
              openedRecordInfo.shared.unionWatchState!.renewalTime != null &&
              now.value >
                  openedRecordInfo.shared.unionWatchState!.renewalTime!.value) {
            wantsWatchStateUpdate = true;
          }

          if (wantsWatchStateUpdate) {
            // Update union watch state
            final unionWatchState = openedRecordInfo.shared.unionWatchState =
                _collectUnionWatchState(openedRecordInfo.records);

            // Apply watch changes for record
            if (unionWatchState == null) {
              unord.add(() async {
                // Record needs watch cancel
                var success = false;
                try {
                  success = await dhtctx.cancelDHTWatch(openedRecordKey);

                  log('cancelDHTWatch: key=$openedRecordKey, success=$success, '
                      'debugNames=${openedRecordInfo.debugNames}');

                  openedRecordInfo.shared.needsWatchStateUpdate = false;
                } on VeilidAPIException catch (e) {
                  // Failed to cancel DHT watch, try again next tick
                  log('Exception in watch cancel: $e');
                }
                return success;
              });
            } else {
              unord.add(() async {
                // Record needs new watch
                var success = false;
                try {
                  final subkeys = unionWatchState.subkeys?.toList();
                  final count = unionWatchState.count;
                  final expiration = unionWatchState.expiration;
                  final now = veilid.now();

                  final realExpiration = await dhtctx.watchDHTValues(
                      openedRecordKey,
                      subkeys: unionWatchState.subkeys?.toList(),
                      count: unionWatchState.count,
                      expiration: unionWatchState.expiration ??
                          (defaultWatchDurationSecs == null
                              ? null
                              : veilid.now().offset(
                                  TimestampDuration.fromMillis(
                                      defaultWatchDurationSecs! * 1000))));

                  final expirationDuration = realExpiration.diff(now);
                  final renewalTime = now.offset(TimestampDuration(
                      value: expirationDuration.value *
                          BigInt.from(watchRenewalNumerator) ~/
                          BigInt.from(watchRenewalDenominator)));

                  log('watchDHTValues: key=$openedRecordKey, subkeys=$subkeys, '
                      'count=$count, expiration=$expiration, '
                      'realExpiration=$realExpiration, '
                      'renewalTime=$renewalTime, '
                      'debugNames=${openedRecordInfo.debugNames}');

                  // Update watch states with real expiration
                  if (realExpiration.value != BigInt.zero) {
                    openedRecordInfo.shared.needsWatchStateUpdate = false;
                    _updateWatchRealExpirations(
                        openedRecordInfo.records, realExpiration, renewalTime);
                    success = true;
                  }
                } on VeilidAPIException catch (e) {
                  // Failed to cancel DHT watch, try again next tick
                  log('Exception in watch update: $e');
                }
                return success;
              });
            }
          }
        }

        // Process all watch changes
        return unord.isEmpty ||
            (await unord.map((f) => f()).wait).reduce((a, b) => a && b);
      });

      // If any watched did not success, back off the attempts to
      // update the watches for a bit

      if (!allSuccess) {
        _watchBackoffTimer *= watchBackoffMultiplier;
        _watchBackoffTimer = min(_watchBackoffTimer, watchBackoffMax);
      } else {
        _watchBackoffTimer = 1;
      }
    } finally {
      _inTick = false;
    }
  }

  void debugPrintAllocations() {
    final sortedAllocations = _state.debugNames.entries.asList()
      ..sort((a, b) => a.key.compareTo(b.key));

    log('DHTRecordPool Allocations: (count=${sortedAllocations.length})');

    for (final entry in sortedAllocations) {
      log('  ${entry.key}: ${entry.value}');
    }
  }

  void debugPrintOpened() {
    final sortedOpened = _opened.entries.asList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

    log('DHTRecordPool Opened Records: (count=${sortedOpened.length})');

    for (final entry in sortedOpened) {
      log('  ${entry.key}: \n'
          '     debugNames=${entry.value.debugNames}\n'
          '     details=${entry.value.details}\n'
          '     sharedDetails=${entry.value.sharedDetails}\n');
    }
  }
}
