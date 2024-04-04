import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

class _SingleContactMessageQueueEntry {
  _SingleContactMessageQueueEntry({this.localMessages, this.remoteMessages});
  IList<proto.Message>? localMessages;
  IList<proto.Message>? remoteMessages;
}

typedef SingleContactMessagesState = AsyncValue<IList<proto.Message>>;

// Cubit that processes single-contact chats
// Builds the reconciled chat record from the local and remote conversation keys
class SingleContactMessagesCubit extends Cubit<SingleContactMessagesState> {
  SingleContactMessagesCubit({
    required ActiveAccountInfo activeAccountInfo,
    required TypedKey remoteIdentityPublicKey,
    required TypedKey localConversationRecordKey,
    required TypedKey localMessagesRecordKey,
    required TypedKey remoteConversationRecordKey,
    required TypedKey remoteMessagesRecordKey,
    required OwnedDHTRecordPointer reconciledChatRecord,
  })  : _activeAccountInfo = activeAccountInfo,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _localConversationRecordKey = localConversationRecordKey,
        _localMessagesRecordKey = localMessagesRecordKey,
        _remoteConversationRecordKey = remoteConversationRecordKey,
        _remoteMessagesRecordKey = remoteMessagesRecordKey,
        _reconciledChatRecord = reconciledChatRecord,
        _messagesUpdateQueue = StreamController(),
        super(const AsyncValue.loading()) {
    // Async Init
    _initWait.add(_init);
  }

  @override
  Future<void> close() async {
    await _initWait();

    await _messagesUpdateQueue.close();
    await _localSubscription?.cancel();
    await _remoteSubscription?.cancel();
    await _reconciledChatSubscription?.cancel();
    await _localMessagesCubit?.close();
    await _remoteMessagesCubit?.close();
    await _reconciledChatMessagesCubit?.close();
    await super.close();
  }

  // Initialize everything
  Future<void> _init() async {
    // Make crypto
    await _initMessagesCrypto();

    // Reconciled messages key
    await _initReconciledChatMessages();

    // Local messages key
    await _initLocalMessages();

    // Remote messages key
    await _initRemoteMessages();

    // Messages listener
    Future.delayed(Duration.zero, () async {
      await for (final entry in _messagesUpdateQueue.stream) {
        await _updateMessagesStateAsync(entry);
      }
    });
  }

  // Make crypto

  Future<void> _initMessagesCrypto() async {
    _messagesCrypto = await _activeAccountInfo
        .makeConversationCrypto(_remoteIdentityPublicKey);
  }

  // Open local messages key
  Future<void> _initLocalMessages() async {
    final writer = _activeAccountInfo.conversationWriter;

    _localMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openWrite(
            _localMessagesRecordKey, writer,
            debugName:
                'SingleContactMessagesCubit::_initLocalMessages::LocalMessages',
            parent: _localConversationRecordKey,
            crypto: _messagesCrypto),
        decodeElement: proto.Message.fromBuffer);
    _localSubscription =
        _localMessagesCubit!.stream.listen(_updateLocalMessagesState);
    _updateLocalMessagesState(_localMessagesCubit!.state);
  }

  // Open remote messages key
  Future<void> _initRemoteMessages() async {
    _remoteMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openRead(_remoteMessagesRecordKey,
            debugName: 'SingleContactMessagesCubit::_initRemoteMessages::'
                'RemoteMessages',
            parent: _remoteConversationRecordKey,
            crypto: _messagesCrypto),
        decodeElement: proto.Message.fromBuffer);
    _remoteSubscription =
        _remoteMessagesCubit!.stream.listen(_updateRemoteMessagesState);
    _updateRemoteMessagesState(_remoteMessagesCubit!.state);
  }

  // Open reconciled chat record key
  Future<void> _initReconciledChatMessages() async {
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    _reconciledChatMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openOwned(_reconciledChatRecord,
            debugName:
                'SingleContactMessagesCubit::_initReconciledChatMessages::'
                'ReconciledChat',
            parent: accountRecordKey),
        decodeElement: proto.Message.fromBuffer);
    _reconciledChatSubscription =
        _reconciledChatMessagesCubit!.stream.listen(_updateReconciledChatState);
    _updateReconciledChatState(_reconciledChatMessagesCubit!.state);
  }

  // Called when the local messages list gets a change
  void _updateLocalMessagesState(
      BlocBusyState<AsyncValue<IList<proto.Message>>> avmessages) {
    final localMessages = avmessages.state.data?.value;
    if (localMessages == null) {
      return;
    }
    // Add local messages updates to queue to process asynchronously
    _messagesUpdateQueue
        .add(_SingleContactMessageQueueEntry(localMessages: localMessages));
  }

  // Called when the remote messages list gets a change
  void _updateRemoteMessagesState(
      BlocBusyState<AsyncValue<IList<proto.Message>>> avmessages) {
    final remoteMessages = avmessages.state.data?.value;
    if (remoteMessages == null) {
      return;
    }
    // Add remote messages updates to queue to process asynchronously
    _messagesUpdateQueue
        .add(_SingleContactMessageQueueEntry(remoteMessages: remoteMessages));
  }

  // Called when the reconciled messages list gets a change
  void _updateReconciledChatState(
      BlocBusyState<AsyncValue<IList<proto.Message>>> avmessages) {
    // When reconciled messages are updated, pass this
    // directly to the messages cubit state
    emit(avmessages.state);
  }

  Future<void> _mergeMessagesInner(
      {required DHTShortArrayWrite reconciledMessagesWriter,
      required IList<proto.Message> messages}) async {
    // Ensure remoteMessages is sorted by timestamp
    final newMessages = messages
        .sort((a, b) => a.timestamp.compareTo(b.timestamp))
        .removeDuplicates();

    // Existing messages will always be sorted by timestamp so merging is easy
    final existingMessages = await reconciledMessagesWriter
        .getAllItemsProtobuf(proto.Message.fromBuffer);
    if (existingMessages == null) {
      throw Exception(
          'Could not load existing reconciled messages at this time');
    }

    var ePos = 0;
    var nPos = 0;
    while (ePos < existingMessages.length && nPos < newMessages.length) {
      final existingMessage = existingMessages[ePos];
      final newMessage = newMessages[nPos];

      // If timestamp to insert is less than
      // the current position, insert it here
      final newTs = Timestamp.fromInt64(newMessage.timestamp);
      final existingTs = Timestamp.fromInt64(existingMessage.timestamp);
      final cmp = newTs.compareTo(existingTs);
      if (cmp < 0) {
        // New message belongs here

        // Insert into dht backing array
        await reconciledMessagesWriter.tryInsertItem(
            ePos, newMessage.writeToBuffer());
        // Insert into local copy as well for this operation
        existingMessages.insert(ePos, newMessage);

        // Next message
        nPos++;
        ePos++;
      } else if (cmp == 0) {
        // Duplicate, skip
        nPos++;
        ePos++;
      } else if (cmp > 0) {
        // New message belongs later
        ePos++;
      }
    }
    // If there are any new messages left, append them all
    while (nPos < newMessages.length) {
      final newMessage = newMessages[nPos];

      // Append to dht backing array
      await reconciledMessagesWriter.tryAddItem(newMessage.writeToBuffer());
      // Insert into local copy as well for this operation
      existingMessages.add(newMessage);

      nPos++;
    }
  }

  Future<void> _updateMessagesStateAsync(
      _SingleContactMessageQueueEntry entry) async {
    final reconciledChatMessagesCubit = _reconciledChatMessagesCubit!;

    // Merge remote and local messages into the reconciled chat log
    await reconciledChatMessagesCubit
        .operateWrite((reconciledMessagesWriter) async {
      // xxx for now, keep two lists, but can probable simplify this out soon
      if (entry.localMessages != null) {
        await _mergeMessagesInner(
            reconciledMessagesWriter: reconciledMessagesWriter,
            messages: entry.localMessages!);
      }
      if (entry.remoteMessages != null) {
        await _mergeMessagesInner(
            reconciledMessagesWriter: reconciledMessagesWriter,
            messages: entry.remoteMessages!);
      }
    });
  }

  // Force refresh of messages
  Future<void> refresh() async {
    await _initWait();

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
    await _initWait();

    await _localMessagesCubit!
        .operateWrite((writer) => writer.tryAddItem(message.writeToBuffer()));
  }

  final WaitSet _initWait = WaitSet();
  final ActiveAccountInfo _activeAccountInfo;
  final TypedKey _remoteIdentityPublicKey;
  final TypedKey _localConversationRecordKey;
  final TypedKey _localMessagesRecordKey;
  final TypedKey _remoteConversationRecordKey;
  final TypedKey _remoteMessagesRecordKey;
  final OwnedDHTRecordPointer _reconciledChatRecord;

  late final DHTRecordCrypto _messagesCrypto;

  DHTShortArrayCubit<proto.Message>? _localMessagesCubit;
  DHTShortArrayCubit<proto.Message>? _remoteMessagesCubit;
  DHTShortArrayCubit<proto.Message>? _reconciledChatMessagesCubit;

  final StreamController<_SingleContactMessageQueueEntry> _messagesUpdateQueue;

  StreamSubscription<BlocBusyState<AsyncValue<IList<proto.Message>>>>?
      _localSubscription;
  StreamSubscription<BlocBusyState<AsyncValue<IList<proto.Message>>>>?
      _remoteSubscription;
  StreamSubscription<BlocBusyState<AsyncValue<IList<proto.Message>>>>?
      _reconciledChatSubscription;
}
