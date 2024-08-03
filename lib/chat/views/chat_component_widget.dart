import 'dart:convert';
import 'dart:math';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../conversation/conversation.dart';
import '../../notifications/notifications.dart';
import '../../theme/theme.dart';
import '../chat.dart';

const onEndReachedThreshold = 0.75;

class ChatComponentWidget extends StatelessWidget {
  const ChatComponentWidget({
    required super.key,
    required TypedKey localConversationRecordKey,
    required void Function() onCancel,
    required void Function() onClose,
  })  : _localConversationRecordKey = localConversationRecordKey,
        _onCancel = onCancel,
        _onClose = onClose;

  /////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final scale = theme.extension<ScaleScheme>()!;
    // final scaleConfig = theme.extension<ScaleConfig>()!;
    // final textTheme = theme.textTheme;

    // Get the account info
    final accountInfo = context.watch<AccountInfoCubit>().state;

    // Get the account record cubit
    final accountRecordCubit = context.read<AccountRecordCubit>();

    // Get the contact list cubit
    final contactListCubit = context.watch<ContactListCubit>();

    // Get the active conversation cubit
    final activeConversationCubit = context
        .select<ActiveConversationsBlocMapCubit, ActiveConversationCubit?>(
            (x) => x.tryOperateSync(_localConversationRecordKey,
                closure: (cubit) => cubit));
    if (activeConversationCubit == null) {
      return waitingPage(onCancel: _onCancel);
    }

    // Get the messages cubit
    final messagesCubit = context.select<ActiveSingleContactChatBlocMapCubit,
            SingleContactMessagesCubit?>(
        (x) => x.tryOperateSync(_localConversationRecordKey,
            closure: (cubit) => cubit));
    if (messagesCubit == null) {
      return waitingPage(onCancel: _onCancel);
    }

    // Make chat component state
    return BlocProvider(
        key: key,
        create: (context) => ChatComponentCubit.singleContact(
              accountInfo: accountInfo,
              accountRecordCubit: accountRecordCubit,
              contactListCubit: contactListCubit,
              activeConversationCubit: activeConversationCubit,
              messagesCubit: messagesCubit,
            ),
        child: Builder(builder: _buildChatComponent));
  }

  /////////////////////////////////////////////////////////////////////

  Widget _buildChatComponent(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;
    final textTheme = theme.textTheme;
    final chatTheme = makeChatTheme(scale, scaleConfig, textTheme);
    final errorChatTheme = (ChatThemeEditor(chatTheme)
          ..inputTextColor = scale.errorScale.primary
          ..sendButtonIcon = Image.asset(
            'assets/icon-send.png',
            color: scale.errorScale.primary,
            package: 'flutter_chat_ui',
          ))
        .commit();

    // Get the enclosing chat component cubit that contains our state
    // (created by ChatComponentWidget.builder())
    final chatComponentCubit = context.watch<ChatComponentCubit>();
    final chatComponentState = chatComponentCubit.state;

    final localUser = chatComponentState.localUser;
    if (localUser == null) {
      return const EmptyChatWidget();
    }

    final messageWindow = chatComponentState.messageWindow.asData?.value;
    if (messageWindow == null) {
      return chatComponentState.messageWindow.buildNotData();
    }
    final isLastPage = messageWindow.windowStart == 0;
    final isFirstPage = messageWindow.windowEnd == messageWindow.length - 1;
    final title = chatComponentState.title;

    if (chatComponentCubit.scrollOffset != 0) {
      chatComponentState.scrollController.position.correctPixels(
          chatComponentState.scrollController.position.pixels +
              chatComponentCubit.scrollOffset);

      chatComponentCubit.scrollOffset = 0;
    }

    return Column(
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
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  child: Text(title,
                      textAlign: TextAlign.start,
                      style: textTheme.titleMedium!
                          .copyWith(color: scale.primaryScale.borderText)),
                )),
            const Spacer(),
            IconButton(
                    icon:
                        Icon(Icons.close, color: scale.primaryScale.borderText),
                    onPressed: _onClose)
                .paddingLTRB(16, 0, 16, 0)
          ]),
        ),
        DecoratedBox(
            decoration:
                BoxDecoration(color: scale.primaryScale.subtleBackground),
            child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (chatComponentCubit.scrollOffset != 0) {
                    return false;
                  }

                  if (!isFirstPage &&
                      notification.metrics.pixels <=
                          ((notification.metrics.maxScrollExtent -
                                      notification.metrics.minScrollExtent) *
                                  (1.0 - onEndReachedThreshold) +
                              notification.metrics.minScrollExtent)) {
                    //
                    final scrollOffset = (notification.metrics.maxScrollExtent -
                            notification.metrics.minScrollExtent) *
                        (1.0 - onEndReachedThreshold);

                    chatComponentCubit.scrollOffset = scrollOffset;

                    //
                    singleFuture(chatComponentState.chatKey, () async {
                      await _handlePageForward(
                          chatComponentCubit, messageWindow, notification);
                    });
                  } else if (!isLastPage &&
                      notification.metrics.pixels >=
                          ((notification.metrics.maxScrollExtent -
                                      notification.metrics.minScrollExtent) *
                                  onEndReachedThreshold +
                              notification.metrics.minScrollExtent)) {
                    //
                    final scrollOffset =
                        -(notification.metrics.maxScrollExtent -
                                notification.metrics.minScrollExtent) *
                            (1.0 - onEndReachedThreshold);

                    chatComponentCubit.scrollOffset = scrollOffset;
                    //
                    singleFuture(chatComponentState.chatKey, () async {
                      await _handlePageBackward(
                          chatComponentCubit, messageWindow, notification);
                    });
                  }
                  return false;
                },
                child: ValueListenableBuilder(
                    valueListenable: chatComponentState.textEditingController,
                    builder: (context, textEditingValue, __) {
                      final messageIsValid =
                          utf8.encode(textEditingValue.text).lengthInBytes <
                              2048;

                      return Chat(
                              key: chatComponentState.chatKey,
                              theme:
                                  messageIsValid ? chatTheme : errorChatTheme,
                              messages: messageWindow.window.toList(),
                              scrollToBottomOnSend: isFirstPage,
                              scrollController:
                                  chatComponentState.scrollController,
                              inputOptions: InputOptions(
                                  inputClearMode: messageIsValid
                                      ? InputClearMode.always
                                      : InputClearMode.never,
                                  textEditingController:
                                      chatComponentState.textEditingController),
                              // isLastPage: isLastPage,
                              // onEndReached: () async {
                              //   await _handlePageBackward(
                              //       chatComponentCubit, messageWindow);
                              // },
                              //onEndReachedThreshold: onEndReachedThreshold,
                              //onAttachmentPressed: _handleAttachmentPressed,
                              //onMessageTap: _handleMessageTap,
                              //onPreviewDataFetched: _handlePreviewDataFetched,
                              onSendPressed: (pt) {
                                try {
                                  if (!messageIsValid) {
                                    context.read<NotificationsCubit>().error(
                                        text:
                                            translate('chat.message_too_long'));
                                    return;
                                  }
                                  _handleSendPressed(chatComponentCubit, pt);
                                } on FormatException {
                                  context.read<NotificationsCubit>().error(
                                      text: translate('chat.message_too_long'));
                                }
                              },
                              listBottomWidget: messageIsValid
                                  ? null
                                  : Text(translate('chat.message_too_long'),
                                          style: TextStyle(
                                              color: scale.errorScale.primary))
                                      .toCenter(),
                              //showUserAvatars: false,
                              //showUserNames: true,
                              user: localUser,
                              emptyState: const EmptyChatWidget())
                          .paddingLTRB(0, 2, 0, 0);
                    }))).expanded(),
      ],
    );
  }

  void _handleSendPressed(
      ChatComponentCubit chatComponentCubit, types.PartialText message) {
    final text = message.text;

    if (text.startsWith('/')) {
      chatComponentCubit.runCommand(text);
      return;
    }

    chatComponentCubit.sendMessage(message);
  }

  // void _handleAttachmentPressed() async {
  //   //
  // }

  Future<void> _handlePageForward(
      ChatComponentCubit chatComponentCubit,
      WindowState<types.Message> messageWindow,
      ScrollNotification notification) async {
    debugPrint(
        '_handlePageForward: messagesState.length=${messageWindow.length} '
        'messagesState.windowTail=${messageWindow.windowTail} '
        'messagesState.windowCount=${messageWindow.windowCount} '
        'ScrollNotification=$notification');

    // Go forward a page
    final tail = min(messageWindow.length,
            messageWindow.windowTail + (messageWindow.windowCount ~/ 4)) %
        messageWindow.length;

    // Set follow
    final follow = messageWindow.length == 0 ||
        tail == 0; // xxx incorporate scroll position

    // final scrollOffset = (notification.metrics.maxScrollExtent -
    //         notification.metrics.minScrollExtent) *
    //     (1.0 - onEndReachedThreshold);

    // chatComponentCubit.scrollOffset = scrollOffset;

    await chatComponentCubit.setWindow(
        tail: tail, count: messageWindow.windowCount, follow: follow);

    // chatComponentCubit.state.scrollController.position.jumpTo(
    //     chatComponentCubit.state.scrollController.offset + scrollOffset);

    //chatComponentCubit.scrollOffset = 0;
  }

  Future<void> _handlePageBackward(
    ChatComponentCubit chatComponentCubit,
    WindowState<types.Message> messageWindow,
    ScrollNotification notification,
  ) async {
    debugPrint(
        '_handlePageBackward: messagesState.length=${messageWindow.length} '
        'messagesState.windowTail=${messageWindow.windowTail} '
        'messagesState.windowCount=${messageWindow.windowCount} '
        'ScrollNotification=$notification');

    // Go back a page
    final tail = max(
        messageWindow.windowCount,
        (messageWindow.windowTail - (messageWindow.windowCount ~/ 4)) %
            messageWindow.length);

    // Set follow
    final follow = messageWindow.length == 0 ||
        tail == 0; // xxx incorporate scroll position

    // final scrollOffset = -(notification.metrics.maxScrollExtent -
    //         notification.metrics.minScrollExtent) *
    //     (1.0 - onEndReachedThreshold);

    // chatComponentCubit.scrollOffset = scrollOffset;

    await chatComponentCubit.setWindow(
        tail: tail, count: messageWindow.windowCount, follow: follow);

    // chatComponentCubit.scrollOffset = scrollOffset;

    // chatComponentCubit.state.scrollController.position.jumpTo(
    //     chatComponentCubit.state.scrollController.offset + scrollOffset);

    //chatComponentCubit.scrollOffset = 0;
  }

  ////////////////////////////////////////////////////////////////////////////
  final TypedKey _localConversationRecordKey;
  final void Function() _onCancel;
  final void Function() _onClose;
}
