import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../models/models.dart';
import 'message_reconciliation.dart';

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

    if (sent && !sentOffline) {
      return MessageSendState.delivered;
    }
    if (reconciledTimestamp != null) {
      return MessageSendState.sent;
    }
    return MessageSendState.sending;
  }

  proto.Message message;
  bool isLocal;
  Timestamp? reconciledTimestamp;
  bool sent;
  bool sentOffline;
}

typedef SingleContactMessagesState = AsyncValue<IList<MessageState>>;

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
  })  : _activeAccountInfo = activeAccountInfo,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _localConversationRecordKey = localConversationRecordKey,
        _localMessagesRecordKey = localMessagesRecordKey,
        _remoteConversationRecordKey = remoteConversationRecordKey,
        _remoteMessagesRecordKey = remoteMessagesRecordKey,
        super(const AsyncValue.loading()) {
    // Async Init
    _initWait.add(_init);
  }

  @override
  Future<void> close() async {
    await _initWait();

    await _sendingMessagesQueue.close();
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
    _sendingMessagesQueue = PersistentQueue<proto.Message>(
      table: 'SingleContactSendingMessages',
      key: _remoteConversationRecordKey.toString(),
      fromBuffer: proto.Message.fromBuffer,
      closure: _processSendingMessages,
    );

    // Make crypto
    await _initCrypto();

    // Reconciled messages key
    await _initReconciledMessagesCubit();

    // Local messages key
    await _initSentMessagesCubit();

    // Remote messages key
    await _initRcvdMessagesCubit();
  }

  // Make crypto
  Future<void> _initCrypto() async {
    _messagesCrypto = await _activeAccountInfo
        .makeConversationCrypto(_remoteIdentityPublicKey);
    _localMessagesCryptoSystem =
        await Veilid.instance.getCryptoSystem(_localMessagesRecordKey.kind);
    _identityCryptoSystem =
        await _activeAccountInfo.localAccount.identityMaster.identityCrypto;
  }

  // Open local messages key
  Future<void> _initSentMessagesCubit() async {
    final writer = _activeAccountInfo.conversationWriter;

    _sentMessagesCubit = DHTLogCubit(
        open: () async => DHTLog.openWrite(_localMessagesRecordKey, writer,
            debugName: 'SingleContactMessagesCubit::_initSentMessagesCubit::'
                'SentMessages',
            parent: _localConversationRecordKey,
            crypto: _messagesCrypto),
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
            crypto: _messagesCrypto),
        decodeElement: proto.Message.fromBuffer);
    _rcvdSubscription =
        _rcvdMessagesCubit!.stream.listen(_updateRcvdMessagesState);
    _updateRcvdMessagesState(_rcvdMessagesCubit!.state);
  }

  Future<VeilidCrypto> _makeLocalMessagesCrypto() async =>
      VeilidCryptoPrivate.fromTypedKey(
          _activeAccountInfo.userLogin.identitySecret, 'tabledb');

  // Open reconciled chat record key
  Future<void> _initReconciledMessagesCubit() async {
    final tableName = _localConversationRecordKey.toString();

    final crypto = await _makeLocalMessagesCrypto();

    _reconciledMessagesCubit = TableDBArrayCubit(
        open: () async => TableDBArray.make(table: tableName, crypto: crypto),
        decodeElement: proto.ReconciledMessage.fromBuffer);

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
    await _reconciledMessagesCubit!.setWindow(
        tail: tail, count: count, follow: follow, forceRefresh: forceRefresh);
  }

  // Set a user-visible 'text' message with possible attachments
  void sendTextMessage({required proto.Message_Text messageText}) {
    final message = proto.Message()..text = messageText;
    _sendMessage(message: message);
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
        _activeAccountInfo.localAccount.identityMaster.identityPublicTypedKey(),
        sentMessages,
        _sentMessagesCubit!);
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
      TableDBArrayBusyState<proto.ReconciledMessage> avmessages) {
    // Update the view
    _renderState();
  }

  Future<Uint8List> _hashSignature(proto.Signature signature) async =>
      (await _localMessagesCryptoSystem
              .generateHash(signature.toVeilid().decode()))
          .decode();

  Future<void> _signMessage(proto.Message message) async {
    // Generate data to sign
    final data = Uint8List.fromList(utf8.encode(message.writeToJson()));

    // Sign with our identity
    final signature = await _identityCryptoSystem.sign(
        _activeAccountInfo.localAccount.identityMaster.identityPublicKey,
        _activeAccountInfo.userLogin.identitySecret.value,
        data);

    // Add to the message
    message.signature = signature.toProto();
  }

  Future<Uint8List> _generateInitialId(
          {required PublicKey identityPublicKey}) async =>
      (await _localMessagesCryptoSystem
              .generateHash(identityPublicKey.decode()))
          .decode();

  Future<void> _processMessageToSend(
      proto.Message message, proto.Message? previousMessage) async {
    // Get the previous message if we don't have one
    previousMessage ??= await _sentMessagesCubit!.operate((r) async =>
        r.length == 0
            ? null
            : await r.getProtobuf(proto.Message.fromBuffer, r.length - 1));

    if (previousMessage == null) {
      // If there's no last sent message,
      // we start at a hash of the identity public key
      message.id = await _generateInitialId(
          identityPublicKey:
              _activeAccountInfo.localAccount.identityMaster.identityPublicKey);
    } else {
      // If there is a last message, we generate the hash
      // of the last message's signature and use it as our next id
      message.id = await _hashSignature(previousMessage.signature);
    }

    // Now sign it
    await _signMessage(message);
  }

  // Async process to send messages in the background
  Future<void> _processSendingMessages(IList<proto.Message> messages) async {
    // Go through and assign ids to all the messages in order
    proto.Message? previousMessage;
    final processedMessages = messages.toList();
    for (final message in processedMessages) {
      await _processMessageToSend(message, previousMessage);
      previousMessage = message;
    }

    await _sentMessagesCubit!.operateAppendEventual((writer) =>
        writer.tryAddAll(messages.map((m) => m.writeToBuffer()).toList()));
  }

  // Produce a state for this cubit from the input cubits and queues
  void _renderState() {
    // Get all reconciled messages
    final reconciledMessages =
        _reconciledMessagesCubit?.state.state.asData?.value;
    // Get all sent messages
    final sentMessages = _sentMessagesCubit?.state.state.asData?.value;
    // Get all items in the unsent queue
    final sendingMessages = _sendingMessagesQueue.queue;

    // If we aren't ready to render a state, say we're loading
    if (reconciledMessages == null || sentMessages == null) {
      emit(const AsyncLoading());
      return;
    }

    // Generate state for each message
    final sentMessagesMap =
        IMap<String, DHTLogElementState<proto.Message>>.fromValues(
      keyMapper: (x) => x.value.uniqueIdString,
      values: sentMessages.elements,
    );
    final reconciledMessagesMap =
        IMap<String, proto.ReconciledMessage>.fromValues(
      keyMapper: (x) => x.content.uniqueIdString,
      values: reconciledMessages.elements,
    );
    final sendingMessagesMap = IMap<String, proto.Message>.fromValues(
      keyMapper: (x) => x.uniqueIdString,
      values: sendingMessages,
    );

    final renderedElements = <String, RenderStateElement>{};

    for (final m in reconciledMessagesMap.entries) {
      renderedElements[m.key] = RenderStateElement(
        message: m.value.content,
        isLocal: m.value.content.author.toVeilid() ==
            _activeAccountInfo.localAccount.identityMaster
                .identityPublicTypedKey(),
        reconciledTimestamp: Timestamp.fromInt64(m.value.reconciledTime),
      );
    }
    for (final m in sentMessagesMap.entries) {
      renderedElements.putIfAbsent(
          m.key,
          () => RenderStateElement(
                message: m.value.value,
                isLocal: true,
              ))
        ..sent = true
        ..sentOffline = m.value.isOffline;
    }
    for (final m in sendingMessagesMap.entries) {
      renderedElements
          .putIfAbsent(
              m.key,
              () => RenderStateElement(
                    message: m.value,
                    isLocal: true,
                  ))
          .sent = false;
    }

    // Render the state
    final messageKeys = renderedElements.entries
        .toIList()
        .sort((x, y) => x.key.compareTo(y.key));
    final renderedState = messageKeys
        .map((x) => MessageState(
            content: x.value.message,
            sentTimestamp: Timestamp.fromInt64(x.value.message.timestamp),
            reconciledTimestamp: x.value.reconciledTimestamp,
            sendState: x.value.sendState))
        .toIList();

    // Emit the rendered state
    emit(AsyncValue.data(renderedState));
  }

  void _sendMessage({required proto.Message message}) {
    // Add common fields
    // id and signature will get set by _processMessageToSend
    message
      ..author = _activeAccountInfo.localAccount.identityMaster
          .identityPublicTypedKey()
          .toProto()
      ..timestamp = Veilid.instance.now().toInt64();

    // Put in the queue
    _sendingMessagesQueue.addSync(message);

    // Update the view
    _renderState();
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
      'msg_$localConversationRecordKey';

  /////////////////////////////////////////////////////////////////////////

  final WaitSet<void> _initWait = WaitSet();
  final ActiveAccountInfo _activeAccountInfo;
  final TypedKey _remoteIdentityPublicKey;
  final TypedKey _localConversationRecordKey;
  final TypedKey _localMessagesRecordKey;
  final TypedKey _remoteConversationRecordKey;
  final TypedKey _remoteMessagesRecordKey;

  late final VeilidCrypto _messagesCrypto;
  late final VeilidCryptoSystem _localMessagesCryptoSystem;
  late final VeilidCryptoSystem _identityCryptoSystem;

  DHTLogCubit<proto.Message>? _sentMessagesCubit;
  DHTLogCubit<proto.Message>? _rcvdMessagesCubit;
  TableDBArrayCubit<proto.ReconciledMessage>? _reconciledMessagesCubit;

  late final MessageReconciliation _reconciliation;

  late final PersistentQueue<proto.Message> _sendingMessagesQueue;

  StreamSubscription<DHTLogBusyState<proto.Message>>? _sentSubscription;
  StreamSubscription<DHTLogBusyState<proto.Message>>? _rcvdSubscription;
  StreamSubscription<TableDBArrayBusyState<proto.ReconciledMessage>>?
      _reconciledSubscription;
}
