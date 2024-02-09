import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../chat.dart';

class ChatComponent extends StatefulWidget {
  const ChatComponent({super.key});

  @override
  ChatComponentState createState() => ChatComponentState();
}

class ChatComponentState extends State<ChatComponent> {
  final _unfocusNode = FocusNode();
  late final types.User _localUser;
  late final types.User _remoteUser;

  @override
  void initState() {
    super.initState();

    _localUser = types.User(
      id: widget.activeAccountInfo.localAccount.identityMaster
          .identityPublicTypedKey()
          .toString(),
      firstName: widget.activeAccountInfo.account.profile.name,
    );
    _remoteUser = types.User(
        id: proto.TypedKeyProto.fromProto(
                widget.activeChatContact.identityPublicKey)
            .toString(),
        firstName: widget.activeChatContact.remoteProfile.name);
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  types.Message protoMessageToMessage(proto.Message message) {
    final isLocal = message.author ==
        widget.activeAccountInfo.localAccount.identityMaster
            .identityPublicTypedKey()
            .toProto();

    final textMessage = types.TextMessage(
      author: isLocal ? _localUser : _remoteUser,
      createdAt: (message.timestamp ~/ 1000).toInt(),
      id: message.timestamp.toString(),
      text: message.text,
    );
    return textMessage;
  }

  Future<void> _addMessage(proto.Message protoMessage) async {
    if (protoMessage.text.isEmpty) {
      return;
    }

    final message = protoMessageToMessage(protoMessage);

    // setState(() {
    //   _messages.insert(0, message);
    // });

    // Now add the message to the conversation messages
    final localConversationRecordKey = proto.TypedKeyProto.fromProto(
        widget.activeChatContact.localConversationRecordKey);
    final remoteIdentityPublicKey = proto.TypedKeyProto.fromProto(
        widget.activeChatContact.identityPublicKey);

    await addLocalConversationMessage(
        activeAccountInfo: widget.activeAccountInfo,
        localConversationRecordKey: localConversationRecordKey,
        remoteIdentityPublicKey: remoteIdentityPublicKey,
        message: protoMessage);

    ref.invalidate(activeConversationMessagesProvider);
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final protoMessage = proto.Message()
      ..author = widget.activeAccountInfo.localAccount.identityMaster
          .identityPublicTypedKey()
          .toProto()
      ..timestamp = (await eventualVeilid.future).now().toInt64()
      ..text = message.text;
    //..signature = signature;

    await _addMessage(protoMessage);
  }

  void _handleAttachmentPressed() {
    //
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = makeChatTheme(scale, textTheme);

    final activeChatCubit = context.watch<ActiveChatCubit>();
    final contactListCubit = context.watch<ContactListCubit>();

    final activeChatContactKey = activeChatCubit.state;
    if (activeChatContactKey == null) {
      return const NoConversationWidget();
    }
    return contactListCubit.state.builder((context, contactList) {
      
      // Get active chat contact profile
      final activeChatContactIdx = contactList.indexWhere(
          (c) => activeChatContactKey == c.remoteConversationRecordKey);
      late final proto.Contact activeChatContact;
      if (activeChatContactIdx == -1) {
        activeChatCubit.setActiveChat(null);
        return const NoConversationWidget();
      } else {
        activeChatContact = contactList[activeChatContactIdx];
      }
      final contactName = activeChatContact.editedProfile.name;

      // Make a messages cubit for this conversation
      xxx

      final protoMessages =
          ref.watch(activeConversationMessagesProvider).asData?.value;
      if (protoMessages == null) {
        return waitingPage(context);
      }
      final messages = <types.Message>[];
      for (final protoMessage in protoMessages) {
        final message = protoMessageToMessage(protoMessage);
        messages.insert(0, message);
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
                              child: Text(contactName,
                                  textAlign: TextAlign.start,
                                  style: textTheme.titleMedium),
                            )),
                        const Spacer(),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              context
                                  .read<ActiveChatCubit>()
                                  .setActiveChat(null);
                            }).paddingLTRB(16, 0, 16, 0)
                      ]),
                    ),
                    Expanded(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(),
                        child: Chat(
                          theme: chatTheme,
                          messages: messages,
                          //onAttachmentPressed: _handleAttachmentPressed,
                          //onMessageTap: _handleMessageTap,
                          //onPreviewDataFetched: _handlePreviewDataFetched,

                          onSendPressed: (message) {
                            unawaited(_handleSendPressed(message));
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
    });
  }
}
