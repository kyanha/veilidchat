import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import '../models/models.dart';
import 'reconciliation/reconciliation.dart';

class RenderStateElement {
  RenderStateElement(
      {required this.message,
      required this.isLocal,
      this.reconciledTimestamp,
      this.sent = false,
      this.sentOffline = false});

  MessageSendState? get sendState {
    if (!isLocal) {
      return null;
    }
    if (reconciledTimestamp != null) {
      return MessageSendState.delivered;
    }
    if (sent) {
      if (!sentOffline) {
        return MessageSendState.sent;
      } else {
        return MessageSendState.sending;
      }
    }
    return null;
  }

  proto.Message message;
  bool isLocal;
  Timestamp? reconciledTimestamp;
  bool sent;
  bool sentOffline;
}

typedef SingleContactMessagesState = AsyncValue<WindowState<MessageState>>;

// Cubit that processes single-contact chats
// Builds the reconciled chat record from the local and remote conversation keys
class SingleContactMessagesCubit extends Cubit<SingleContactMessagesState> {
  SingleContactMessagesCubit({
    required AccountInfo accountInfo,
    required TypedKey remoteIdentityPublicKey,
    required TypedKey localConversationRecordKey,
    required TypedKey localMessagesRecordKey,
    required TypedKey remoteConversationRecordKey,
    required TypedKey remoteMessagesRecordKey,
  })  : _accountInfo = accountInfo,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _localConversationRecordKey = localConversationRecordKey,
        _localMessagesRecordKey = localMessagesRecordKey,
        _remoteConversationRecordKey = remoteConversationRecordKey,
        _remoteMessagesRecordKey = remoteMessagesRecordKey,
        _commandController = StreamController(),
        super(const AsyncValue.loading()) {
    // Async Init
    _initWait.add(_init);
  }

  @override
  Future<void> close() async {
    await _initWait();

    await _commandController.close();
    await _commandRunnerFut;
    await _unsentMessagesQueue.close();
    await _sentSubscription?.cancel();
    await _rcvdSubscription?.cancel();
    await _reconciledSubscription?.cancel();
    await _sentMessagesCubit?.close();
    await _rcvdMessagesCubit?.close();
    await _reconciledMessagesCubit?.close();
    await super.close();
  }

  // Initialize everything
  Future<void> _init() async {
    _unsentMessagesQueue = PersistentQueue<proto.Message>(
      table: 'SingleContactUnsentMessages',
      key: _remoteConversationRecordKey.toString(),
      fromBuffer: proto.Message.fromBuffer,
      closure: _processUnsentMessages,
    );

    // Make crypto
    await _initCrypto();

    // Reconciled messages key
    await _initReconciledMessagesCubit();

    // Local messages key
    await _initSentMessagesCubit();

    // Remote messages key
    await _initRcvdMessagesCubit();

    // Command execution background process
    _commandRunnerFut = Future.delayed(Duration.zero, _commandRunner);
  }

  // Make crypto
  Future<void> _initCrypto() async {
    _conversationCrypto =
        await _accountInfo.makeConversationCrypto(_remoteIdentityPublicKey);
    _senderMessageIntegrity = await MessageIntegrity.create(
        author: _accountInfo.identityTypedPublicKey);
  }

  // Open local messages key
  Future<void> _initSentMessagesCubit() async {
    final writer = _accountInfo.identityWriter;

    _sentMessagesCubit = DHTLogCubit(
        open: () async => DHTLog.openWrite(_localMessagesRecordKey, writer,
            debugName: 'SingleContactMessagesCubit::_initSentMessagesCubit::'
                'SentMessages',
            parent: _localConversationRecordKey,
            crypto: _conversationCrypto),
        decodeElement: proto.Message.fromBuffer);
    _sentSubscription =
        _sentMessagesCubit!.stream.listen(_updateSentMessagesState);
    _updateSentMessagesState(_sentMessagesCubit!.state);
  }

  // Open remote messages key
  Future<void> _initRcvdMessagesCubit() async {
    _rcvdMessagesCubit = DHTLogCubit(
        open: () async => DHTLog.openRead(_remoteMessagesRecordKey,
            debugName: 'SingleContactMessagesCubit::_initRcvdMessagesCubit::'
                'RcvdMessages',
            parent: _remoteConversationRecordKey,
            crypto: _conversationCrypto),
        decodeElement: proto.Message.fromBuffer);
    _rcvdSubscription =
        _rcvdMessagesCubit!.stream.listen(_updateRcvdMessagesState);
    _updateRcvdMessagesState(_rcvdMessagesCubit!.state);
  }

  Future<VeilidCrypto> _makeLocalMessagesCrypto() async =>
      VeilidCryptoPrivate.fromTypedKey(
          _accountInfo.userLogin!.identitySecret, 'tabledb');

  // Open reconciled chat record key
  Future<void> _initReconciledMessagesCubit() async {
    final tableName =
        _reconciledMessagesTableDBName(_localConversationRecordKey);

    final crypto = await _makeLocalMessagesCrypto();

    _reconciledMessagesCubit = TableDBArrayProtobufCubit(
      open: () async => TableDBArrayProtobuf.make(
          table: tableName,
          crypto: crypto,
          fromBuffer: proto.ReconciledMessage.fromBuffer),
    );

    _reconciliation = MessageReconciliation(
        output: _reconciledMessagesCubit!,
        onError: (e, st) {
          emit(AsyncValue.error(e, st));
        });

    _reconciledSubscription =
        _reconciledMessagesCubit!.stream.listen(_updateReconciledMessagesState);
    _updateReconciledMessagesState(_reconciledMessagesCubit!.state);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public interface

  // Set the tail position of the log for pagination.
  // If tail is 0, the end of the log is used.
  // If tail is negative, the position is subtracted from the current log
  // length.
  // If tail is positive, the position is absolute from the head of the log
  // If follow is enabled, the tail offset will update when the log changes
  Future<void> setWindow(
      {int? tail, int? count, bool? follow, bool forceRefresh = false}) async {
    await _initWait();

    // print('setWindow: tail=$tail count=$count, follow=$follow');

    await _reconciledMessagesCubit!.setWindow(
        tail: tail, count: count, follow: follow, forceRefresh: forceRefresh);
  }

  // Set a user-visible 'text' message with possible attachments
  void sendTextMessage({required proto.Message_Text messageText}) {
    final message = proto.Message()..text = messageText;
    _sendMessage(message: message);
  }

  // Run a chat command
  void runCommand(String command) {
    final (cmd, rest) = command.splitOnce(' ');

    if (kDebugMode) {
      if (cmd == '/repeat' && rest != null) {
        final (countStr, text) = rest.splitOnce(' ');
        final count = int.tryParse(countStr);
        if (count != null) {
          runCommandRepeat(count, text ?? '');
        }
      }
    }
  }

  // Run a repeat command
  void runCommandRepeat(int count, String text) {
    _commandController.sink.add(() async {
      for (var i = 0; i < count; i++) {
        final protoMessageText = proto.Message_Text()
          ..text = text.replaceAll(RegExp(r'\$n\b'), i.toString());
        final message = proto.Message()..text = protoMessageText;
        _sendMessage(message: message);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // Internal implementation

  // Called when the sent messages cubit gets a change
  // This will re-render when messages are sent from another machine
  void _updateSentMessagesState(DHTLogBusyState<proto.Message> avmessages) {
    final sentMessages = avmessages.state.asData?.value;
    if (sentMessages == null) {
      return;
    }

    _reconciliation.reconcileMessages(
        _accountInfo.identityTypedPublicKey, sentMessages, _sentMessagesCubit!);

    // Update the view
    _renderState();
  }

  // Called when the received messages cubit gets a change
  void _updateRcvdMessagesState(DHTLogBusyState<proto.Message> avmessages) {
    final rcvdMessages = avmessages.state.asData?.value;
    if (rcvdMessages == null) {
      return;
    }

    _reconciliation.reconcileMessages(
        _remoteIdentityPublicKey, rcvdMessages, _rcvdMessagesCubit!);
  }

  // Called when the reconciled messages window gets a change
  void _updateReconciledMessagesState(
      TableDBArrayProtobufBusyState<proto.ReconciledMessage> avmessages) {
    // Update the view
    _renderState();
  }

  Future<void> _processMessageToSend(
      proto.Message message, proto.Message? previousMessage) async {
    // Get the previous message if we don't have one
    previousMessage ??= await _sentMessagesCubit!.operate((r) async =>
        r.length == 0
            ? null
            : await r.getProtobuf(proto.Message.fromBuffer, r.length - 1));

    message.id =
        await _senderMessageIntegrity.generateMessageId(previousMessage);

    // Now sign it
    await _senderMessageIntegrity.signMessage(
        message, _accountInfo.identitySecretKey);
  }

  // Async process to send messages in the background
  Future<void> _processUnsentMessages(IList<proto.Message> messages) async {
    // Go through and assign ids to all the messages in order
    proto.Message? previousMessage;
    final processedMessages = messages.toList();
    for (final message in processedMessages) {
      await _processMessageToSend(message, previousMessage);
      previousMessage = message;
    }

    await _sentMessagesCubit!.operateAppendEventual((writer) =>
        writer.addAll(messages.map((m) => m.writeToBuffer()).toList()));
  }

  // Produce a state for this cubit from the input cubits and queues
  void _renderState() {
    // Get all reconciled messages
    final reconciledMessages =
        _reconciledMessagesCubit?.state.state.asData?.value;
    // Get all sent messages
    final sentMessages = _sentMessagesCubit?.state.state.asData?.value;
    // Get all items in the unsent queue
    // final unsentMessages = _unsentMessagesQueue.queue;

    // If we aren't ready to render a state, say we're loading
    if (reconciledMessages == null || sentMessages == null) {
      emit(const AsyncLoading());
      return;
    }

    // Generate state for each message
    // final reconciledMessagesMap =
    //     IMap<String, proto.ReconciledMessage>.fromValues(
    //   keyMapper: (x) => x.content.authorUniqueIdString,
    //   values: reconciledMessages.elements,
    // );
    final sentMessagesMap =
        IMap<String, OnlineElementState<proto.Message>>.fromValues(
      keyMapper: (x) => x.value.authorUniqueIdString,
      values: sentMessages.window,
    );
    // final unsentMessagesMap = IMap<String, proto.Message>.fromValues(
    //   keyMapper: (x) => x.authorUniqueIdString,
    //   values: unsentMessages,
    // );

    final renderedElements = <RenderStateElement>[];

    for (final m in reconciledMessages.windowElements) {
      final isLocal =
          m.content.author.toVeilid() == _accountInfo.identityTypedPublicKey;
      final reconciledTimestamp = Timestamp.fromInt64(m.reconciledTime);
      final sm =
          isLocal ? sentMessagesMap[m.content.authorUniqueIdString] : null;
      final sent = isLocal && sm != null;
      final sentOffline = isLocal && sm != null && sm.isOffline;

      renderedElements.add(RenderStateElement(
        message: m.content,
        isLocal: isLocal,
        reconciledTimestamp: reconciledTimestamp,
        sent: sent,
        sentOffline: sentOffline,
      ));
    }

    // Render the state
    final messages = renderedElements
        .map((x) => MessageState(
            content: x.message,
            sentTimestamp: Timestamp.fromInt64(x.message.timestamp),
            reconciledTimestamp: x.reconciledTimestamp,
            sendState: x.sendState))
        .toIList();

    // Emit the rendered state
    emit(AsyncValue.data(WindowState<MessageState>(
        window: messages,
        length: reconciledMessages.length,
        windowTail: reconciledMessages.windowTail,
        windowCount: reconciledMessages.windowCount,
        follow: reconciledMessages.follow)));
  }

  void _sendMessage({required proto.Message message}) {
    // Add common fields
    // id and signature will get set by _processMessageToSend
    message
      ..author = _accountInfo.identityTypedPublicKey.toProto()
      ..timestamp = Veilid.instance.now().toInt64();

    // Put in the queue
    _unsentMessagesQueue.addSync(message);

    // Update the view
    _renderState();
  }

  Future<void> _commandRunner() async {
    await for (final command in _commandController.stream) {
      await command();
    }
  }

  /////////////////////////////////////////////////////////////////////////
  // Static utility functions

  static Future<void> cleanupAndDeleteMessages(
      {required TypedKey localConversationRecordKey}) async {
    final recmsgdbname =
        _reconciledMessagesTableDBName(localConversationRecordKey);
    await Veilid.instance.deleteTableDB(recmsgdbname);
  }

  static String _reconciledMessagesTableDBName(
          TypedKey localConversationRecordKey) =>
      'msg_${localConversationRecordKey.toString().replaceAll(':', '_')}';

  /////////////////////////////////////////////////////////////////////////

  final WaitSet<void> _initWait = WaitSet();
  late final AccountInfo _accountInfo;
  final TypedKey _remoteIdentityPublicKey;
  final TypedKey _localConversationRecordKey;
  final TypedKey _localMessagesRecordKey;
  final TypedKey _remoteConversationRecordKey;
  final TypedKey _remoteMessagesRecordKey;

  late final VeilidCrypto _conversationCrypto;
  late final MessageIntegrity _senderMessageIntegrity;

  DHTLogCubit<proto.Message>? _sentMessagesCubit;
  DHTLogCubit<proto.Message>? _rcvdMessagesCubit;
  TableDBArrayProtobufCubit<proto.ReconciledMessage>? _reconciledMessagesCubit;

  late final MessageReconciliation _reconciliation;

  late final PersistentQueue<proto.Message> _unsentMessagesQueue;

  StreamSubscription<DHTLogBusyState<proto.Message>>? _sentSubscription;
  StreamSubscription<DHTLogBusyState<proto.Message>>? _rcvdSubscription;
  StreamSubscription<TableDBArrayProtobufBusyState<proto.ReconciledMessage>>?
      _reconciledSubscription;
  final StreamController<Future<void> Function()> _commandController;
  late final Future<void> _commandRunnerFut;
}
