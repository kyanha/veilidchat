import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../conversation/conversation.dart';
import '../../proto/proto.dart' as proto;
import '../models/chat_component_state.dart';
import '../models/message_state.dart';
import '../models/window_state.dart';
import 'cubits.dart';

const metadataKeyIdentityPublicKey = 'identityPublicKey';
const metadataKeyExpirationDuration = 'expiration';
const metadataKeyViewLimit = 'view_limit';
const metadataKeyAttachments = 'attachments';
const _sfChangedContacts = 'changedContacts';

class ChatComponentCubit extends Cubit<ChatComponentState> {
  ChatComponentCubit._({
    required AccountInfo accountInfo,
    required AccountRecordCubit accountRecordCubit,
    required ContactListCubit contactListCubit,
    required List<ActiveConversationCubit> conversationCubits,
    required SingleContactMessagesCubit messagesCubit,
  })  : _accountInfo = accountInfo,
        _accountRecordCubit = accountRecordCubit,
        _contactListCubit = contactListCubit,
        _conversationCubits = conversationCubits,
        _messagesCubit = messagesCubit,
        super(ChatComponentState(
          chatKey: GlobalKey<ChatState>(),
          scrollController: AutoScrollController(),
          textEditingController: InputTextFieldController(),
          localUser: null,
          remoteUsers: const IMap.empty(),
          historicalRemoteUsers: const IMap.empty(),
          unknownUsers: const IMap.empty(),
          messageWindow: const AsyncLoading(),
          title: '',
        )) {
    // Async Init
    _initWait.add(_init);
  }

  factory ChatComponentCubit.singleContact(
          {required AccountInfo accountInfo,
          required AccountRecordCubit accountRecordCubit,
          required ContactListCubit contactListCubit,
          required ActiveConversationCubit activeConversationCubit,
          required SingleContactMessagesCubit messagesCubit}) =>
      ChatComponentCubit._(
        accountInfo: accountInfo,
        accountRecordCubit: accountRecordCubit,
        contactListCubit: contactListCubit,
        conversationCubits: [activeConversationCubit],
        messagesCubit: messagesCubit,
      );

  Future<void> _init() async {
    // Get local user info and account record cubit
    _localUserIdentityKey = _accountInfo.identityTypedPublicKey;

    // Subscribe to local user info
    _accountRecordSubscription =
        _accountRecordCubit.stream.listen(_onChangedAccountRecord);
    _onChangedAccountRecord(_accountRecordCubit.state);

    // Subscribe to remote user info
    await _updateConversationSubscriptions();

    // Subscribe to messages
    _messagesSubscription = _messagesCubit.stream.listen(_onChangedMessages);
    _onChangedMessages(_messagesCubit.state);

    // Subscribe to contact list changes
    _contactListSubscription =
        _contactListCubit.stream.listen(_onChangedContacts);
    _onChangedContacts(_contactListCubit.state);
  }

  @override
  Future<void> close() async {
    await _initWait();
    await _contactListSubscription.cancel();
    await _accountRecordSubscription.cancel();
    await _messagesSubscription.cancel();
    await _conversationSubscriptions.values.map((v) => v.cancel()).wait;
    await super.close();
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  // Set the tail position of the log for pagination.
  // If tail is 0, the end of the log is used.
  // If tail is negative, the position is subtracted from the current log
  // length.
  // If tail is positive, the position is absolute from the head of the log
  // If follow is enabled, the tail offset will update when the log changes
  Future<void> setWindow(
      {int? tail, int? count, bool? follow, bool forceRefresh = false}) async {
    //await _initWait();
    await _messagesCubit.setWindow(
        tail: tail, count: count, follow: follow, forceRefresh: forceRefresh);
  }

  // Send a message
  void sendMessage(types.PartialText message) {
    final text = message.text;

    final replyId = (message.repliedMessage != null)
        ? base64UrlNoPadDecode(message.repliedMessage!.id)
        : null;
    Timestamp? expiration;
    int? viewLimit;
    List<proto.Attachment>? attachments;
    final metadata = message.metadata;
    if (metadata != null) {
      final expirationValue =
          metadata[metadataKeyExpirationDuration] as TimestampDuration?;
      if (expirationValue != null) {
        expiration = Veilid.instance.now().offset(expirationValue);
      }
      final viewLimitValue = metadata[metadataKeyViewLimit] as int?;
      if (viewLimitValue != null) {
        viewLimit = viewLimitValue;
      }
      final attachmentsValue =
          metadata[metadataKeyAttachments] as List<proto.Attachment>?;
      if (attachmentsValue != null) {
        attachments = attachmentsValue;
      }
    }

    _addTextMessage(
        text: text,
        replyId: replyId,
        expiration: expiration,
        viewLimit: viewLimit,
        attachments: attachments ?? []);
  }

  // Run a chat command
  void runCommand(String command) {
    _messagesCubit.runCommand(command);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Private Implementation

  void _onChangedAccountRecord(AsyncValue<proto.Account> avAccount) {
    // Update local 'User'
    final account = avAccount.asData?.value;
    if (account == null) {
      emit(state.copyWith(localUser: null));
      return;
    }
    final localUser = types.User(
        id: _localUserIdentityKey.toString(),
        firstName: account.profile.name,
        metadata: {metadataKeyIdentityPublicKey: _localUserIdentityKey});
    emit(state.copyWith(localUser: localUser));
  }

  void _onChangedMessages(
      AsyncValue<WindowState<MessageState>> avMessagesState) {
    emit(_convertMessages(state, avMessagesState));
  }

  void _onChangedContacts(
      BlocBusyState<AsyncValue<IList<DHTShortArrayElementState<proto.Contact>>>>
          bavContacts) {
    // Rewrite users when contacts change
    singleFuture((this, _sfChangedContacts), _updateConversationSubscriptions);
  }

  void _onChangedConversation(
    TypedKey remoteIdentityPublicKey,
    AsyncValue<ActiveConversationState> avConversationState,
  ) {
    // Update remote 'User'
    final activeConversationState = avConversationState.asData?.value;
    if (activeConversationState == null) {
      // Don't change user information on loading state
      return;
    }
    emit(_updateTitle(state.copyWith(
        remoteUsers: state.remoteUsers.add(
            remoteIdentityPublicKey,
            _convertRemoteUser(
                remoteIdentityPublicKey, activeConversationState)))));
  }

  static ChatComponentState _updateTitle(ChatComponentState currentState) {
    if (currentState.remoteUsers.length == 0) {
      return currentState.copyWith(title: 'Empty Chat');
    }
    if (currentState.remoteUsers.length == 1) {
      final remoteUser = currentState.remoteUsers.values.first;
      return currentState.copyWith(title: remoteUser.firstName ?? '<unnamed>');
    }
    return currentState.copyWith(
        title: '<group chat with ${currentState.remoteUsers.length} users>');
  }

  types.User _convertRemoteUser(TypedKey remoteIdentityPublicKey,
      ActiveConversationState activeConversationState) {
    // See if we have a contact for this remote user
    final contacts = _contactListCubit.state.state.asData?.value;
    if (contacts != null) {
      final contactIdx = contacts.indexWhere((x) =>
          x.value.identityPublicKey.toVeilid() == remoteIdentityPublicKey);
      if (contactIdx != -1) {
        final contact = contacts[contactIdx].value;
        return types.User(
            id: remoteIdentityPublicKey.toString(),
            firstName: contact.displayName,
            metadata: {metadataKeyIdentityPublicKey: remoteIdentityPublicKey});
      }
    }

    return types.User(
        id: remoteIdentityPublicKey.toString(),
        firstName: activeConversationState.remoteConversation.profile.name,
        metadata: {metadataKeyIdentityPublicKey: remoteIdentityPublicKey});
  }

  types.User _convertUnknownUser(TypedKey remoteIdentityPublicKey) =>
      types.User(
          id: remoteIdentityPublicKey.toString(),
          firstName: '<$remoteIdentityPublicKey>',
          metadata: {metadataKeyIdentityPublicKey: remoteIdentityPublicKey});

  Future<void> _updateConversationSubscriptions() async {
    // Get existing subscription keys and state
    final existing = _conversationSubscriptions.keys.toList();
    var currentRemoteUsersState = state.remoteUsers;

    // Process cubit list
    for (final cc in _conversationCubits) {
      // Get the remote identity key
      final remoteIdentityPublicKey = cc.input.remoteIdentityPublicKey;

      // If the cubit is already being listened to we have nothing to do
      if (existing.remove(remoteIdentityPublicKey)) {
        // If the cubit is not already being listened to we should do that
        _conversationSubscriptions[remoteIdentityPublicKey] = cc.stream.listen(
            (avConv) =>
                _onChangedConversation(remoteIdentityPublicKey, avConv));
      }

      final activeConversationState = cc.state.asData?.value;
      if (activeConversationState != null) {
        currentRemoteUsersState = currentRemoteUsersState.add(
            remoteIdentityPublicKey,
            _convertRemoteUser(
                remoteIdentityPublicKey, activeConversationState));
      }
    }
    // Purge remote users we didn't see in the cubit list any more
    final cancels = <Future<void>>[];
    for (final deadUser in existing) {
      currentRemoteUsersState = currentRemoteUsersState.remove(deadUser);
      cancels.add(_conversationSubscriptions.remove(deadUser)!.cancel());
    }
    await cancels.wait;

    // Emit change to remote users state
    emit(_updateTitle(state.copyWith(remoteUsers: currentRemoteUsersState)));
  }

  (ChatComponentState, types.Message?) _messageStateToChatMessage(
      ChatComponentState currentState, MessageState message) {
    final authorIdentityPublicKey = message.content.author.toVeilid();
    late final types.User author;
    if (authorIdentityPublicKey == _localUserIdentityKey &&
        currentState.localUser != null) {
      author = currentState.localUser!;
    } else {
      final remoteUser = currentState.remoteUsers[authorIdentityPublicKey];
      if (remoteUser != null) {
        author = remoteUser;
      } else {
        final historicalRemoteUser =
            currentState.historicalRemoteUsers[authorIdentityPublicKey];
        if (historicalRemoteUser != null) {
          author = historicalRemoteUser;
        } else {
          final unknownRemoteUser =
              currentState.unknownUsers[authorIdentityPublicKey];
          if (unknownRemoteUser != null) {
            author = unknownRemoteUser;
          } else {
            final unknownUser = _convertUnknownUser(authorIdentityPublicKey);
            currentState = currentState.copyWith(
                unknownUsers: currentState.unknownUsers
                    .add(authorIdentityPublicKey, unknownUser));
            author = unknownUser;
          }
        }
      }
    }

    types.Status? status;
    if (message.sendState != null) {
      assert(author.id == _localUserIdentityKey.toString(),
          'send state should only be on sent messages');
      switch (message.sendState!) {
        case MessageSendState.sending:
          status = types.Status.sending;
        case MessageSendState.sent:
          status = types.Status.sent;
        case MessageSendState.delivered:
          status = types.Status.delivered;
      }
    }

    switch (message.content.whichKind()) {
      case proto.Message_Kind.text:
        final contextText = message.content.text;
        final textMessage = types.TextMessage(
            author: author,
            createdAt:
                (message.sentTimestamp.value ~/ BigInt.from(1000)).toInt(),
            id: message.content.authorUniqueIdString,
            text: contextText.text,
            showStatus: status != null,
            status: status);
        return (currentState, textMessage);
      case proto.Message_Kind.secret:
      case proto.Message_Kind.delete:
      case proto.Message_Kind.erase:
      case proto.Message_Kind.settings:
      case proto.Message_Kind.permissions:
      case proto.Message_Kind.membership:
      case proto.Message_Kind.moderation:
      case proto.Message_Kind.notSet:
        return (currentState, null);
    }
  }

  ChatComponentState _convertMessages(ChatComponentState currentState,
      AsyncValue<WindowState<MessageState>> avMessagesState) {
    // Clear out unknown users
    currentState = state.copyWith(unknownUsers: const IMap.empty());

    final asError = avMessagesState.asError;
    if (asError != null) {
      return currentState.copyWith(
          unknownUsers: const IMap.empty(),
          messageWindow: AsyncValue.error(asError.error, asError.stackTrace));
    } else if (avMessagesState.asLoading != null) {
      return currentState.copyWith(
          unknownUsers: const IMap.empty(),
          messageWindow: const AsyncValue.loading());
    }
    final messagesState = avMessagesState.asData!.value;

    // Convert protobuf messages to chat messages
    final chatMessages = <types.Message>[];
    final tsSet = <String>{};
    for (final message in messagesState.window) {
      final (newState, chatMessage) =
          _messageStateToChatMessage(currentState, message);
      currentState = newState;
      if (chatMessage == null) {
        continue;
      }
      chatMessages.insert(0, chatMessage);
      if (!tsSet.add(chatMessage.id)) {
        // ignore: avoid_print
        print('duplicate id found: ${chatMessage.id}:\n'
            'Messages:\n${messagesState.window}\n'
            'ChatMessages:\n$chatMessages');
        assert(false, 'should not have duplicate id');
      }
    }
    return currentState.copyWith(
        messageWindow: AsyncValue.data(WindowState<types.Message>(
            window: chatMessages.toIList(),
            length: messagesState.length,
            windowTail: messagesState.windowTail,
            windowCount: messagesState.windowCount,
            follow: messagesState.follow)));
  }

  void _addTextMessage(
      {required String text,
      String? topic,
      Uint8List? replyId,
      Timestamp? expiration,
      int? viewLimit,
      List<proto.Attachment> attachments = const []}) {
    final protoMessageText = proto.Message_Text()..text = text;
    if (topic != null) {
      protoMessageText.topic = topic;
    }
    if (replyId != null) {
      protoMessageText.replyId = replyId;
    }
    protoMessageText
      ..expiration = expiration?.toInt64() ?? Int64.ZERO
      ..viewLimit = viewLimit ?? 0;
    protoMessageText.attachments.addAll(attachments);

    _messagesCubit.sendTextMessage(messageText: protoMessageText);
  }

  ////////////////////////////////////////////////////////////////////////////

  final _initWait = WaitSet<void>();
  final AccountInfo _accountInfo;
  final AccountRecordCubit _accountRecordCubit;
  final ContactListCubit _contactListCubit;
  final List<ActiveConversationCubit> _conversationCubits;
  final SingleContactMessagesCubit _messagesCubit;

  late final TypedKey _localUserIdentityKey;
  late final StreamSubscription<AsyncValue<proto.Account>>
      _accountRecordSubscription;
  final Map<TypedKey, StreamSubscription<AsyncValue<ActiveConversationState>>>
      _conversationSubscriptions = {};
  late StreamSubscription<SingleContactMessagesState> _messagesSubscription;
  late StreamSubscription<
          BlocBusyState<
              AsyncValue<IList<DHTShortArrayElementState<proto.Contact>>>>>
      _contactListSubscription;
  double scrollOffset = 0;
}
