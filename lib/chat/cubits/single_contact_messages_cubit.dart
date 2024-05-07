import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../models/models.dart';

class RenderStateElement {
  RenderStateElement(
      {required this.message,
      required this.isLocal,
      this.reconciled = false,
      this.reconciledOffline = false,
      this.sent = false,
      this.sentOffline = false});

  MessageSendState? get sendState {
    if (!isLocal) {
      return null;
    }

    if (sent && !sentOffline) {
      return MessageSendState.delivered;
    }
    if (reconciled && !reconciledOffline) {
      return MessageSendState.sent;
    }
    return MessageSendState.sending;
  }

  proto.Message message;
  bool isLocal;
  bool reconciled;
  bool reconciledOffline;
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
    required OwnedDHTRecordPointer reconciledChatRecord,
  })  : _activeAccountInfo = activeAccountInfo,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _localConversationRecordKey = localConversationRecordKey,
        _localMessagesRecordKey = localMessagesRecordKey,
        _remoteConversationRecordKey = remoteConversationRecordKey,
        _remoteMessagesRecordKey = remoteMessagesRecordKey,
        _reconciledChatRecord = reconciledChatRecord,
        super(const AsyncValue.loading()) {
    // Async Init
    _initWait.add(_init);
  }

  @override
  Future<void> close() async {
    await _initWait();

    await _unreconciledMessagesQueue.close();
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
    // Late initialization of queues with closures
    _unreconciledMessagesQueue = PersistentQueue<proto.Message>(
      table: 'SingleContactUnreconciledMessages',
      key: _remoteConversationRecordKey.toString(),
      fromBuffer: proto.Message.fromBuffer,
      closure: _processUnreconciledMessages,
    );
    _sendingMessagesQueue = PersistentQueue<proto.Message>(
      table: 'SingleContactSendingMessages',
      key: _remoteConversationRecordKey.toString(),
      fromBuffer: proto.Message.fromBuffer,
      closure: _processSendingMessages,
    );

    // Make crypto
    await _initMessagesCrypto();

    // Reconciled messages key
    await _initReconciledMessagesCubit();

    // Local messages key
    await _initSentMessagesCubit();

    // Remote messages key
    await _initRcvdMessagesCubit();
  }

  // Make crypto
  Future<void> _initMessagesCrypto() async {
    _messagesCrypto = await _activeAccountInfo
        .makeConversationCrypto(_remoteIdentityPublicKey);
  }

  // Open local messages key
  Future<void> _initSentMessagesCubit() async {
    final writer = _activeAccountInfo.conversationWriter;

    _sentMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openWrite(
            _localMessagesRecordKey, writer,
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
    _rcvdMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openRead(_remoteMessagesRecordKey,
            debugName: 'SingleContactMessagesCubit::_initRcvdMessagesCubit::'
                'RcvdMessages',
            parent: _remoteConversationRecordKey,
            crypto: _messagesCrypto),
        decodeElement: proto.Message.fromBuffer);
    _rcvdSubscription =
        _rcvdMessagesCubit!.stream.listen(_updateRcvdMessagesState);
    _updateRcvdMessagesState(_rcvdMessagesCubit!.state);
  }

  // Open reconciled chat record key
  Future<void> _initReconciledMessagesCubit() async {
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    _reconciledMessagesCubit = DHTShortArrayCubit(
        open: () async => DHTShortArray.openOwned(_reconciledChatRecord,
            debugName:
                'SingleContactMessagesCubit::_initReconciledMessagesCubit::'
                'ReconciledMessages',
            parent: accountRecordKey),
        decodeElement: proto.Message.fromBuffer);
    _reconciledSubscription =
        _reconciledMessagesCubit!.stream.listen(_updateReconciledMessagesState);
    _updateReconciledMessagesState(_reconciledMessagesCubit!.state);
  }

  ////////////////////////////////////////////////////////////////////////////

  // Called when the sent messages cubit gets a change
  // This will re-render when messages are sent from another machine
  void _updateSentMessagesState(
      DHTShortArrayBusyState<proto.Message> avmessages) {
    final sentMessages = avmessages.state.asData?.value;
    if (sentMessages == null) {
      return;
    }
    // Don't reconcile, the sending machine will have already added
    // to the reconciliation queue on that machine

    // Update the view
    _renderState();
  }

  // Called when the received messages cubit gets a change
  void _updateRcvdMessagesState(
      DHTShortArrayBusyState<proto.Message> avmessages) {
    final rcvdMessages = avmessages.state.asData?.value;
    if (rcvdMessages == null) {
      return;
    }

    // Add remote messages updates to queue to process asynchronously
    // Ignore offline state because remote messages are always fully delivered
    // This may happen once per client but should be idempotent
    _unreconciledMessagesQueue.addAllSync(rcvdMessages.map((x) => x.value));

    // Update the view
    _renderState();
  }

  // Called when the reconciled messages list gets a change
  // This can happen when multiple clients for the same identity are
  // reading and reconciling the same remote chat
  void _updateReconciledMessagesState(
      DHTShortArrayBusyState<proto.Message> avmessages) {
    // Update the view
    _renderState();
  }

  // Async process to reconcile messages sent or received in the background
  Future<void> _processUnreconciledMessages(
      IList<proto.Message> messages) async {
    await _reconciledMessagesCubit!
        .operateWrite((reconciledMessagesWriter) async {
      await _reconcileMessagesInner(
          reconciledMessagesWriter: reconciledMessagesWriter,
          messages: messages);
    });
  }

  // Async process to send messages in the background
  Future<void> _processSendingMessages(IList<proto.Message> messages) async {
    for (final message in messages) {
      await _sentMessagesCubit!.operateWriteEventual(
          (writer) => writer.tryAddItem(message.writeToBuffer()));
    }
  }

  Future<void> _reconcileMessagesInner(
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

  // Produce a state for this cubit from the input cubits and queues
  void _renderState() {
    // Get all reconciled messages
    final reconciledMessages =
        _reconciledMessagesCubit?.state.state.asData?.value;
    // Get all sent messages
    final sentMessages = _sentMessagesCubit?.state.state.asData?.value;
    // Get all items in the unreconciled queue
    final unreconciledMessages = _unreconciledMessagesQueue.queue;
    // Get all items in the unsent queue
    final sendingMessages = _sendingMessagesQueue.queue;

    // If we aren't ready to render a state, say we're loading
    if (reconciledMessages == null || sentMessages == null) {
      emit(const AsyncLoading());
      return;
    }

    // Generate state for each message
    final sentMessagesMap =
        IMap<Int64, DHTShortArrayElementState<proto.Message>>.fromValues(
      keyMapper: (x) => x.value.timestamp,
      values: sentMessages,
    );
    final reconciledMessagesMap =
        IMap<Int64, DHTShortArrayElementState<proto.Message>>.fromValues(
      keyMapper: (x) => x.value.timestamp,
      values: reconciledMessages,
    );
    final sendingMessagesMap = IMap<Int64, proto.Message>.fromValues(
      keyMapper: (x) => x.timestamp,
      values: sendingMessages,
    );
    final unreconciledMessagesMap = IMap<Int64, proto.Message>.fromValues(
      keyMapper: (x) => x.timestamp,
      values: unreconciledMessages,
    );

    final renderedElements = <Int64, RenderStateElement>{};

    for (final m in reconciledMessagesMap.entries) {
      renderedElements[m.key] = RenderStateElement(
          message: m.value.value,
          isLocal: m.value.value.author.toVeilid() != _remoteIdentityPublicKey,
          reconciled: true,
          reconciledOffline: m.value.isOffline);
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
    for (final m in unreconciledMessagesMap.entries) {
      renderedElements
          .putIfAbsent(
              m.key,
              () => RenderStateElement(
                    message: m.value,
                    isLocal:
                        m.value.author.toVeilid() != _remoteIdentityPublicKey,
                  ))
          .reconciled = false;
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
            author: x.value.message.author.toVeilid(),
            timestamp: Timestamp.fromInt64(x.key),
            text: x.value.message.text,
            sendState: x.value.sendState))
        .toIList();

    // Emit the rendered state

    emit(AsyncValue.data(renderedState));
  }

  void addMessage({required proto.Message message}) {
    _unreconciledMessagesQueue.addSync(message);
    _sendingMessagesQueue.addSync(message);

    // Update the view
    _renderState();
  }

  final WaitSet<void> _initWait = WaitSet();
  final ActiveAccountInfo _activeAccountInfo;
  final TypedKey _remoteIdentityPublicKey;
  final TypedKey _localConversationRecordKey;
  final TypedKey _localMessagesRecordKey;
  final TypedKey _remoteConversationRecordKey;
  final TypedKey _remoteMessagesRecordKey;
  final OwnedDHTRecordPointer _reconciledChatRecord;

  late final DHTRecordCrypto _messagesCrypto;

  DHTShortArrayCubit<proto.Message>? _sentMessagesCubit;
  DHTShortArrayCubit<proto.Message>? _rcvdMessagesCubit;
  DHTShortArrayCubit<proto.Message>? _reconciledMessagesCubit;

  late final PersistentQueue<proto.Message> _unreconciledMessagesQueue;
  late final PersistentQueue<proto.Message> _sendingMessagesQueue;

  StreamSubscription<DHTShortArrayBusyState<proto.Message>>? _sentSubscription;
  StreamSubscription<DHTShortArrayBusyState<proto.Message>>? _rcvdSubscription;
  StreamSubscription<DHTShortArrayBusyState<proto.Message>>?
      _reconciledSubscription;
}
