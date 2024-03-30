import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:mutex/mutex.dart';
import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';
import '../../proto/proto.dart' as proto;

part 'dht_short_array_head.dart';
part 'dht_short_array_read.dart';
part 'dht_short_array_write.dart';

///////////////////////////////////////////////////////////////////////

class DHTShortArray {
  ////////////////////////////////////////////////////////////////
  // Constructors

  DHTShortArray._({required DHTRecord headRecord})
      : _head = _DHTShortArrayHead(headRecord: headRecord) {
    _head.onUpdatedHead = () {
      _watchController?.sink.add(null);
    };
  }

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
      dhtRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: smplWriter);
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
      await dhtShortArray._head.operate((head) async {
        if (!await head._writeHead()) {
          throw StateError('Failed to write head at this time');
        }
      });
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      await pool.delete(dhtRecord.key);
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
      await dhtShortArray._head.operate((head) => head._loadHead());
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
      await dhtShortArray._head.operate((head) => head._loadHead());
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

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  /// Get the record key for this shortarray
  TypedKey get recordKey => _head.recordKey;

  /// Get the record pointer foir this shortarray
  OwnedDHTRecordPointer get recordPointer => _head.recordPointer;

  /// Free all resources for the DHTShortArray
  Future<void> close() async {
    await _watchController?.close();
    await _head.close();
  }

  /// Free all resources for the DHTShortArray and delete it from the DHT
  Future<void> delete() async {
    await close();
    await DHTRecordPool.instance.delete(recordKey);
  }

  /// Runs a closure that guarantees the DHTShortArray
  /// will be closed upon exit, even if an uncaught exception is thrown
  Future<T> scope<T>(Future<T> Function(DHTShortArray) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      await close();
    }
  }

  /// Runs a closure that guarantees the DHTShortArray
  /// will be closed upon exit, and deleted if an an
  /// uncaught exception is thrown
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

  /// Runs a closure allowing read-only access to the shortarray
  Future<T> operate<T>(Future<T> Function(DHTShortArrayRead) closure) async =>
      _head.operate((head) async {
        final reader = _DHTShortArrayRead._(head);
        return closure(reader);
      });

  /// Runs a closure allowing read-write access to the shortarray
  /// Returns (result, true) of the closure if the write could be performed
  /// Returns (null, false) if the write could not be performed at this time
  Future<(T?, bool)> operateWrite<T>(
          Future<T> Function(DHTShortArrayWrite) closure) async =>
      _head.operateWrite((head) async {
        final writer = _DHTShortArrayWrite._(head);
        return closure(writer);
      });

  /// Set an item at position 'pos' of the DHTShortArray. Retries until the
  /// value being written is successfully made the newest value of the element.
  /// This may throw an exception if the position elements the built-in limit of
  /// 'maxElements = 256' entries.
  Future<void> eventualWriteItem(int pos, Uint8List newValue,
      {Duration? timeout}) async {
    await _head.operateWriteEventual((head) async {
      bool wasSet;
      (_, wasSet) = await _tryWriteItemInner(head, pos, newValue);
      return wasSet;
    }, timeout: timeout);
  }

  /// Change an item at position 'pos' of the DHTShortArray.
  /// Runs with the value of the old element at that position such that it can
  /// be changed to the returned value from tha closure. Retries until the
  /// value being written is successfully made the newest value of the element.
  /// This may throw an exception if the position elements the built-in limit of
  /// 'maxElements = 256' entries.

  Future<void> eventualUpdateItem(
      int pos, Future<Uint8List> Function(Uint8List? oldValue) update,
      {Duration? timeout}) async {
    await _head.operateWriteEventual((head) async {
      final oldData = await getItem(pos);

      // Update the data
      final updatedData = await update(oldData);

      // Set it back
      bool wasSet;
      (_, wasSet) = await _tryWriteItemInner(head, pos, updatedData);
      return wasSet;
    }, timeout: timeout);
  }

  /// Convenience function:
  /// Like eventualWriteItem but also encodes the input value as JSON and parses
  /// the returned element as JSON
  Future<void> eventualWriteItemJson<T>(int pos, T newValue,
          {Duration? timeout}) =>
      eventualWriteItem(pos, jsonEncodeBytes(newValue), timeout: timeout);

  /// Convenience function:
  /// Like eventualWriteItem but also encodes the input value as a protobuf
  /// object and parses the returned element as a protobuf object
  Future<void> eventualWriteItemProtobuf<T extends GeneratedMessage>(
          int pos, T newValue,
          {int subkey = -1, Duration? timeout}) =>
      eventualWriteItem(pos, newValue.writeToBuffer(), timeout: timeout);

  /// Convenience function:
  /// Like eventualUpdateItem but also encodes the input value as JSON
  Future<void> eventualUpdateItemJson<T>(
          T Function(dynamic) fromJson, int pos, Future<T> Function(T?) update,
          {Duration? timeout}) =>
      eventualUpdateItem(pos, jsonUpdate(fromJson, update), timeout: timeout);

  /// Convenience function:
  /// Like eventualUpdateItem but also encodes the input value as a protobuf
  /// object
  Future<void> eventualUpdateItemProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer,
          int pos,
          Future<T> Function(T?) update,
          {Duration? timeout}) =>
      eventualUpdateItem(pos, protobufUpdate(fromBuffer, update),
          timeout: timeout);

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
              // Cancel watches of head record
              await _head.cancelWatch();
              _watchController = null;
            }));
          });

          // Start watching head record
          await _head.watch();
        }
        // Return subscription
        return _watchController!.stream.listen((_) => onChanged());
      });

  ////////////////////////////////////////////////////////////////
  // Fields

  static const maxElements = 256;

  // Internal representation refreshed from head record
  final _DHTShortArrayHead _head;

  // Watch mutex to ensure we keep the representation valid
  final Mutex _listenMutex = Mutex();
  // Stream of external changes
  StreamController<void>? _watchController;
}
