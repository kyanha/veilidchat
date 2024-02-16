import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

@immutable
class DHTRecordWatchChange extends Equatable {
  const DHTRecordWatchChange(
      {required this.local, required this.data, required this.subkeys});

  final bool local;
  final Uint8List data;
  final List<ValueSubkeyRange> subkeys;

  @override
  List<Object?> get props => [local, data, subkeys];
}

/////////////////////////////////////////////////

class DHTRecord {
  DHTRecord(
      {required VeilidRoutingContext routingContext,
      required DHTRecordDescriptor recordDescriptor,
      int defaultSubkey = 0,
      KeyPair? writer,
      DHTRecordCrypto crypto = const DHTRecordCryptoPublic()})
      : _crypto = crypto,
        _routingContext = routingContext,
        _recordDescriptor = recordDescriptor,
        _defaultSubkey = defaultSubkey,
        _writer = writer,
        _open = true,
        _valid = true,
        _subkeySeqCache = {},
        needsWatchStateUpdate = false,
        inWatchStateUpdate = false;

  final VeilidRoutingContext _routingContext;
  final DHTRecordDescriptor _recordDescriptor;
  final int _defaultSubkey;
  final KeyPair? _writer;
  final Map<int, int> _subkeySeqCache;
  final DHTRecordCrypto _crypto;
  bool _open;
  bool _valid;
  @internal
  StreamController<DHTRecordWatchChange>? watchController;
  @internal
  bool needsWatchStateUpdate;
  @internal
  bool inWatchStateUpdate;
  @internal
  WatchState? watchState;

  int subkeyOrDefault(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  VeilidRoutingContext get routingContext => _routingContext;
  TypedKey get key => _recordDescriptor.key;
  PublicKey get owner => _recordDescriptor.owner;
  KeyPair? get ownerKeyPair => _recordDescriptor.ownerKeyPair();
  DHTSchema get schema => _recordDescriptor.schema;
  int get subkeyCount => _recordDescriptor.schema.subkeyCount();
  KeyPair? get writer => _writer;
  DHTRecordCrypto get crypto => _crypto;
  OwnedDHTRecordPointer get ownedDHTRecordPointer =>
      OwnedDHTRecordPointer(recordKey: key, owner: ownerKeyPair!);

  Future<void> close() async {
    if (!_valid) {
      throw StateError('already deleted');
    }
    if (!_open) {
      return;
    }
    await watchController?.close();
    await _routingContext.closeDHTRecord(_recordDescriptor.key);
    DHTRecordPool.instance.recordClosed(_recordDescriptor.key);
    _open = false;
  }

  Future<void> delete() async {
    if (!_valid) {
      throw StateError('already deleted');
    }
    if (_open) {
      await close();
    }
    await DHTRecordPool.instance.deleteDeep(key);
    _valid = false;
  }

  Future<T> scope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      if (_valid) {
        await close();
      }
    }
  }

  Future<T> deleteScope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      final out = await scopeFunction(this);
      if (_valid && _open) {
        await close();
      }
      return out;
    } on Exception catch (_) {
      if (_valid) {
        await delete();
      }
      rethrow;
    }
  }

  Future<T> maybeDeleteScope<T>(
      bool delete, Future<T> Function(DHTRecord) scopeFunction) async {
    if (delete) {
      return deleteScope(scopeFunction);
    } else {
      return scope(scopeFunction);
    }
  }

  Future<Uint8List?> get(
      {int subkey = -1,
      bool forceRefresh = false,
      bool onlyUpdates = false}) async {
    subkey = subkeyOrDefault(subkey);
    final valueData = await _routingContext.getDHTValue(
        _recordDescriptor.key, subkey, forceRefresh);
    if (valueData == null) {
      return null;
    }
    final lastSeq = _subkeySeqCache[subkey];
    if (onlyUpdates && lastSeq != null && valueData.seq <= lastSeq) {
      return null;
    }
    final out = _crypto.decrypt(valueData.data, subkey);
    _subkeySeqCache[subkey] = valueData.seq;
    return out;
  }

  Future<T?> getJson<T>(T Function(dynamic) fromJson,
      {int subkey = -1,
      bool forceRefresh = false,
      bool onlyUpdates = false}) async {
    final data = await get(
        subkey: subkey, forceRefresh: forceRefresh, onlyUpdates: onlyUpdates);
    if (data == null) {
      return null;
    }
    return jsonDecodeBytes(fromJson, data);
  }

  Future<T?> getProtobuf<T extends GeneratedMessage>(
      T Function(List<int> i) fromBuffer,
      {int subkey = -1,
      bool forceRefresh = false,
      bool onlyUpdates = false}) async {
    final data = await get(
        subkey: subkey, forceRefresh: forceRefresh, onlyUpdates: onlyUpdates);
    if (data == null) {
      return null;
    }
    return fromBuffer(data.toList());
  }

  Future<Uint8List?> tryWriteBytes(Uint8List newValue,
      {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    final lastSeq = _subkeySeqCache[subkey];
    final encryptedNewValue = await _crypto.encrypt(newValue, subkey);

    // Set the new data if possible
    var newValueData = await _routingContext.setDHTValue(
        _recordDescriptor.key, subkey, encryptedNewValue);
    if (newValueData == null) {
      // A newer value wasn't found on the set, but
      // we may get a newer value when getting the value for the sequence number
      newValueData = await _routingContext.getDHTValue(
          _recordDescriptor.key, subkey, false);
      if (newValueData == null) {
        assert(newValueData != null, "can't get value that was just set");
        return null;
      }
    }

    // Record new sequence number
    final isUpdated = newValueData.seq != lastSeq;
    _subkeySeqCache[subkey] = newValueData.seq;

    // See if the encrypted data returned is exactly the same
    // if so, shortcut and don't bother decrypting it
    if (newValueData.data.equals(encryptedNewValue)) {
      if (isUpdated) {
        addLocalValueChange(newValue, subkey);
      }
      return null;
    }

    // Decrypt value to return it
    final decryptedNewValue = await _crypto.decrypt(newValueData.data, subkey);
    if (isUpdated) {
      addLocalValueChange(decryptedNewValue, subkey);
    }
    return decryptedNewValue;
  }

  Future<void> eventualWriteBytes(Uint8List newValue, {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    final lastSeq = _subkeySeqCache[subkey];
    final encryptedNewValue = await _crypto.encrypt(newValue, subkey);

    ValueData? newValueData;
    do {
      do {
        // Set the new data
        newValueData = await _routingContext.setDHTValue(
            _recordDescriptor.key, subkey, encryptedNewValue);

        // Repeat if newer data on the network was found
      } while (newValueData != null);

      // Get the data to check its sequence number
      newValueData = await _routingContext.getDHTValue(
          _recordDescriptor.key, subkey, false);
      if (newValueData == null) {
        assert(newValueData != null, "can't get value that was just set");
        return;
      }

      // Record new sequence number
      _subkeySeqCache[subkey] = newValueData.seq;

      // The encrypted data returned should be exactly the same
      // as what we are trying to set,
      // otherwise we still need to keep trying to set the value
    } while (!newValueData.data.equals(encryptedNewValue));

    final isUpdated = newValueData.seq != lastSeq;
    if (isUpdated) {
      addLocalValueChange(newValue, subkey);
    }
  }

  Future<void> eventualUpdateBytes(
      Future<Uint8List> Function(Uint8List? oldValue) update,
      {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);

    // Get the existing data, do not allow force refresh here
    // because if we need a refresh the setDHTValue will fail anyway
    var oldValue =
        await get(subkey: subkey, forceRefresh: false, onlyUpdates: false);

    do {
      // Update the data
      final updatedValue = await update(oldValue);

      // Try to write it back to the network
      oldValue = await tryWriteBytes(updatedValue, subkey: subkey);

      // Repeat update if newer data on the network was found
    } while (oldValue != null);
  }

  Future<T?> tryWriteJson<T>(T Function(dynamic) fromJson, T newValue,
          {int subkey = -1}) =>
      tryWriteBytes(jsonEncodeBytes(newValue), subkey: subkey).then((out) {
        if (out == null) {
          return null;
        }
        return jsonDecodeBytes(fromJson, out);
      });

  Future<T?> tryWriteProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, T newValue,
          {int subkey = -1}) =>
      tryWriteBytes(newValue.writeToBuffer(), subkey: subkey).then((out) {
        if (out == null) {
          return null;
        }
        return fromBuffer(out);
      });

  Future<void> eventualWriteJson<T>(T newValue, {int subkey = -1}) =>
      eventualWriteBytes(jsonEncodeBytes(newValue), subkey: subkey);

  Future<void> eventualWriteProtobuf<T extends GeneratedMessage>(T newValue,
          {int subkey = -1}) =>
      eventualWriteBytes(newValue.writeToBuffer(), subkey: subkey);

  Future<void> eventualUpdateJson<T>(
          T Function(dynamic) fromJson, Future<T> Function(T?) update,
          {int subkey = -1}) =>
      eventualUpdateBytes(jsonUpdate(fromJson, update), subkey: subkey);

  Future<void> eventualUpdateProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, Future<T> Function(T?) update,
          {int subkey = -1}) =>
      eventualUpdateBytes(protobufUpdate(fromBuffer, update), subkey: subkey);

  Future<void> watch(
      {List<ValueSubkeyRange>? subkeys,
      Timestamp? expiration,
      int? count}) async {
    // Set up watch requirements which will get picked up by the next tick
    final oldWatchState = watchState;
    watchState = WatchState(
        subkeys: subkeys?.lock, expiration: expiration, count: count);
    if (oldWatchState != watchState) {
      needsWatchStateUpdate = true;
    }
  }

  Future<StreamSubscription<DHTRecordWatchChange>> listen(
      Future<void> Function(
              DHTRecord record, Uint8List data, List<ValueSubkeyRange> subkeys)
          onUpdate,
      {bool localChanges = true}) async {
    // Set up watch requirements
    watchController ??=
        StreamController<DHTRecordWatchChange>.broadcast(onCancel: () {
      // If there are no more listeners then we can get rid of the controller
      watchController = null;
    });

    return watchController!.stream.listen(
        (change) {
          if (change.local && !localChanges) {
            return;
          }
          Future.delayed(Duration.zero, () async {
            final Uint8List data;
            if (change.local) {
              // local changes are not encrypted
              data = change.data;
            } else {
              // incoming/remote changes are encrypted
              data =
                  await _crypto.decrypt(change.data, change.subkeys.first.low);
            }
            await onUpdate(this, data, change.subkeys);
          });
        },
        cancelOnError: true,
        onError: (e) async {
          await watchController!.close();
          watchController = null;
        });
  }

  Future<void> cancelWatch() async {
    // Tear down watch requirements
    if (watchState != null) {
      watchState = null;
      needsWatchStateUpdate = true;
    }
  }

  void addLocalValueChange(Uint8List data, int subkey) {
    watchController?.add(DHTRecordWatchChange(
        local: true, data: data, subkeys: [ValueSubkeyRange.single(subkey)]));
  }

  void addRemoteValueChange(VeilidUpdateValueChange update) {
    watchController?.add(DHTRecordWatchChange(
        local: false, data: update.valueData.data, subkeys: update.subkeys));
  }
}
