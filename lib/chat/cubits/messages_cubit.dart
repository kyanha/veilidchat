import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

class _MessageQueueEntry {
  _MessageQueueEntry(
      {required this.localMessages, required this.remoteMessages});
  IList<proto.Message> localMessages;
  IList<proto.Message> remoteMessages;
}

class MessagesCubit extends Cubit<AsyncValue<IList<proto.Message>>> {
  MessagesCubit(
      {required ActiveAccountInfo activeAccountInfo,
      required TypedKey remoteIdentityPublicKey,
      required TypedKey localConversationRecordKey,
      required TypedKey localMessagesRecordKey,
      required TypedKey remoteConversationRecordKey,
      required TypedKey remoteMessagesRecordKey})
      : _activeAccountInfo = activeAccountInfo,
        _localMessagesRecordKey = localMessagesRecordKey,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _remoteMessagesRecordKey = remoteMessagesRecordKey,
        _remoteMessagesQueue = StreamController(),
        super(const AsyncValue.loading()) {
    // Local messages key
    Future.delayed(Duration.zero, () async {
      final crypto = await getMessagesCrypto();
      final writer = _activeAccountInfo.conversationWriter;
      final record = await DHTShortArray.openWrite(
          _localMessagesRecordKey, writer,
          parent: localConversationRecordKey, crypto: crypto);
      await _setLocalMessages(record);
    });

    // Remote messages key
    Future.delayed(Duration.zero, () async {
      // Open remote record key if it is specified
      final crypto = await getMessagesCrypto();
      final record = await DHTShortArray.openRead(_remoteMessagesRecordKey,
          parent: remoteConversationRecordKey, crypto: crypto);
      await _setRemoteMessages(record);
    });

    // Remote messages listener
    Future.delayed(Duration.zero, () async {
      await for (final entry in _remoteMessagesQueue.stream) {
        await _updateRemoteMessagesStateAsync(entry);
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
  }

  void updateLocalMessagesState(AsyncValue<IList<proto.Message>> avmessages) {
    // Updated local messages from online just update the state immediately
    emit(avmessages);
  }

  Future<void> _updateRemoteMessagesStateAsync(_MessageQueueEntry entry) async {
    // Updated remote messages need to be merged with the local messages state

    // Ensure remoteMessages is sorted by timestamp
    final remoteMessages =
        entry.remoteMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Existing messages will always be sorted by timestamp so merging is easy
    var localMessages = entry.localMessages;
    var pos = 0;
    for (final newMessage in remoteMessages) {
      var skip = false;
      while (pos < localMessages.length) {
        final m = localMessages[pos];

        // If timestamp to insert is less than
        // the current position, insert it here
        final newTs = Timestamp.fromInt64(newMessage.timestamp);
        final curTs = Timestamp.fromInt64(m.timestamp);
        final cmp = newTs.compareTo(curTs);
        if (cmp < 0) {
          break;
        } else if (cmp == 0) {
          skip = true;
          break;
        }
        pos++;
      }
      // Insert at this position
      if (!skip) {
        // Insert into dht backing array
        await _localMessagesCubit!.shortArray
            .tryInsertItem(pos, newMessage.writeToBuffer());
        // Insert into local copy as well for this operation
        localMessages = localMessages.insert(pos, newMessage);
      }
    }
  }

  void updateRemoteMessagesState(AsyncValue<IList<proto.Message>> avmessages) {
    final remoteMessages = avmessages.data?.value;
    if (remoteMessages == null) {
      return;
    }

    final localMessages = state.data?.value;
    if (localMessages == null) {
      // No local messages means remote messages
      // are all we have so merging is easy
      emit(AsyncValue.data(remoteMessages));
      return;
    }

    _remoteMessagesQueue.add(_MessageQueueEntry(
        localMessages: localMessages, remoteMessages: remoteMessages));
  }

  // Open local messages key
  Future<void> _setLocalMessages(DHTShortArray localMessagesRecord) async {
    assert(_localMessagesCubit == null, 'shoud not set local messages twice');
    _localMessagesCubit = DHTShortArrayCubit.value(
        shortArray: localMessagesRecord,
        decodeElement: proto.Message.fromBuffer);
    _localMessagesCubit!.stream.listen(updateLocalMessagesState);
  }

  // Open remote messages key
  Future<void> _setRemoteMessages(DHTShortArray remoteMessagesRecord) async {
    assert(_remoteMessagesCubit == null, 'shoud not set remote messages twice');
    _remoteMessagesCubit = DHTShortArrayCubit.value(
        shortArray: remoteMessagesRecord,
        decodeElement: proto.Message.fromBuffer);
    _remoteMessagesCubit!.stream.listen(updateRemoteMessagesState);
  }

  // Initialize local messages
  static Future<T> initLocalMessages<T>({
    required ActiveAccountInfo activeAccountInfo,
    required TypedKey remoteIdentityPublicKey,
    required TypedKey localConversationKey,
    required FutureOr<T> Function(DHTShortArray) callback,
  }) async {
    final crypto =
        await _makeMessagesCrypto(activeAccountInfo, remoteIdentityPublicKey);
    final writer = activeAccountInfo.conversationWriter;

    return (await DHTShortArray.create(
            parent: localConversationKey, crypto: crypto, smplWriter: writer))
        .deleteScope((messages) async => await callback(messages));
  }

  // Force refresh of messages
  Future<void> refresh() async {
    final lcc = _localMessagesCubit;
    final rcc = _remoteMessagesCubit;

    if (lcc != null) {
      await lcc.refresh();
    }
    if (rcc != null) {
      await rcc.refresh();
    }
  }

  Future<void> addMessage({required proto.Message message}) async {
    await _localMessagesCubit!.shortArray.tryAddItem(message.writeToBuffer());
  }

  Future<DHTRecordCrypto> getMessagesCrypto() async {
    var messagesCrypto = _messagesCrypto;
    if (messagesCrypto != null) {
      return messagesCrypto;
    }
    messagesCrypto =
        await _makeMessagesCrypto(_activeAccountInfo, _remoteIdentityPublicKey);
    _messagesCrypto = messagesCrypto;
    return messagesCrypto;
  }

  static Future<DHTRecordCrypto> _makeMessagesCrypto(
      ActiveAccountInfo activeAccountInfo,
      TypedKey remoteIdentityPublicKey) async {
    final identitySecret = activeAccountInfo.userLogin.identitySecret;
    final cs = await Veilid.instance.getCryptoSystem(identitySecret.kind);
    final sharedSecret =
        await cs.cachedDH(remoteIdentityPublicKey.value, identitySecret.value);

    final messagesCrypto = await DHTRecordCryptoPrivate.fromSecret(
        identitySecret.kind, sharedSecret);
    return messagesCrypto;
  }

  final ActiveAccountInfo _activeAccountInfo;
  final TypedKey _remoteIdentityPublicKey;
  final TypedKey _localMessagesRecordKey;
  final TypedKey _remoteMessagesRecordKey;
  DHTShortArrayCubit<proto.Message>? _localMessagesCubit;
  DHTShortArrayCubit<proto.Message>? _remoteMessagesCubit;
  final StreamController<_MessageQueueEntry> _remoteMessagesQueue;
  //
  DHTRecordCrypto? _messagesCrypto;
}
