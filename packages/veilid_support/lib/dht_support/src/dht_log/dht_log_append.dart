part of 'dht_log.dart';

////////////////////////////////////////////////////////////////////////////
// Append/truncate implementation

class _DHTLogAppend extends _DHTLogRead implements DHTAppendTruncateRandomRead {
  _DHTLogAppend._(super.spine) : super._();

  @override
  Future<bool> tryAppendItem(Uint8List value) async {
    // Allocate empty index at the end of the list
    final insertPos = _spine.length;
    _spine.allocateTail(1);
    final lookup = await _spine.lookupPosition(insertPos);
    if (lookup == null) {
      throw StateError("can't write to dht log");
    }

    // Write item to the segment
    return lookup.shortArray.scope((sa) => sa.operateWrite((write) async {
          // If this a new segment, then clear it in case we have wrapped around
          if (lookup.pos == 0) {
            await write.clear();
          } else if (lookup.pos != write.length) {
            // We should always be appending at the length
            throw StateError('appending should be at the end');
          }
          return write.tryAddItem(value);
        }));
  }

  @override
  Future<bool> tryAppendItems(List<Uint8List> values) async {
    // Allocate empty index at the end of the list
    final insertPos = _spine.length;
    _spine.allocateTail(values.length);

    // Look up the first position and shortarray
    final dws = DelayedWaitSet<void>();

    var success = true;
    for (var valueIdx = 0; valueIdx < values.length;) {
      final remaining = values.length - valueIdx;

      final lookup = await _spine.lookupPosition(insertPos + valueIdx);
      if (lookup == null) {
        throw StateError("can't write to dht log");
      }

      final sacount = min(remaining, DHTShortArray.maxElements - lookup.pos);
      final sublistValues = values.sublist(valueIdx, valueIdx + sacount);

      dws.add(() async {
        final ok = await lookup.shortArray
            .scope((sa) => sa.operateWrite((write) async {
                  // If this a new segment, then clear it in
                  // case we have wrapped around
                  if (lookup.pos == 0) {
                    await write.clear();
                  } else if (lookup.pos != write.length) {
                    // We should always be appending at the length
                    throw StateError('appending should be at the end');
                  }
                  return write.tryAddItems(sublistValues);
                }));
        if (!ok) {
          success = false;
        }
      });

      valueIdx += sacount;
    }

    await dws(chunkSize: maxDHTConcurrency);

    return success;
  }

  @override
  Future<void> truncate(int count) async {
    count = min(count, _spine.length);
    if (count == 0) {
      return;
    }
    if (count < 0) {
      throw StateError('can not remove negative items');
    }
    await _spine.releaseHead(count);
  }

  @override
  Future<void> clear() async {
    await _spine.releaseHead(_spine.length);
  }
}
