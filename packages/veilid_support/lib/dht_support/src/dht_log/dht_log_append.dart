part of 'dht_log.dart';

////////////////////////////////////////////////////////////////////////////
// Append/truncate implementation

class _DHTLogAppend extends _DHTLogRead implements DHTAppendTruncateRandomRead {
  _DHTLogAppend._(super.spine) : super._();

  @override
  Future<bool> tryAppendItem(Uint8List value) async {
    // Allocate empty index at the end of the list
    final endPos = _spine.length;
    _spine.allocateTail(1);
    final lookup = await _spine.lookupPosition(endPos);
    if (lookup == null) {
      throw StateError("can't write to dht log");
    }
    // Write item to the segment
    return lookup.shortArray
        .operateWrite((write) async => write.tryWriteItem(lookup.pos, value));
  }

  @override
  Future<void> truncate(int count) async {
    final len = _spine.length;
    if (count > len) {
      count = len;
    }
    if (count == 0) {
      return;
    }
    if (count < 0) {
      throw StateError('can not remove negative items');
    }
    _spine.releaseHead(count);
  }

  @override
  Future<void> clear() async {
    _spine.releaseHead(_spine.length);
  }
}
