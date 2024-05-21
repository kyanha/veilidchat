import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Reader interface
abstract class DHTRandomRead {
  /// Returns the number of elements in the DHTArray
  /// This number will be >= 0 and <= DHTShortArray.maxElements (256)
  int get length;

  /// Return the item at position 'pos' in the DHTArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  /// * 'pos' must be >= 0 and < 'length'
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false});

  /// Return a list of a range of items in the DHTArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  /// * 'start' must be >= 0
  /// * 'len' must be >= 0 and <= DHTShortArray.maxElements (256) and defaults
  ///    to the maximum length
  Future<List<Uint8List>?> getItemRange(int start,
      {int? length, bool forceRefresh = false});

  /// Get a list of the positions that were written offline and not flushed yet
  Future<Set<int>> getOfflinePositions();
}

extension DHTRandomReadExt on DHTRandomRead {
  /// Convenience function:
  /// Like getItem but also parses the returned element as JSON
  Future<T?> getItemJson<T>(T Function(dynamic) fromJson, int pos,
          {bool forceRefresh = false}) =>
      getItem(pos, forceRefresh: forceRefresh)
          .then((out) => jsonDecodeOptBytes(fromJson, out));

  /// Convenience function:
  /// Like getAllItems but also parses the returned elements as JSON
  Future<List<T>?> getItemRangeJson<T>(T Function(dynamic) fromJson, int start,
          {int? length, bool forceRefresh = false}) =>
      getItemRange(start, length: length, forceRefresh: forceRefresh)
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
  Future<List<T>?> getItemRangeProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int start,
          {int? length, bool forceRefresh = false}) =>
      getItemRange(start, length: length, forceRefresh: forceRefresh)
          .then((out) => out?.map(fromBuffer).toList());
}
