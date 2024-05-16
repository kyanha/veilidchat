part of 'dht_log.dart';

////////////////////////////////////////////////////////////////////////////
// Reader-only implementation

class _DHTLogRead implements DHTRandomRead {
  _DHTLogRead._(_DHTLogSpine spine) : _spine = spine;

  @override
  int get length => _spine.length;

  @override
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false}) async {
    if (pos < 0 || pos >= length) {
      throw IndexError.withLength(pos, length);
    }
    final lookup = await _spine.lookupPosition(pos);
    if (lookup == null) {
      return null;
    }

    return lookup.shortArray.scope((sa) => sa.operate(
        (read) => read.getItem(lookup.pos, forceRefresh: forceRefresh)));
  }

  (int, int) _clampStartLen(int start, int? len) {
    len ??= _spine.length;
    if (start < 0) {
      throw IndexError.withLength(start, _spine.length);
    }
    if (start > _spine.length) {
      throw IndexError.withLength(start, _spine.length);
    }
    if ((len + start) > _spine.length) {
      len = _spine.length - start;
    }
    return (start, len);
  }

  @override
  Future<List<Uint8List>?> getItemRange(int start,
      {int? length, bool forceRefresh = false}) async {
    final out = <Uint8List>[];
    (start, length) = _clampStartLen(start, length);

    final chunks = Iterable<int>.generate(length).slices(maxDHTConcurrency).map(
        (chunk) => chunk
            .map((pos) => getItem(pos + start, forceRefresh: forceRefresh)));

    for (final chunk in chunks) {
      final elems = await chunk.wait;
      if (elems.contains(null)) {
        return null;
      }
      out.addAll(elems.cast<Uint8List>());
    }

    return out;
  }

  @override
  Future<Set<int>> getOfflinePositions() async {
    final positionOffline = <int>{};

    // Iterate positions backward from most recent
    for (var pos = _spine.length - 1; pos >= 0; pos--) {
      final lookup = await _spine.lookupPosition(pos);
      if (lookup == null) {
        throw StateError('Unable to look up position');
      }

      // Check each segment for offline positions
      var foundOffline = false;
      await lookup.shortArray.scope((sa) => sa.operate((read) async {
            final segmentOffline = await read.getOfflinePositions();

            // For each shortarray segment go through their segment positions
            // in reverse order and see if they are offline
            for (var segmentPos = lookup.pos;
                segmentPos >= 0 && pos >= 0;
                segmentPos--, pos--) {
              // If the position in the segment is offline, then
              // mark the position in the log as offline
              if (segmentOffline.contains(segmentPos)) {
                positionOffline.add(pos);
                foundOffline = true;
              }
            }
          }));

      // If we found nothing offline in this segment then we can stop
      if (!foundOffline) {
        break;
      }
    }

    return positionOffline;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Fields
  final _DHTLogSpine _spine;
}
