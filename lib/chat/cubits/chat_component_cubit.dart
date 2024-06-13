import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
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

class ChatComponentCubit extends Cubit<ChatComponentState> {
  ChatComponentCubit._({
    required SingleContactMessagesCubit messagesCubit,
    required types.User localUser,
    required IMap<TypedKey, types.User> remoteUsers,
  })  : _messagesCubit = messagesCubit,
        super(ChatComponentState(
          chatKey: GlobalKey<ChatState>(),
          scrollController: AutoScrollController(),
          localUser: localUser,
          remoteUsers: remoteUsers,
          messageWindow: const AsyncLoading(),
          title: '',
        )) {
    // Async Init
    _initWait.add(_init);
  }

  // ignore: prefer_constructors_over_static_methods
  static ChatComponentCubit singleContact(
      {required UnlockedAccountInfo activeAccountInfo,
      required proto.Account accountRecordInfo,
      required ActiveConversationState activeConversationState,
      required SingleContactMessagesCubit messagesCubit}) {
    // Make local 'User'
    final localUserIdentityKey = activeAccountInfo.identityTypedPublicKey;
    final localUser = types.User(
        id: localUserIdentityKey.toString(),
        firstName: accountRecordInfo.profile.name,
        metadata: {metadataKeyIdentityPublicKey: localUserIdentityKey});
    // Make remote 'User's
    final remoteUsers = {
      activeConversationState.contact.identityPublicKey.toVeilid(): types.User(
          id: activeConversationState.contact.identityPublicKey
              .toVeilid()
              .toString(),
          firstName: activeConversationState.contact.editedProfile.name,
          metadata: {
            metadataKeyIdentityPublicKey:
                activeConversationState.contact.identityPublicKey.toVeilid()
          })
    }.toIMap();

    return ChatComponentCubit._(
      messagesCubit: messagesCubit,
      localUser: localUser,
      remoteUsers: remoteUsers,
    );
  }

  Future<void> _init() async {
    _messagesSubscription = _messagesCubit.stream.listen((messagesState) {
      emit(state.copyWith(
        messageWindow: _convertMessages(messagesState),
      ));
    });
    emit(state.copyWith(
      messageWindow: _convertMessages(_messagesCubit.state),
      title: _getTitle(),
    ));
  }

  @override
  Future<void> close() async {
    await _initWait();
    await _messagesSubscription.cancel();
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

  String _getTitle() {
    if (state.remoteUsers.length == 1) {
      final remoteUser = state.remoteUsers.values.first;
      return remoteUser.firstName ?? '<unnamed>';
    } else {
      return '<group chat with ${state.remoteUsers.length} users>';
    }
  }

  types.Message? _messageStateToChatMessage(MessageState message) {
    final authorIdentityPublicKey = message.content.author.toVeilid();
    final author =
        state.remoteUsers[authorIdentityPublicKey] ?? state.localUser;

    types.Status? status;
    if (message.sendState != null) {
      assert(author == state.localUser,
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
        return textMessage;
      case proto.Message_Kind.secret:
      case proto.Message_Kind.delete:
      case proto.Message_Kind.erase:
      case proto.Message_Kind.settings:
      case proto.Message_Kind.permissions:
      case proto.Message_Kind.membership:
      case proto.Message_Kind.moderation:
      case proto.Message_Kind.notSet:
        return null;
    }
  }

  AsyncValue<WindowState<types.Message>> _convertMessages(
      AsyncValue<WindowState<MessageState>> avMessagesState) {
    final asError = avMessagesState.asError;
    if (asError != null) {
      return AsyncValue.error(asError.error, asError.stackTrace);
    } else if (avMessagesState.asLoading != null) {
      return const AsyncValue.loading();
    }
    final messagesState = avMessagesState.asData!.value;

    // Convert protobuf messages to chat messages
    final chatMessages = <types.Message>[];
    final tsSet = <String>{};
    for (final message in messagesState.window) {
      final chatMessage = _messageStateToChatMessage(message);
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
    return AsyncValue.data(WindowState<types.Message>(
        window: chatMessages.toIList(),
        length: messagesState.length,
        windowTail: messagesState.windowTail,
        windowCount: messagesState.windowCount,
        follow: messagesState.follow));
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
  final SingleContactMessagesCubit _messagesCubit;
  late StreamSubscription<SingleContactMessagesState> _messagesSubscription;
  double scrollOffset = 0;
}
