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

  // Open reconciled chat record key
  Future<void> _initReconciledMessagesCubit() async {
    final tableName = _localConversationRecordKey.toString();

  xxx whats the right encryption for reconciled messages cubit?

    final crypto = VeilidCryptoPrivate.fromTypedKey(kind, secretKey);
    _reconciledMessagesCubit = TableDBArrayCubit(
        open: () async => TableDBArray.make(table: tableName, crypto: crypto),
        decodeElement: proto.Message.fromBuffer);
    _reconciledSubscription =
        _reconciledMessagesCubit!.stream.listen(_updateReconciledMessagesState);
    _updateReconciledMessagesState(_reconciledMessagesCubit!.state);
  }

  ////////////////////////////////////////////////////////////////////////////

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

  ////////////////////////////////////////////////////////////////////////////

  // Called when the sent messages cubit gets a change
  // This will re-render when messages are sent from another machine
  void _updateSentMessagesState(DHTLogBusyState<proto.Message> avmessages) {
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
  void _updateRcvdMessagesState(DHTLogBusyState<proto.Message> avmessages) {
    final rcvdMessages = avmessages.state.asData?.value;
    if (rcvdMessages == null) {
      return;
    }

    singleFuture(_rcvdMessagesCubit!, () async {
      // Get the timestamp of our most recent reconciled message
      final lastReconciledMessageTs =
          await _reconciledMessagesCubit!.operate((r) async {
        final len = r.length;
        if (len == 0) {
          return null;
        } else {
          final lastMessage =
              await r.getItemProtobuf(proto.Message.fromBuffer, len - 1);
          if (lastMessage == null) {
            throw StateError('should have gotten last message');
          }
          return lastMessage.timestamp;
        }
      });

      // Find oldest message we have not yet reconciled

      // // Go through all the ones from the cubit state first since we've already
      // // gotten them from the DHT
      // for (var rn = rcvdMessages.elements.length; rn >= 0; rn--) {
      //   //
      // }

      // // Add remote messages updates to queue to process asynchronously
      // // Ignore offline state because remote messages are always fully delivered
      // // This may happen once per client but should be idempotent
      // _unreconciledMessagesQueue.addAllSync(rcvdMessages.map((x) => x.value));

      // Update the view
      _renderState();
    });
  }

  // Called when the reconciled messages list gets a change
  // This can happen when multiple clients for the same identity are
  // reading and reconciling the same remote chat
  void _updateReconciledMessagesState(
      DHTLogBusyState<proto.Message> avmessages) {
    // Update the view
    _renderState();
  }

  // Async process to reconcile messages sent or received in the background
  Future<void> _processUnreconciledMessages(
      IList<proto.Message> messages) async {
    // await _reconciledMessagesCubit!
    //     .operateAppendEventual((reconciledMessagesWriter) async {
    //   await _reconcileMessagesInner(
    //       reconciledMessagesWriter: reconciledMessagesWriter,
    //       messages: messages);
    // });
  }

  // Async process to send messages in the background
  Future<void> _processSendingMessages(IList<proto.Message> messages) async {
    await _sentMessagesCubit!.operateAppendEventual((writer) =>
        writer.tryAddItems(messages.map((m) => m.writeToBuffer()).toList()));
  }

  Future<void> _reconcileMessagesInner(
      {required DHTLogWriteOperations reconciledMessagesWriter,
      required IList<proto.Message> messages}) async {
    // // Ensure remoteMessages is sorted by timestamp
    // final newMessages = messages
    //     .sort((a, b) => a.timestamp.compareTo(b.timestamp))
    //     .removeDuplicates();

    // // Existing messages will always be sorted by timestamp so merging is easy
    // final existingMessages = await reconciledMessagesWriter
    //     .getItemRangeProtobuf(proto.Message.fromBuffer, 0);
    // if (existingMessages == null) {
    //   throw Exception(
    //       'Could not load existing reconciled messages at this time');
    // }

    // var ePos = 0;
    // var nPos = 0;
    // while (ePos < existingMessages.length && nPos < newMessages.length) {
    //   final existingMessage = existingMessages[ePos];
    //   final newMessage = newMessages[nPos];

    //   // If timestamp to insert is less than
    //   // the current position, insert it here
    //   final newTs = Timestamp.fromInt64(newMessage.timestamp);
    //   final existingTs = Timestamp.fromInt64(existingMessage.timestamp);
    //   final cmp = newTs.compareTo(existingTs);
    //   if (cmp < 0) {
    //     // New message belongs here

    //     // Insert into dht backing array
    //     await reconciledMessagesWriter.tryInsertItem(
    //         ePos, newMessage.writeToBuffer());
    //     // Insert into local copy as well for this operation
    //     existingMessages.insert(ePos, newMessage);

    //     // Next message
    //     nPos++;
    //     ePos++;
    //   } else if (cmp == 0) {
    //     // Duplicate, skip
    //     nPos++;
    //     ePos++;
    //   } else if (cmp > 0) {
    //     // New message belongs later
    //     ePos++;
    //   }
    // }
    // // If there are any new messages left, append them all
    // while (nPos < newMessages.length) {
    //   final newMessage = newMessages[nPos];

    //   // Append to dht backing array
    //   await reconciledMessagesWriter.tryAddItem(newMessage.writeToBuffer());
    //   // Insert into local copy as well for this operation
    //   existingMessages.add(newMessage);

    //   nPos++;
    // }
  }

  // Produce a state for this cubit from the input cubits and queues
  void _renderState() {
    //  xxx move into a singlefuture

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
        IMap<Int64, DHTLogElementState<proto.Message>>.fromValues(
      keyMapper: (x) => x.value.timestamp,
      values: sentMessages.elements,
    );
    final reconciledMessagesMap =
        IMap<Int64, DHTLogElementState<proto.Message>>.fromValues(
      keyMapper: (x) => x.value.timestamp,
      values: reconciledMessages.elements,
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
            content: x.value.message,
            timestamp: Timestamp.fromInt64(x.key),
            sendState: x.value.sendState))
        .toIList();

    // Emit the rendered state

    emit(AsyncValue.data(renderedState));
  }

  void addTextMessage({required proto.Message_Text messageText}) {
    final message = proto.Message()
      ..id = generateNextId()
      ..author = _activeAccountInfo.localAccount.identityMaster
          .identityPublicTypedKey()
          .toProto()
      ..timestamp = Veilid.instance.now().toInt64()
      ..text = messageText;

    _unreconciledMessagesQueue.addSync(message);
    _sendingMessagesQueue.addSync(message);

    // Update the view
    _renderState();
  }

  /////////////////////////////////////////////////////////////////////////

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

  DHTLogCubit<proto.Message>? _sentMessagesCubit;
  DHTLogCubit<proto.Message>? _rcvdMessagesCubit;
  TableDBArrayCubit<proto.Message>? _reconciledMessagesCubit;

  late final PersistentQueue<proto.Message> _unreconciledMessagesQueue;
  late final PersistentQueue<proto.Message> _sendingMessagesQueue;

  StreamSubscription<DHTLogBusyState<proto.Message>>? _sentSubscription;
  StreamSubscription<DHTLogBusyState<proto.Message>>? _rcvdSubscription;
  StreamSubscription<DHTLogBusyState<proto.Message>>? _reconciledSubscription;
}
