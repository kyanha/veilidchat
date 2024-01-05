import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mutex/mutex.dart';

import '../../../../veilid_support.dart';

part 'dht_record_pool.freezed.dart';
part 'dht_record_pool.g.dart';

/// Record pool that managed DHTRecords and allows for tagged deletion
@freezed
class DHTRecordPoolAllocations with _$DHTRecordPoolAllocations {
  const factory DHTRecordPoolAllocations({
    required IMap<String, ISet<TypedKey>>
        childrenByParent, // String key due to IMap<> json unsupported in key
    required IMap<String, TypedKey>
        parentByChild, // String key due to IMap<> json unsupported in key
    required ISet<TypedKey> rootRecords,
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
class _WatchState {
  _WatchState(
      {required this.subkeys, required this.expiration, required this.count});
  List<ValueSubkeyRange>? subkeys;
  Timestamp? expiration;
  int? count;
  Timestamp? realExpiration;
}

/// Opened DHTRecord state
class _OpenedDHTRecord {
  _OpenedDHTRecord(this.routingContext)
      : mutex = Mutex(),
        needsWatchStateUpdate = false,
        inWatchStateUpdate = false;

  Future<void> close() async {
    await watchController?.close();
  }

  Mutex mutex;
  StreamController<VeilidUpdateValueChange>? watchController;
  bool needsWatchStateUpdate;
  bool inWatchStateUpdate;
  _WatchState? watchState;
  VeilidRoutingContext routingContext;
}

class DHTRecordPool with TableDBBacked<DHTRecordPoolAllocations> {
  DHTRecordPool._(Veilid veilid, VeilidRoutingContext routingContext)
      : _state = DHTRecordPoolAllocations(
            childrenByParent: IMap(),
            parentByChild: IMap(),
            rootRecords: ISet()),
        _opened = <TypedKey, _OpenedDHTRecord>{},
        _routingContext = routingContext,
        _veilid = veilid;

  // Persistent DHT record list
  DHTRecordPoolAllocations _state;
  // Which DHT records are currently open
  final Map<TypedKey, _OpenedDHTRecord> _opened;
  // Default routing context to use for new keys
  final VeilidRoutingContext _routingContext;
  // Convenience accessor
  final Veilid _veilid;
  // If tick is already running or not
  bool inTick = false;

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
      : DHTRecordPoolAllocations(
          childrenByParent: IMap(), parentByChild: IMap(), rootRecords: ISet());
  @override
  Object? valueToJson(DHTRecordPoolAllocations val) => val.toJson();

  //////////////////////////////////////////////////////////////

  static DHTRecordPool get instance => _singleton!;

  static Future<void> init() async {
    final routingContext = await Veilid.instance.routingContext();
    final globalPool = DHTRecordPool._(Veilid.instance, routingContext);
    globalPool._state = await globalPool.load();
    _singleton = globalPool;
  }

  Veilid get veilid => _veilid;

  Future<void> _recordOpened(
      TypedKey key, VeilidRoutingContext routingContext) async {
    // no race because dart is single threaded until async breaks
    final odr = _opened[key] ?? _OpenedDHTRecord(routingContext);
    _opened[key] = odr;
    await odr.mutex.acquire();
  }

  Future<StreamSubscription<VeilidUpdateValueChange>> recordWatch(
      TypedKey key, Future<void> Function(VeilidUpdateValueChange) onUpdate,
      {required List<ValueSubkeyRange>? subkeys,
      required Timestamp? expiration,
      required int? count}) async {
    final odr = _opened[key];
    if (odr == null) {
      throw StateError("can't watch unopened record");
    }

    // Set up watch requirements
    odr
      ..watchState =
          _WatchState(subkeys: subkeys, expiration: expiration, count: count)
      ..needsWatchStateUpdate = true
      ..watchController ??=
          StreamController<VeilidUpdateValueChange>.broadcast(onCancel: () {
        // Request watch state change for cancel
        odr
          ..watchState = null
          ..needsWatchStateUpdate = true;
        // If there are no more listeners then we can get rid of the controller
        if (!(odr.watchController?.hasListener ?? true)) {
          odr.watchController = null;
        }
      });

    return odr.watchController!.stream.listen(
        (update) {
          Future.delayed(Duration.zero, () => onUpdate(update));
        },
        cancelOnError: true,
        onError: (e) async {
          await odr.watchController!.close();
          odr.watchController = null;
        });
  }

  Future<void> recordClosed(TypedKey key) async {
    final odr = _opened.remove(key);
    if (odr == null) {
      throw StateError('record already closed');
    }
    await odr.close();
    odr.mutex.release();
  }

  Future<void> deleteDeep(TypedKey parent) async {
    // Collect all dependencies
    final allDeps = <TypedKey>[];
    final currentDeps = [parent];
    while (currentDeps.isNotEmpty) {
      final nextDep = currentDeps.removeLast();

      // Ensure we get the exclusive lock on this record
      // Can use default routing context here because we are only deleting
      await _recordOpened(nextDep, _routingContext);

      // Remove this child from its parent
      await _removeDependency(nextDep);

      allDeps.add(nextDep);
      final childDeps =
          _state.childrenByParent[nextDep.toJson()]?.toList() ?? [];
      currentDeps.addAll(childDeps);
    }

    // Delete all records
    final allFutures = <Future<void>>[];
    for (final dep in allDeps) {
      allFutures.add(_routingContext.deleteDHTRecord(dep));
      await recordClosed(dep);
    }
    await Future.wait(allFutures);
  }

  void _validateParent(TypedKey? parent, TypedKey child) {
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

  Future<void> _addDependency(TypedKey? parent, TypedKey child) async {
    if (parent == null) {
      if (_state.rootRecords.contains(child)) {
        // Dependency already added
        return;
      }
      _state = await store(
          _state.copyWith(rootRecords: _state.rootRecords.add(child)));
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
          parentByChild: _state.parentByChild.add(child.toJson(), parent)));
    }
  }

  Future<void> _removeDependency(TypedKey child) async {
    if (_state.rootRecords.contains(child)) {
      _state = await store(
          _state.copyWith(rootRecords: _state.rootRecords.remove(child)));
    } else {
      final parent = _state.parentByChild[child.toJson()];
      if (parent == null) {
        return;
      }
      final children = _state.childrenByParent[parent.toJson()]!.remove(child);
      late final DHTRecordPoolAllocations newState;
      if (children.isEmpty) {
        newState = _state.copyWith(
            childrenByParent: _state.childrenByParent.remove(parent.toJson()),
            parentByChild: _state.parentByChild.remove(child.toJson()));
      } else {
        newState = _state.copyWith(
            childrenByParent:
                _state.childrenByParent.add(parent.toJson(), children),
            parentByChild: _state.parentByChild.remove(child.toJson()));
      }
      _state = await store(newState);
    }
  }

  ///////////////////////////////////////////////////////////////////////

  /// Create a root DHTRecord that has no dependent records
  Future<DHTRecord> create({
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    DHTSchema schema = const DHTSchema.dflt(oCnt: 1),
    int defaultSubkey = 0,
    DHTRecordCrypto? crypto,
    KeyPair? writer,
  }) async {
    final dhtctx = routingContext ?? _routingContext;
    final recordDescriptor = await dhtctx.createDHTRecord(schema);

    final rec = DHTRecord(
        routingContext: dhtctx,
        recordDescriptor: recordDescriptor,
        defaultSubkey: defaultSubkey,
        writer: writer ?? recordDescriptor.ownerKeyPair(),
        crypto: crypto ??
            await DHTRecordCryptoPrivate.fromTypedKeyPair(
                recordDescriptor.ownerTypedKeyPair()!));

    await _addDependency(parent, rec.key);
    await _recordOpened(rec.key, dhtctx);

    return rec;
  }

  /// Open a DHTRecord readonly
  Future<DHTRecord> openRead(TypedKey recordKey,
      {VeilidRoutingContext? routingContext,
      TypedKey? parent,
      int defaultSubkey = 0,
      DHTRecordCrypto? crypto}) async {
    final dhtctx = routingContext ?? _routingContext;

    await _recordOpened(recordKey, dhtctx);

    late final DHTRecord rec;
    try {
      // If we are opening a key that already exists
      // make sure we are using the same parent if one was specified
      _validateParent(parent, recordKey);

      // Open from the veilid api
      final recordDescriptor = await dhtctx.openDHTRecord(recordKey, null);
      rec = DHTRecord(
          routingContext: dhtctx,
          recordDescriptor: recordDescriptor,
          defaultSubkey: defaultSubkey,
          crypto: crypto ?? const DHTRecordCryptoPublic());

      // Register the dependency
      await _addDependency(parent, rec.key);
    } on Exception catch (_) {
      await recordClosed(recordKey);
      rethrow;
    }

    return rec;
  }

  /// Open a DHTRecord writable
  Future<DHTRecord> openWrite(
    TypedKey recordKey,
    KeyPair writer, {
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    int defaultSubkey = 0,
    DHTRecordCrypto? crypto,
  }) async {
    final dhtctx = routingContext ?? _routingContext;

    await _recordOpened(recordKey, dhtctx);

    late final DHTRecord rec;
    try {
      // If we are opening a key that already exists
      // make sure we are using the same parent if one was specified
      _validateParent(parent, recordKey);

      // Open from the veilid api
      final recordDescriptor = await dhtctx.openDHTRecord(recordKey, writer);
      rec = DHTRecord(
          routingContext: dhtctx,
          recordDescriptor: recordDescriptor,
          defaultSubkey: defaultSubkey,
          writer: writer,
          crypto: crypto ??
              await DHTRecordCryptoPrivate.fromTypedKeyPair(
                  TypedKeyPair.fromKeyPair(recordKey.kind, writer)));

      // Register the dependency if specified
      await _addDependency(parent, rec.key);
    } on Exception catch (_) {
      await recordClosed(recordKey);
      rethrow;
    }

    return rec;
  }

  /// Open a DHTRecord owned
  /// This is the same as writable but uses an OwnedDHTRecordPointer
  /// for convenience and uses symmetric encryption on the key
  /// This is primarily used for backing up private content on to the DHT
  /// to synchronizing it between devices. Because it is 'owned', the correct
  /// parent must be specified.
  Future<DHTRecord> openOwned(
    OwnedDHTRecordPointer ownedDHTRecordPointer, {
    required TypedKey parent,
    VeilidRoutingContext? routingContext,
    int defaultSubkey = 0,
    DHTRecordCrypto? crypto,
  }) =>
      openWrite(
        ownedDHTRecordPointer.recordKey,
        ownedDHTRecordPointer.owner,
        routingContext: routingContext,
        parent: parent,
        defaultSubkey: defaultSubkey,
        crypto: crypto,
      );

  /// Get the parent of a DHTRecord key if it exists
  TypedKey? getParentRecord(TypedKey child) {
    final childJson = child.toJson();
    return _state.parentByChild[childJson];
  }

  /// Handle the DHT record updates coming from Veilid
  void processUpdateValueChange(VeilidUpdateValueChange updateValueChange) {
    if (updateValueChange.subkeys.isNotEmpty) {}
  }

  /// Ticker to check watch state change requests
  Future<void> tick() async {
    if (inTick) {
      return;
    }
    inTick = true;
    try {
      // See if any opened records need watch state changes
      final unord = List<Future<void>>.empty(growable: true);

      for (final kv in _opened.entries) {
        // Check if already updating
        if (kv.value.inWatchStateUpdate) {
          continue;
        }

        if (kv.value.needsWatchStateUpdate) {
          kv.value.inWatchStateUpdate = true;

          final ws = kv.value.watchState;
          if (ws == null) {
            unord.add(() async {
              // Record needs watch cancel
              try {
                final done =
                    await kv.value.routingContext.cancelDHTWatch(kv.key);
                assert(done,
                    'should always be done when cancelling whole subkey range');
                kv.value.needsWatchStateUpdate = false;
              } on VeilidAPIException {
                // Failed to cancel DHT watch, try again next tick
              }
              kv.value.inWatchStateUpdate = false;
            }());
          } else {
            unord.add(() async {
              // Record needs new watch
              try {
                final realExpiration = await kv.value.routingContext
                    .watchDHTValues(kv.key,
                        subkeys: ws.subkeys,
                        count: ws.count,
                        expiration: ws.expiration);
                kv.value.needsWatchStateUpdate = false;
                ws.realExpiration = realExpiration;
              } on VeilidAPIException {
                // Failed to cancel DHT watch, try again next tick
              }
              kv.value.inWatchStateUpdate = false;
            }());
          }
        }
      }

      await unord.wait;
    } finally {
      inTick = false;
    }
  }
}
