part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Reader interface
abstract class DHTShortArrayRead {
  /// Returns the number of elements in the DHTShortArray
  int get length;

  /// Return the item at position 'pos' in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false});

  /// Return a list of all of the items in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  Future<List<Uint8List>?> getAllItems({bool forceRefresh = false});

  /// Get a list of the positions that were written offline and not flushed yet
  Future<Set<int>> getOfflinePositions();
}

extension DHTShortArrayReadExt on DHTShortArrayRead {
  /// Convenience function:
  /// Like getItem but also parses the returned element as JSON
  Future<T?> getItemJson<T>(T Function(dynamic) fromJson, int pos,
          {bool forceRefresh = false}) =>
      getItem(pos, forceRefresh: forceRefresh)
          .then((out) => jsonDecodeOptBytes(fromJson, out));

  /// Convenience function:
  /// Like getAllItems but also parses the returned elements as JSON
  Future<List<T>?> getAllItemsJson<T>(T Function(dynamic) fromJson,
          {bool forceRefresh = false}) =>
      getAllItems(forceRefresh: forceRefresh)
          .then((out) => out?.map(fromJson).toList());

  /// Convenience function:
  /// Like getItem but also parses the returned element as a protobuf object
  Future<T?> getItemProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int pos,
          {bool forceRefresh = false}) =>
      getItem(pos, forceRefresh: forceRefresh)
          .then((out) => (out == null) ? null : fromBuffer(out));

  /// Convenience function:
  /// Like getAllItems but also parses the returned elements as protobuf objects
  Future<List<T>?> getAllItemsProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer,
          {bool forceRefresh = false}) =>
      getAllItems(forceRefresh: forceRefresh)
          .then((out) => out?.map(fromBuffer).toList());
}

////////////////////////////////////////////////////////////////////////////
// Reader-only implementation

class _DHTShortArrayRead implements DHTShortArrayRead {
  _DHTShortArrayRead._(_DHTShortArrayHead head) : _head = head;

  /// Returns the number of elements in the DHTShortArray
  @override
  int get length => _head.length;

  /// Return the item at position 'pos' in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  @override
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false}) async {
    if (pos < 0 || pos >= length) {
      throw IndexError.withLength(pos, length);
    }

    final lookup = await _head.lookupPosition(pos);

    final refresh = forceRefresh || _head.positionNeedsRefresh(pos);
    final out =
        lookup.record.get(subkey: lookup.recordSubkey, forceRefresh: refresh);
    await _head.updatePositionSeq(pos, false);

    return out;
  }

  /// Return a list of all of the items in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  @override
  Future<List<Uint8List>?> getAllItems({bool forceRefresh = false}) async {
    final out = <Uint8List>[];

    for (var pos = 0; pos < _head.length; pos++) {
      final elem = await getItem(pos, forceRefresh: forceRefresh);
      if (elem == null) {
        return null;
      }
      out.add(elem);
    }

    return out;
  }

  /// Get a list of the positions that were written offline and not flushed yet
  @override
  Future<Set<int>> getOfflinePositions() async {
    final indexOffline = <int>{};
    final inspects = await [
      _head._headRecord.inspect(),
      ..._head._linkedRecords.map((lr) => lr.inspect())
    ].wait;

    // Add to offline index
    var strideOffset = 0;
    for (final inspect in inspects) {
      for (final r in inspect.offlineSubkeys) {
        for (var i = r.low; i <= r.high; i++) {
          // If this is the head record, ignore the first head subkey
          if (strideOffset != 0 || i != 0) {
            indexOffline.add(i + ((strideOffset == 0) ? -1 : strideOffset));
          }
        }
      }
      strideOffset += _head._stride;
    }

    // See which positions map to offline indexes
    final positionOffline = <int>{};
    for (var i = 0; i < _head._index.length; i++) {
      final idx = _head._index[i];
      if (indexOffline.contains(idx)) {
        positionOffline.add(i);
      }
    }
    return positionOffline;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Fields
  final _DHTShortArrayHead _head;
}
