part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Writer implementation

class _DHTShortArrayWrite extends _DHTShortArrayRead
    implements DHTRandomReadWrite {
  _DHTShortArrayWrite._(super.head) : super._();

  @override
  Future<bool> tryAddItem(Uint8List value) =>
      tryInsertItem(_head.length, value);

  @override
  Future<bool> tryAddItems(List<Uint8List> values) =>
      tryInsertItems(_head.length, values);

  @override
  Future<bool> tryInsertItem(int pos, Uint8List value) async {
    // Allocate empty index at position
    _head.allocateIndex(pos);

    // Write item
    final ok = await tryWriteItem(pos, value);
    if (!ok) {
      _head.freeIndex(pos);
    }
    return true;
  }

  @override
  Future<bool> tryInsertItems(int pos, List<Uint8List> values) async {
    // Allocate empty indices at the end of the list
    for (var i = 0; i < values.length; i++) {
      _head.allocateIndex(pos + i);
    }

    // Write items
    var success = true;
    final dws = DelayedWaitSet<void>();
    for (var i = 0; i < values.length; i++) {
      dws.add(() async {
        final ok = await tryWriteItem(pos + i, values[i]);
        if (!ok) {
          _head.freeIndex(pos + i);
          success = false;
        }
      });
    }
    await dws(chunkSize: maxDHTConcurrency, onChunkDone: (_) => success);
    return success;
  }

  @override
  Future<void> swapItem(int aPos, int bPos) async {
    if (aPos < 0 || aPos >= _head.length) {
      throw IndexError.withLength(aPos, _head.length);
    }
    if (bPos < 0 || bPos >= _head.length) {
      throw IndexError.withLength(bPos, _head.length);
    }
    // Swap indices
    _head.swapIndex(aPos, bPos);
  }

  @override
  Future<void> removeItem(int pos, {Output<Uint8List>? output}) async {
    if (pos < 0 || pos >= _head.length) {
      throw IndexError.withLength(pos, _head.length);
    }
    final lookup = await _head.lookupPosition(pos);

    final outSeqNum = Output<int>();

    final result = lookup.seq == 0xFFFFFFFF
        ? null
        : await lookup.record.get(subkey: lookup.recordSubkey);

    if (outSeqNum.value != null) {
      _head.updatePositionSeq(pos, false, outSeqNum.value!);
    }

    if (result == null) {
      throw StateError('Element does not exist');
    }
    _head.freeIndex(pos);
    output?.save(result);
  }

  @override
  Future<void> clear() async {
    _head.clearIndex();
  }

  @override
  Future<bool> tryWriteItem(int pos, Uint8List newValue,
      {Output<Uint8List>? output}) async {
    if (pos < 0 || pos >= _head.length) {
      throw IndexError.withLength(pos, _head.length);
    }
    final lookup = await _head.lookupPosition(pos);

    final outSeqNum = Output<int>();

    final oldValue = lookup.seq == 0xFFFFFFFF
        ? null
        : await lookup.record
            .get(subkey: lookup.recordSubkey, outSeqNum: outSeqNum);

    if (outSeqNum.value != null) {
      _head.updatePositionSeq(pos, false, outSeqNum.value!);
    }

    final result = await lookup.record.tryWriteBytes(newValue,
        subkey: lookup.recordSubkey, outSeqNum: outSeqNum);

    if (outSeqNum.value != null) {
      _head.updatePositionSeq(pos, true, outSeqNum.value!);
    }

    if (result != null) {
      // A result coming back means the element was overwritten already
      output?.save(result);
      return false;
    }
    output?.save(oldValue);
    return true;
  }
}
