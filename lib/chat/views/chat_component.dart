import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat_list/chat_list.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../chat.dart';

const String metadataKeyExpirationDuration = 'expiration';
const String metadataKeyViewLimit = 'view_limit';
const String metadataKeyAttachments = 'attachments';

class ChatComponent extends StatelessWidget {
  const ChatComponent._(
      {required TypedKey localUserIdentityKey,
      required SingleContactMessagesCubit messagesCubit,
      required SingleContactMessagesState messagesState,
      required types.User localUser,
      required types.User remoteUser,
      super.key})
      : _localUserIdentityKey = localUserIdentityKey,
        _messagesCubit = messagesCubit,
        _messagesState = messagesState,
        _localUser = localUser,
        _remoteUser = remoteUser;

  final TypedKey _localUserIdentityKey;
  final SingleContactMessagesCubit _messagesCubit;
  final SingleContactMessagesState _messagesState;
  final types.User _localUser;
  final types.User _remoteUser;

  // Builder wrapper function that takes care of state management requirements
  static Widget builder(
          {required TypedKey localConversationRecordKey, Key? key}) =>
      Builder(builder: (context) {
        // Get all watched dependendies
        final activeAccountInfo = context.watch<ActiveAccountInfo>();
        final accountRecordInfo =
            context.watch<AccountRecordCubit>().state.asData?.value;
        if (accountRecordInfo == null) {
          return debugPage('should always have an account record here');
        }
        final contactList =
            context.watch<ContactListCubit>().state.state.asData?.value;
        if (contactList == null) {
          return debugPage('should always have a contact list here');
        }
        final avconversation = context.select<ActiveConversationsBlocMapCubit,
                AsyncValue<ActiveConversationState>?>(
            (x) => x.state[localConversationRecordKey]);
        if (avconversation == null) {
          return waitingPage();
        }
        final conversation = avconversation.asData?.value;
        if (conversation == null) {
          return avconversation.buildNotData();
        }

        // Make flutter_chat_ui 'User's
        final localUserIdentityKey = activeAccountInfo
            .localAccount.identityMaster
            .identityPublicTypedKey();

        final localUser = types.User(
          id: localUserIdentityKey.toString(),
          firstName: accountRecordInfo.profile.name,
        );
        final editedName = conversation.contact.editedProfile.name;
        final remoteUser = types.User(
            id: conversation.contact.identityPublicKey.toVeilid().toString(),
            firstName: editedName);

        // Get the messages cubit
        final messages = context.select<ActiveSingleContactChatBlocMapCubit,
                (SingleContactMessagesCubit, SingleContactMessagesState)?>(
            (x) => x.tryOperate(localConversationRecordKey,
                closure: (cubit) => (cubit, cubit.state)));

        // Get the messages to display
        // and ensure it is safe to operate() on the MessageCubit for this chat
        if (messages == null) {
          return waitingPage();
        }

        return ChatComponent._(
            localUserIdentityKey: localUserIdentityKey,
            messagesCubit: messages.$1,
            messagesState: messages.$2,
            localUser: localUser,
            remoteUser: remoteUser,
            key: key);
      });

  /////////////////////////////////////////////////////////////////////

  types.Message? messageToChatMessage(MessageState message) {
    final isLocal = message.content.author.toVeilid() == _localUserIdentityKey;

    types.Status? status;
    if (message.sendState != null) {
      assert(isLocal, 'send state should only be on sent messages');
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
            author: isLocal ? _localUser : _remoteUser,
            createdAt: (message.timestamp.value ~/ BigInt.from(1000)).toInt(),
            id: message.uniqueId,
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

    _messagesCubit.addTextMessage(messageText: protoMessageText);
  }

  void _handleSendPressed(types.PartialText message) {
    final text = message.text;
    final replyId = (message.repliedMessage != null)
        ? MessageStateExt.splitUniqueId(message.repliedMessage!.id).$2
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

  // void _handleAttachmentPressed() async {
  //   //
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = makeChatTheme(scale, textTheme);

    final messages = _messagesState.asData?.value;
    if (messages == null) {
      return _messagesState.buildNotData();
    }

    // Convert protobuf messages to chat messages
    final chatMessages = <types.Message>[];
    final tsSet = <String>{};
    for (final message in messages) {
      final chatMessage = messageToChatMessage(message);
      if (chatMessage == null) {
        continue;
      }
      chatMessages.insert(0, chatMessage);
      if (!tsSet.add(chatMessage.id)) {
        // ignore: avoid_print
        print('duplicate id found: ${chatMessage.id}:\n'
            'Messages:\n$messages\n'
            'ChatMessages:\n$chatMessages');
        assert(false, 'should not have duplicate id');
      }
    }

    return DefaultTextStyle(
        style: textTheme.bodySmall!,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: scale.primaryScale.subtleBorder,
                    ),
                    child: Row(children: [
                      Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            child: Text(_remoteUser.firstName!,
                                textAlign: TextAlign.start,
                                style: textTheme.titleMedium!.copyWith(
                                    color: scale.primaryScale.borderText)),
                          )),
                      const Spacer(),
                      IconButton(
                          icon: Icon(Icons.close,
                              color: scale.primaryScale.borderText),
                          onPressed: () async {
                            context.read<ActiveChatCubit>().setActiveChat(null);
                          }).paddingLTRB(16, 0, 16, 0)
                    ]),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(),
                      child: Chat(
                        theme: chatTheme,
                        // emojiEnlargementBehavior:
                        //     EmojiEnlargementBehavior.multi,
                        messages: chatMessages,
                        //onAttachmentPressed: _handleAttachmentPressed,
                        //onMessageTap: _handleMessageTap,
                        //onPreviewDataFetched: _handlePreviewDataFetched,
                        onSendPressed: _handleSendPressed,
                        //showUserAvatars: false,
                        //showUserNames: true,
                        user: _localUser,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
