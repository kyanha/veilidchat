import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Append/truncate interface
abstract class DHTAppendTruncate {
  /// Try to add an item to the end of the DHT data structure.
  /// Return true if the element was successfully added, and false if the state
  /// changed before the element could be added or a newer value was found on
  /// the network.
  /// This may throw an exception if the number elements added exceeds limits.
  Future<bool> tryAppendItem(Uint8List value);

  /// Try to add a list of items to the end of the DHT data structure.
  /// Return true if the elements were successfully added, and false if the
  /// state changed before the element could be added or a newer value was found
  /// on the network.
  /// This may throw an exception if the number elements added exceeds limits.
  Future<bool> tryAppendItems(List<Uint8List> values);

  /// Try to remove a number of items from the head of the DHT data structure.
  /// Throws StateError if count < 0
  Future<void> truncate(int count);

  /// Remove all items in the DHT data structure.
  Future<void> clear();
}

abstract class DHTAppendTruncateRandomRead
    implements DHTAppendTruncate, DHTRandomRead {}

extension DHTAppendTruncateExt on DHTAppendTruncate {
  /// Convenience function:
  /// Like tryAppendItem but also encodes the input value as JSON and parses the
  /// returned element as JSON
  Future<bool> tryAppendItemJson<T>(
    T newValue,
  ) =>
      tryAppendItem(jsonEncodeBytes(newValue));

  /// Convenience function:
  /// Like tryAppendItem but also encodes the input value as a protobuf object
  /// and parses the returned element as a protobuf object
  Future<bool> tryAppendItemProtobuf<T extends GeneratedMessage>(
    T newValue,
  ) =>
      tryAppendItem(newValue.writeToBuffer());
}
