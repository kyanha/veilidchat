import 'dart:async';
import 'dart:typed_data';

import 'package:mutex/mutex.dart';
import 'package:protobuf/protobuf.dart';

import '../../../../veilid_support.dart';
import '../proto/proto.dart' as proto;

class _DHTShortArrayCache {
  _DHTShortArrayCache()
      : linkedRecords = List<DHTRecord>.empty(growable: true),
        index = List<int>.empty(growable: true),
        free = List<int>.empty(growable: true);
  _DHTShortArrayCache.from(_DHTShortArrayCache other)
      : linkedRecords = List.of(other.linkedRecords),
        index = List.of(other.index),
        free = List.of(other.free);

  final List<DHTRecord> linkedRecords;
  final List<int> index;
  final List<int> free;

  proto.DHTShortArray toProto() {
    final head = proto.DHTShortArray();
    head.keys.addAll(linkedRecords.map((lr) => lr.key.toProto()));
    head.index = head.index..addAll(index);
    // Do not serialize free list, it gets recreated
    return head;
  }
}

class DHTShortArray {
  DHTShortArray._({required DHTRecord headRecord})
      : _headRecord = headRecord,
        _head = _DHTShortArrayCache(),
        _subscriptions = {},
        _listenMutex = Mutex() {
    late final int stride;
    switch (headRecord.schema) {
      case DHTSchemaDFLT(oCnt: final oCnt):
        if (oCnt <= 1) {
          throw StateError('Invalid DFLT schema in DHTShortArray');
        }
        stride = oCnt - 1;
      case DHTSchemaSMPL(oCnt: final oCnt, members: final members):
        if (oCnt != 0 || members.length != 1 || members[0].mCnt <= 1) {
          throw StateError('Invalid SMPL schema in DHTShortArray');
        }
        stride = members[0].mCnt - 1;
    }
    assert(stride <= maxElements, 'stride too long');
    _stride = stride;
  }

  static const maxElements = 256;

  // Head DHT record
  final DHTRecord _headRecord;
  late final int _stride;

  // Cached representation refreshed from head record
  _DHTShortArrayCache _head;

  // Subscription to head and linked record internal changes
  final Map<TypedKey, StreamSubscription<VeilidUpdateValueChange>>
      _subscriptions;
  // Stream of external changes
  StreamController<void>? _watchController;
  // Watch mutex to ensure we keep the representation valid
  final Mutex _listenMutex;

  // Create a DHTShortArray
  // if smplWriter is specified, uses a SMPL schema with a single writer
  // rather than the key owner
  static Future<DHTShortArray> create(
      {int stride = maxElements,
      VeilidRoutingContext? routingContext,
      TypedKey? parent,
      DHTRecordCrypto? crypto,
      KeyPair? smplWriter}) async {
    assert(stride <= maxElements, 'stride too long');
    final pool = DHTRecordPool.instance;

    late final DHTRecord dhtRecord;
    if (smplWriter != null) {
      final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [DHTSchemaMember(mKey: smplWriter.key, mCnt: stride + 1)]);
      final dhtCreateRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: smplWriter);
      // Reopen with SMPL writer
      await dhtCreateRecord.close();
      dhtRecord = await pool.openWrite(dhtCreateRecord.key, smplWriter,
          parent: parent, routingContext: routingContext, crypto: crypto);
    } else {
      final schema = DHTSchema.dflt(oCnt: stride + 1);
      dhtRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto);
    }

    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      if (!await dhtShortArray._tryWriteHead()) {
        throw StateError('Failed to write head at this time');
      }
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.delete();
      rethrow;
    }
  }

  static Future<DHTShortArray> openRead(TypedKey headRecordKey,
      {VeilidRoutingContext? routingContext,
      TypedKey? parent,
      DHTRecordCrypto? crypto}) async {
    final dhtRecord = await DHTRecordPool.instance.openRead(headRecordKey,
        parent: parent, routingContext: routingContext, crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      await dhtShortArray._refreshHead();
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  static Future<DHTShortArray> openWrite(
    TypedKey headRecordKey,
    KeyPair writer, {
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    DHTRecordCrypto? crypto,
  }) async {
    final dhtRecord = await DHTRecordPool.instance.openWrite(
        headRecordKey, writer,
        parent: parent, routingContext: routingContext, crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      await dhtShortArray._refreshHead();
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  static Future<DHTShortArray> openOwned(
    OwnedDHTRecordPointer ownedDHTRecordPointer, {
    required TypedKey parent,
    VeilidRoutingContext? routingContext,
    DHTRecordCrypto? crypto,
  }) =>
      openWrite(
        ownedDHTRecordPointer.recordKey,
        ownedDHTRecordPointer.owner,
        routingContext: routingContext,
        parent: parent,
        crypto: crypto,
      );

  DHTRecord get record => _headRecord;

  ////////////////////////////////////////////////////////////////

  /// Serialize and write out the current head record, possibly updating it
  /// if a newer copy is available online. Returns true if the write was
  /// successful
  Future<bool> _tryWriteHead() async {
    final head = _head.toProto();
    final headBuffer = head.writeToBuffer();

    final existingData = await _headRecord.tryWriteBytes(headBuffer);
    if (existingData != null) {
      // Head write failed, incorporate update
      await _newHead(proto.DHTShortArray.fromBuffer(existingData));
      return false;
    }

    return true;
  }

  /// Validate the head from the DHT is properly formatted
  /// and calculate the free list from it while we're here
  List<int> _validateHeadCacheData(
      List<Typed<FixedEncodedString43>> linkedKeys, List<int> index) {
    // Ensure nothing is duplicated in the linked keys set
    final newKeys = linkedKeys.toSet();
    assert(newKeys.length <= (maxElements + (_stride - 1)) ~/ _stride,
        'too many keys');
    assert(newKeys.length == linkedKeys.length, 'duplicated linked keys');
    final newIndex = index.toSet();
    assert(newIndex.length <= maxElements, 'too many indexes');
    assert(newIndex.length == index.length, 'duplicated index locations');
    // Ensure all the index keys fit into the existing records
    final indexCapacity = (linkedKeys.length + 1) * _stride;
    int? maxIndex;
    for (final idx in newIndex) {
      assert(idx >= 0 || idx < indexCapacity, 'index out of range');
      if (maxIndex == null || idx > maxIndex) {
        maxIndex = idx;
      }
    }
    final free = <int>[];
    if (maxIndex != null) {
      for (var i = 0; i < maxIndex; i++) {
        if (!newIndex.contains(i)) {
          free.add(i);
        }
      }
    }
    return free;
  }

  /// Open a linked record for reading or writing, same as the head record
  Future<DHTRecord> _openLinkedRecord(TypedKey recordKey) async {
    final writer = _headRecord.writer;
    return (writer != null)
        ? await DHTRecordPool.instance.openWrite(
            recordKey,
            writer,
            parent: _headRecord.key,
            routingContext: _headRecord.routingContext,
          )
        : await DHTRecordPool.instance.openRead(
            recordKey,
            parent: _headRecord.key,
            routingContext: _headRecord.routingContext,
          );
  }

  /// Validate a new head record
  Future<void> _newHead(proto.DHTShortArray head) async {
    // Get the set of new linked keys and validate it
    final linkedKeys = head.keys.map((p) => p.toVeilid()).toList();
    final index = head.index;
    final free = _validateHeadCacheData(linkedKeys, index);

    // See which records are actually new
    final oldRecords = Map<TypedKey, DHTRecord>.fromEntries(
        _head.linkedRecords.map((lr) => MapEntry(lr.key, lr)));
    final newRecords = <TypedKey, DHTRecord>{};
    final sameRecords = <TypedKey, DHTRecord>{};
    try {
      for (var n = 0; n < linkedKeys.length; n++) {
        final newKey = linkedKeys[n];
        final oldRecord = oldRecords[newKey];
        if (oldRecord == null) {
          // Open the new record
          final newRecord = await _openLinkedRecord(newKey);
          newRecords[newKey] = newRecord;
        } else {
          sameRecords[newKey] = oldRecord;
        }
      }
    } on Exception catch (_) {
      // On any exception close the records we have opened
      await Future.wait(newRecords.entries.map((e) => e.value.close()));
      rethrow;
    }

    // From this point forward we should not throw an exception or everything
    // is possibly invalid. Just pass the exception up it happens and the caller
    // will have to delete this short array and reopen it if it can
    await Future.wait(oldRecords.entries
        .where((e) => !sameRecords.containsKey(e.key))
        .map((e) => e.value.close()));

    // Figure out which indices are free

    // Make the new head cache
    _head = _DHTShortArrayCache()
      ..linkedRecords.addAll(
          linkedKeys.map((key) => (sameRecords[key] ?? newRecords[key])!))
      ..index.addAll(index)
      ..free.addAll(free);

    // Update watch if we have one in case linked records have been added
    if (_watchController != null) {
      await _watchAllRecords();
    }
  }

  /// Pull the latest or updated copy of the head record from the network
  Future<bool> _refreshHead(
      {bool forceRefresh = true, bool onlyUpdates = false}) async {
    // Get an updated head record copy if one exists
    final head = await _headRecord.getProtobuf(proto.DHTShortArray.fromBuffer,
        subkey: 0, forceRefresh: forceRefresh, onlyUpdates: onlyUpdates);
    if (head == null) {
      if (onlyUpdates) {
        // No update
        return false;
      }
      throw StateError('head missing during refresh');
    }

    await _newHead(head);

    return true;
  }

  ////////////////////////////////////////////////////////////////

  Future<void> close() async {
    await _watchController?.close();
    final futures = <Future<void>>[_headRecord.close()];
    for (final lr in _head.linkedRecords) {
      futures.add(lr.close());
    }
    await Future.wait(futures);
  }

  Future<void> delete() async {
    await _watchController?.close();

    final futures = <Future<void>>[_headRecord.delete()];
    for (final lr in _head.linkedRecords) {
      futures.add(lr.delete());
    }
    await Future.wait(futures);
  }

  Future<T> scope<T>(Future<T> Function(DHTShortArray) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      await close();
    }
  }

  Future<T> deleteScope<T>(
      Future<T> Function(DHTShortArray) scopeFunction) async {
    try {
      final out = await scopeFunction(this);
      await close();
      return out;
    } on Exception catch (_) {
      await delete();
      rethrow;
    }
  }

  DHTRecord? _getLinkedRecord(int recordNumber) {
    if (recordNumber == 0) {
      return _headRecord;
    }
    recordNumber--;
    if (recordNumber >= _head.linkedRecords.length) {
      return null;
    }
    return _head.linkedRecords[recordNumber];
  }

  Future<DHTRecord> _getOrCreateLinkedRecord(int recordNumber) async {
    if (recordNumber == 0) {
      return _headRecord;
    }
    final pool = DHTRecordPool.instance;
    recordNumber--;
    while (recordNumber >= _head.linkedRecords.length) {
      // Linked records must use SMPL schema so writer can be specified
      // Use the same writer as the head record
      final smplWriter = _headRecord.writer!;
      final parent = pool.getParentRecordKey(_headRecord.key);
      final routingContext = _headRecord.routingContext;
      final crypto = _headRecord.crypto;

      final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [DHTSchemaMember(mKey: smplWriter.key, mCnt: _stride)]);
      final dhtCreateRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: smplWriter);
      // Reopen with SMPL writer
      await dhtCreateRecord.close();
      final dhtRecord = await pool.openWrite(dhtCreateRecord.key, smplWriter,
          parent: parent, routingContext: routingContext, crypto: crypto);

      // Add to linked records
      _head.linkedRecords.add(dhtRecord);
      if (!await _tryWriteHead()) {
        await _refreshHead();
      }
    }
    return _head.linkedRecords[recordNumber];
  }

  int _emptyIndex() {
    if (_head.free.isNotEmpty) {
      return _head.free.removeLast();
    }
    if (_head.index.length == maxElements) {
      throw StateError('too many elements');
    }
    return _head.index.length;
  }

  void _freeIndex(int idx) {
    _head.free.add(idx);
    // xxx: free list optimization here?
  }

  int get length => _head.index.length;

  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false}) async {
    await _refreshHead(forceRefresh: forceRefresh, onlyUpdates: true);

    if (pos < 0 || pos >= _head.index.length) {
      throw IndexError.withLength(pos, _head.index.length);
    }
    final index = _head.index[pos];
    final recordNumber = index ~/ _stride;
    final record = _getLinkedRecord(recordNumber);
    assert(record != null, 'Record does not exist');

    final recordSubkey = (index % _stride) + ((recordNumber == 0) ? 1 : 0);
    return record!.get(subkey: recordSubkey, forceRefresh: forceRefresh);
  }

  Future<T?> getItemJson<T>(T Function(dynamic) fromJson, int pos,
          {bool forceRefresh = false}) =>
      getItem(pos, forceRefresh: forceRefresh)
          .then((out) => jsonDecodeOptBytes(fromJson, out));

  Future<T?> getItemProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int pos,
          {bool forceRefresh = false}) =>
      getItem(pos, forceRefresh: forceRefresh)
          .then((out) => (out == null) ? null : fromBuffer(out));

  Future<bool> tryAddItem(Uint8List value) async {
    await _refreshHead(onlyUpdates: true);

    final oldHead = _DHTShortArrayCache.from(_head);
    late final int pos;
    try {
      // Allocate empty index
      final idx = _emptyIndex();
      // Add new index
      pos = _head.index.length;
      _head.index.add(idx);

      // Write new head
      if (!await _tryWriteHead()) {
        // Failed to write head means head got overwritten
        return false;
      }
    } on Exception catch (_) {
      // Exception on write means state needs to be reverted
      _head = oldHead;
      return false;
    }

    // Head write succeeded, now write item
    await eventualWriteItem(pos, value);
    return true;
  }

  Future<bool> tryInsertItem(int pos, Uint8List value) async {
    await _refreshHead(onlyUpdates: true);

    final oldHead = _DHTShortArrayCache.from(_head);
    try {
      // Allocate empty index
      final idx = _emptyIndex();
      // Add new index
      _head.index.insert(pos, idx);

      // Write new head
      if (!await _tryWriteHead()) {
        // Failed to write head means head got overwritten
        return false;
      }
    } on Exception catch (_) {
      // Exception on write means state needs to be reverted
      _head = oldHead;
      return false;
    }

    // Head write succeeded, now write item
    await eventualWriteItem(pos, value);
    return true;
  }

  Future<bool> trySwapItem(int aPos, int bPos) async {
    if (aPos == bPos) {
      return false;
    }
    await _refreshHead(onlyUpdates: true);

    final oldHead = _DHTShortArrayCache.from(_head);
    try {
      // Add new index
      final aIdx = _head.index[aPos];
      final bIdx = _head.index[bPos];
      _head.index[aPos] = bIdx;
      _head.index[bPos] = aIdx;

      // Write new head
      if (!await _tryWriteHead()) {
        // Failed to write head means head got overwritten
        return false;
      }
    } on Exception catch (_) {
      // Exception on write means state needs to be reverted
      _head = oldHead;
      return false;
    }

    // A change happened, notify any listeners
    _watchController?.sink.add(null);
    return true;
  }

  Future<Uint8List?> tryRemoveItem(int pos) async {
    await _refreshHead(onlyUpdates: true);

    final oldHead = _DHTShortArrayCache.from(_head);
    try {
      final removedIdx = _head.index.removeAt(pos);
      _freeIndex(removedIdx);
      final recordNumber = removedIdx ~/ _stride;
      final record = _getLinkedRecord(recordNumber);
      assert(record != null, 'Record does not exist');
      final recordSubkey =
          (removedIdx % _stride) + ((recordNumber == 0) ? 1 : 0);

      // Write new head
      if (!await _tryWriteHead()) {
        // Failed to write head means head got overwritten
        return null;
      }

      final result = await record!.get(subkey: recordSubkey);
      if (result != null) {
        // A change happened, notify any listeners
        _watchController?.sink.add(null);
      }
      return result;
    } on Exception catch (_) {
      // Exception on write means state needs to be reverted
      _head = oldHead;
      return null;
    }
  }

  Future<T?> tryRemoveItemJson<T>(
    T Function(dynamic) fromJson,
    int pos,
  ) =>
      tryRemoveItem(pos).then((out) => jsonDecodeOptBytes(fromJson, out));

  Future<T?> tryRemoveItemProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int pos) =>
      getItem(pos).then((out) => (out == null) ? null : fromBuffer(out));

  Future<bool> tryClear() async {
    await _refreshHead(onlyUpdates: true);

    final oldHead = _DHTShortArrayCache.from(_head);
    try {
      _head.index.clear();
      _head.free.clear();

      // Write new head
      if (!await _tryWriteHead()) {
        // Failed to write head means head got overwritten
        return false;
      }
    } on Exception catch (_) {
      // Exception on write means state needs to be reverted
      _head = oldHead;
      return false;
    }

    // A change happened, notify any listeners
    _watchController?.sink.add(null);

    return true;
  }

  Future<Uint8List?> tryWriteItem(int pos, Uint8List newValue) async {
    if (await _refreshHead(onlyUpdates: true)) {
      throw StateError('structure changed');
    }
    if (pos < 0 || pos >= _head.index.length) {
      throw IndexError.withLength(pos, _head.index.length);
    }
    final index = _head.index[pos];

    final recordNumber = index ~/ _stride;
    final record = await _getOrCreateLinkedRecord(recordNumber);

    final recordSubkey = (index % _stride) + ((recordNumber == 0) ? 1 : 0);
    final result = await record.tryWriteBytes(newValue, subkey: recordSubkey);

    if (result != null) {
      // A change happened, notify any listeners
      _watchController?.sink.add(null);
    }
    return result;
  }

  Future<void> eventualWriteItem(int pos, Uint8List newValue) async {
    Uint8List? oldData;
    do {
      // Set it back
      oldData = await tryWriteItem(pos, newValue);

      // Repeat if newer data on the network was found
    } while (oldData != null);
  }

  Future<void> eventualUpdateItem(
      int pos, Future<Uint8List> Function(Uint8List oldValue) update) async {
    var oldData = await getItem(pos);
    // Ensure it exists already
    if (oldData == null) {
      throw const FormatException('value does not exist');
    }
    do {
      // Update the data
      final updatedData = await update(oldData!);

      // Set it back
      oldData = await tryWriteItem(pos, updatedData);

      // Repeat if newer data on the network was found
    } while (oldData != null);
  }

  Future<T?> tryWriteItemJson<T>(
    T Function(dynamic) fromJson,
    int pos,
    T newValue,
  ) =>
      tryWriteItem(pos, jsonEncodeBytes(newValue))
          .then((out) => jsonDecodeOptBytes(fromJson, out));

  Future<T?> tryWriteItemProtobuf<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    int pos,
    T newValue,
  ) =>
      tryWriteItem(pos, newValue.writeToBuffer()).then((out) {
        if (out == null) {
          return null;
        }
        return fromBuffer(out);
      });

  Future<void> eventualWriteItemJson<T>(int pos, T newValue) =>
      eventualWriteItem(pos, jsonEncodeBytes(newValue));

  Future<void> eventualWriteItemProtobuf<T extends GeneratedMessage>(
          int pos, T newValue,
          {int subkey = -1}) =>
      eventualWriteItem(pos, newValue.writeToBuffer());

  Future<void> eventualUpdateItemJson<T>(
    T Function(dynamic) fromJson,
    int pos,
    Future<T> Function(T) update,
  ) =>
      eventualUpdateItem(pos, jsonUpdate(fromJson, update));

  Future<void> eventualUpdateItemProtobuf<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    int pos,
    Future<T> Function(T) update,
  ) =>
      eventualUpdateItem(pos, protobufUpdate(fromBuffer, update));

  // Watch head and all linked records
  Future<void> _watchAllRecords() async {
    // This will update any existing watches if necessary
    try {
      await [_headRecord.watch(), ..._head.linkedRecords.map((r) => r.watch())]
          .wait;

      // Update changes to the head record
      if (!_subscriptions.containsKey(_headRecord.key)) {
        _subscriptions[_headRecord.key] =
            await _headRecord.listen(_onUpdateRecord);
      }
      // Update changes to any linked records
      for (final lr in _head.linkedRecords) {
        if (!_subscriptions.containsKey(lr.key)) {
          _subscriptions[lr.key] = await lr.listen(_onUpdateRecord);
        }
      }
    } on Exception {
      // If anything fails, try to cancel the watches
      await _cancelRecordWatches();
      rethrow;
    }
  }

  // Stop watching for changes to head and linked records
  Future<void> _cancelRecordWatches() async {
    await _headRecord.cancelWatch();
    for (final lr in _head.linkedRecords) {
      await lr.cancelWatch();
    }
    await _subscriptions.values.map((s) => s.cancel()).wait;
    _subscriptions.clear();
  }

  // Called when a head or linked record changes
  Future<void> _onUpdateRecord(
      DHTRecord record, Uint8List data, List<ValueSubkeyRange> subkeys) async {
    // If head record subkey zero changes, then the layout
    // of the dhtshortarray has changed
    var updateHead = false;
    if (record == _headRecord && subkeys.containsSubkey(0)) {
      updateHead = true;
    }

    // If we have any other subkeys to update, do them first
    final unord = List<Future<Uint8List?>>.empty(growable: true);
    for (final skr in subkeys) {
      for (var subkey = skr.low; subkey <= skr.high; subkey++) {
        // Skip head subkey
        if (subkey == 0) {
          continue;
        }
        // Get the subkey, which caches the result in the local record store
        unord.add(record.get(subkey: subkey, forceRefresh: true));
      }
    }
    await unord.wait;

    // Then update the head record
    if (updateHead) {
      await _refreshHead(forceRefresh: false);
    }
    // Then commit the change to any listeners
    _watchController?.sink.add(null);
  }

  Future<StreamSubscription<void>> listen(
    void Function() onChanged,
  ) =>
      _listenMutex.protect(() async {
        // If don't have a controller yet, set it up
        if (_watchController == null) {
          // Set up watch requirements
          _watchController = StreamController<void>.broadcast(onCancel: () {
            // If there are no more listeners then we can get
            // rid of the controller and drop our subscriptions
            unawaited(_listenMutex.protect(() async {
              // Cancel watches of head and linked records
              await _cancelRecordWatches();
              _watchController = null;
            }));
          });

          // Start watching head and linked records
          await _watchAllRecords();
        }
        // Return subscription
        return _watchController!.stream.listen((_) => onChanged());
      });
}
