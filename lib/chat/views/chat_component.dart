import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
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
import '../../tools/tools.dart';
import '../chat.dart';

class ChatComponent extends StatelessWidget {
  const ChatComponent._(
      {required TypedKey localUserIdentityKey,
      required TypedKey remoteConversationRecordKey,
      required MessagesCubit messagesCubit,
      required types.User localUser,
      required types.User remoteUser,
      super.key})
      : _localUserIdentityKey = localUserIdentityKey,
        _remoteConversationRecordKey = remoteConversationRecordKey,
        _messagesCubit = messagesCubit,
        _localUser = localUser,
        _remoteUser = remoteUser;

  final TypedKey _localUserIdentityKey;
  final TypedKey _remoteConversationRecordKey;
  final MessagesCubit _messagesCubit;
  final types.User _localUser;
  final types.User _remoteUser;

  // Builder wrapper function that takes care of state management requirements
  static Widget builder(
          {required TypedKey remoteConversationRecordKey, Key? key}) =>
      Builder(builder: (context) {
        // Get all watched dependendies
        final activeAccountInfo = context.watch<ActiveAccountInfo>();
        final accountRecordInfo =
            context.watch<AccountRecordCubit>().state.data?.value;
        if (accountRecordInfo == null) {
          return debugPage('should always have an account record here');
        }
        final contactList =
            context.watch<ContactListCubit>().state.state.data?.value;
        if (contactList == null) {
          return debugPage('should always have a contact list here');
        }
        final avconversation = context.select<ActiveConversationsBlocMapCubit,
                AsyncValue<ActiveConversationState>?>(
            (x) => x.state[remoteConversationRecordKey]);
        if (avconversation == null) {
          return waitingPage();
        }
        final conversation = avconversation.data?.value;
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
        final messagesCubit = context
            .select<ActiveConversationMessagesBlocMapCubit, MessagesCubit?>(
                (x) => x.tryOperate(remoteConversationRecordKey,
                    closure: (cubit) => cubit));

        // Get the messages to display
        // and ensure it is safe to operate() on the MessageCubit for this chat
        if (messagesCubit == null) {
          return waitingPage();
        }

        return ChatComponent._(
            localUserIdentityKey: localUserIdentityKey,
            remoteConversationRecordKey: remoteConversationRecordKey,
            messagesCubit: messagesCubit,
            localUser: localUser,
            remoteUser: remoteUser,
            key: key);
      });

  /////////////////////////////////////////////////////////////////////

  types.Message messageToChatMessage(proto.Message message) {
    final isLocal = message.author == _localUserIdentityKey.toProto();

    final textMessage = types.TextMessage(
      author: isLocal ? _localUser : _remoteUser,
      createdAt: (message.timestamp ~/ 1000).toInt(),
      id: message.timestamp.toString(),
      text: message.text,
    );
    return textMessage;
  }

  Future<void> _addMessage(proto.Message message) async {
    if (message.text.isEmpty) {
      return;
    }
    await _messagesCubit.addMessage(message: message);
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final protoMessage = proto.Message()
      ..author = _localUserIdentityKey.toProto()
      ..timestamp = Veilid.instance.now().toInt64()
      ..text = message.text;
    //..signature = signature;

    await _addMessage(protoMessage);
  }

  Future<void> _handleAttachmentPressed() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = makeChatTheme(scale, textTheme);

    final avmessages = _messagesCubit.state;
    final messages = avmessages.data?.value;
    if (messages == null) {
      return avmessages.buildNotData();
    }

    // Convert protobuf messages to chat messages
    final chatMessages = <types.Message>[];
    for (final message in messages) {
      final chatMessage = messageToChatMessage(message);
      chatMessages.insert(0, chatMessage);
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
                                style: textTheme.titleMedium),
                          )),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close),
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
                        messages: chatMessages,
                        //onAttachmentPressed: _handleAttachmentPressed,
                        //onMessageTap: _handleMessageTap,
                        //onPreviewDataFetched: _handlePreviewDataFetched,
                        onSendPressed: (message) {
                          singleFuture(
                              this, () async => _handleSendPressed(message));
                        },
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
