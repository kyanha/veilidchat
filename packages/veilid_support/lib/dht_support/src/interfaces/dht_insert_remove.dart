import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Insert/Remove interface
abstract class DHTInsertRemove {
  /// Try to insert an item as position 'pos' of the DHT container.
  /// Return true if the element was successfully inserted, and false if the
  /// state changed before the element could be inserted or a newer value was
  /// found on the network.
  /// Throws an IndexError if the position removed exceeds the length of
  /// the container.
  /// Throws a StateError if the container exceeds its maximum size.
  Future<bool> tryInsertItem(int pos, Uint8List value);

  /// Try to insert items at position 'pos' of the DHT container.
  /// Return true if the elements were successfully inserted, and false if the
  /// state changed before the elements could be inserted or a newer value was
  /// found on the network.
  /// Throws an IndexError if the position removed exceeds the length of
  /// the container.
  /// Throws a StateError if the container exceeds its maximum size.
  Future<bool> tryInsertItems(int pos, List<Uint8List> values);

  /// Swap items at position 'aPos' and 'bPos' in the DHTArray.
  /// Throws an IndexError if either of the positions swapped exceeds the length
  /// of the container
  Future<void> swapItem(int aPos, int bPos);

  /// Remove an item at position 'pos' in the DHT container.
  /// If the remove was successful this returns:
  ///   * outValue will return the prior contents of the element
  /// Throws an IndexError if the position removed exceeds the length of
  /// the container.
  Future<void> removeItem(int pos, {Output<Uint8List>? output});
}

extension DHTInsertRemoveExt on DHTInsertRemove {
  /// Convenience function:
  /// Like removeItem but also parses the returned element as JSON
  Future<void> removeItemJson<T>(T Function(dynamic) fromJson, int pos,
      {Output<T>? output}) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    await removeItem(pos, output: outValueBytes);
    output.mapSave(outValueBytes, (b) => jsonDecodeBytes(fromJson, b));
  }

  /// Convenience function:
  /// Like removeItem but also parses the returned element as JSON
  Future<void> removeItemProtobuf<T extends GeneratedMessage>(
      T Function(List<int>) fromBuffer, int pos,
      {Output<T>? output}) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    await removeItem(pos, output: outValueBytes);
    output.mapSave(outValueBytes, fromBuffer);
  }
}
