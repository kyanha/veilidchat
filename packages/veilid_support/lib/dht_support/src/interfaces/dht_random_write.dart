import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Writer interface
abstract class DHTRandomWrite {
  /// Try to set an item at position 'pos' of the DHTArray.
  /// If the set was successful this returns:
  ///   * A boolean true
  ///   * outValue will return the prior contents of the element,
  ///     or null if there was no value yet
  ///
  /// If the set was found a newer value on the network this returns:
  ///   * A boolean false
  ///   * outValue will return the newer value of the element,
  ///     or null if the head record changed.
  ///
  /// This may throw an exception if the position exceeds the built-in limit of
  /// 'maxElements = 256' entries.
  Future<bool> tryWriteItem(int pos, Uint8List newValue,
      {Output<Uint8List>? output});

  /// Try to add an item to the end of the DHTArray. Return true if the
  /// element was successfully added, and false if the state changed before
  /// the element could be added or a newer value was found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryAddItem(Uint8List value);

  /// Try to add a list of items to the end of the DHTArray. Return true if the
  /// elements were successfully added, and false if the state changed before
  /// the elements could be added or a newer value was found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryAddItems(List<Uint8List> values);

  /// Try to insert an item as position 'pos' of the DHTArray.
  /// Return true if the element was successfully inserted, and false if the
  /// state changed before the element could be inserted or a newer value was
  /// found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryInsertItem(int pos, Uint8List value);

  /// Try to insert items at position 'pos' of the DHTArray.
  /// Return true if the elements were successfully inserted, and false if the
  /// state changed before the elements could be inserted or a newer value was
  /// found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryInsertItems(int pos, List<Uint8List> values);

  /// Swap items at position 'aPos' and 'bPos' in the DHTArray.
  /// Throws IndexError if either of the positions swapped exceed
  /// the length of the list
  Future<void> swapItem(int aPos, int bPos);

  /// Remove an item at position 'pos' in the DHTArray.
  /// If the remove was successful this returns:
  ///   * outValue will return the prior contents of the element
  /// Throws IndexError if the position removed exceeds the length of
  /// the list.
  Future<void> removeItem(int pos, {Output<Uint8List>? output});

  /// Remove all items in the DHTShortArray.
  Future<void> clear();
}

extension DHTRandomWriteExt on DHTRandomWrite {
  /// Convenience function:
  /// Like tryWriteItem but also encodes the input value as JSON and parses the
  /// returned element as JSON
  Future<bool> tryWriteItemJson<T>(
      T Function(dynamic) fromJson, int pos, T newValue,
      {Output<T>? output}) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    final out = await tryWriteItem(pos, jsonEncodeBytes(newValue),
        output: outValueBytes);
    output.mapSave(outValueBytes, (b) => jsonDecodeBytes(fromJson, b));
    return out;
  }

  /// Convenience function:
  /// Like tryWriteItem but also encodes the input value as a protobuf object
  /// and parses the returned element as a protobuf object
  Future<bool> tryWriteItemProtobuf<T extends GeneratedMessage>(
      T Function(List<int>) fromBuffer, int pos, T newValue,
      {Output<T>? output}) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    final out = await tryWriteItem(pos, newValue.writeToBuffer(),
        output: outValueBytes);
    output.mapSave(outValueBytes, fromBuffer);
    return out;
  }

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

abstract class DHTRandomReadWrite implements DHTRandomRead, DHTRandomWrite {}
