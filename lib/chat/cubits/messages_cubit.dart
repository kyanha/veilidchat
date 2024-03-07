import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

class _MessageQueueEntry {
  _MessageQueueEntry({required this.remoteMessages});
  IList<proto.Message> remoteMessages;
}

typedef MessagesState = AsyncValue<IList<proto.Message>>;

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit(
      {required ActiveAccountInfo activeAccountInfo,
      required TypedKey remoteIdentityPublicKey,
      required TypedKey localConversationRecordKey,
      required TypedKey localMessagesRecordKey,
      required TypedKey remoteConversationRecordKey,
      required TypedKey remoteMessagesRecordKey})
      : _activeAccountInfo = activeAccountInfo,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _remoteMessagesQueue = StreamController(),
        super(const AsyncValue.loading()) {
    // Local messages key
    Future.delayed(
        Duration.zero,
        () async => _initLocalMessages(
            localConversationRecordKey, localMessagesRecordKey));

    // Remote messages key
    Future.delayed(
        Duration.zero,
        () async => _initRemoteMessages(
            remoteConversationRecordKey, remoteMessagesRecordKey));

    // Remote messages listener
    Future.delayed(Duration.zero, () async {
      await for (final entry in _remoteMessagesQueue.stream) {
        await _updateRemoteMessagesStateAsync(entry);
      }
    });
  }

  @override
  Future<void> close() async {
    await _remoteMessagesQueue.close();
    await _localSubscription?.cancel();
    await _remoteSubscription?.cancel();
    await _localMessagesCubit?.close();
    await _remoteMessagesCubit?.close();
    await super.close();
  }

  // Open local messages key
  Future<void> _initLocalMessages(TypedKey localConversationRecordKey,
      TypedKey localMessagesRecordKey) async {
    final crypto = await _getMessagesCrypto();
    final writer = _activeAccountInfo.conversationWriter;

    _localMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openWrite(
            localMessagesRecordKey, writer,
            parent: localConversationRecordKey, crypto: crypto),
        decodeElement: proto.Message.fromBuffer);
    _localSubscription =
        _localMessagesCubit!.stream.listen(_updateLocalMessagesState);
    _updateLocalMessagesState(_localMessagesCubit!.state);
  }

  // Open remote messages key
  Future<void> _initRemoteMessages(TypedKey remoteConversationRecordKey,
      TypedKey remoteMessagesRecordKey) async {
    // Open remote record key if it is specified
    final crypto = await _getMessagesCrypto();

    _remoteMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openRead(remoteMessagesRecordKey,
            parent: remoteConversationRecordKey, crypto: crypto),
        decodeElement: proto.Message.fromBuffer);
    _remoteSubscription =
        _remoteMessagesCubit!.stream.listen(_updateRemoteMessagesState);
    _updateRemoteMessagesState(_remoteMessagesCubit!.state);
  }

  // Called when the local messages list gets a change
  void _updateLocalMessagesState(
      BlocBusyState<AsyncValue<IList<proto.Message>>> avmessages) {
    // When local messages are updated, pass this
    // directly to the messages cubit state
    emit(avmessages.state);
  }

  // Called when the remote messages list gets a change
  void _updateRemoteMessagesState(
      BlocBusyState<AsyncValue<IList<proto.Message>>> avmessages) {
    final remoteMessages = avmessages.state.data?.value;
    if (remoteMessages == null) {
      return;
    }
    // Add remote messages updates to queue to process asynchronously
    _remoteMessagesQueue
        .add(_MessageQueueEntry(remoteMessages: remoteMessages));
  }

  Future<void> _updateRemoteMessagesStateAsync(_MessageQueueEntry entry) async {
    final localMessagesCubit = _localMessagesCubit!;

    // Updated remote messages need to be merged with the local messages state
    await localMessagesCubit.operate((shortArray) async {
      // Ensure remoteMessages is sorted by timestamp
      final remoteMessages = entry.remoteMessages
          .sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // dedup? build local timestamp set?

      // Existing messages will always be sorted by timestamp so merging is easy
      var localMessages = localMessagesCubit.state.state.data!.value;

      var pos = 0;
      for (final newMessage in remoteMessages) {
        var skip = false;
        while (pos < localMessages.length) {
          final m = localMessages[pos];
          pos++;

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
        }
        // Insert at this position
        if (!skip) {
          // Insert into dht backing array
          await shortArray.tryInsertItem(pos, newMessage.writeToBuffer());
          // Insert into local copy as well for this operation
          localMessages = localMessages.insert(pos, newMessage);
        }
      }
    });
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
    await _localMessagesCubit!.operate(
        (shortArray) => shortArray.tryAddItem(message.writeToBuffer()));
  }

  Future<DHTRecordCrypto> _getMessagesCrypto() async {
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
  DHTShortArrayCubit<proto.Message>? _localMessagesCubit;
  DHTShortArrayCubit<proto.Message>? _remoteMessagesCubit;
  final StreamController<_MessageQueueEntry> _remoteMessagesQueue;
  StreamSubscription<BlocBusyState<AsyncValue<IList<proto.Message>>>>?
      _localSubscription;
  StreamSubscription<BlocBusyState<AsyncValue<IList<proto.Message>>>>?
      _remoteSubscription;
  //
  DHTRecordCrypto? _messagesCrypto;
}
