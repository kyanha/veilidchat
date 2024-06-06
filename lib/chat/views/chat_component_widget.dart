import 'dart:math';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat_list/chat_list.dart';
import '../../theme/theme.dart';
import '../chat.dart';

const onEndReachedThreshold = 0.75;

class ChatComponentWidget extends StatelessWidget {
  const ChatComponentWidget._({required super.key});

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

        final avconversation = context.select<ActiveConversationsBlocMapCubit,
                AsyncValue<ActiveConversationState>?>(
            (x) => x.state[localConversationRecordKey]);
        if (avconversation == null) {
          return waitingPage();
        }

        final activeConversationState = avconversation.asData?.value;
        if (activeConversationState == null) {
          return avconversation.buildNotData();
        }

        // Get the messages cubit
        final messagesCubit = context.select<
                ActiveSingleContactChatBlocMapCubit,
                SingleContactMessagesCubit?>(
            (x) => x.tryOperate(localConversationRecordKey,
                closure: (cubit) => cubit));
        if (messagesCubit == null) {
          return waitingPage();
        }

        // Make chat component state
        return BlocProvider(
            create: (context) => ChatComponentCubit.singleContact(
                  activeAccountInfo: activeAccountInfo,
                  accountRecordInfo: accountRecordInfo,
                  activeConversationState: activeConversationState,
                  messagesCubit: messagesCubit,
                ),
            child: ChatComponentWidget._(key: key));
      });

  /////////////////////////////////////////////////////////////////////

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
    print(
        '_handlePageForward: messagesState.length=${messageWindow.length} messagesState.windowTail=${messageWindow.windowTail} messagesState.windowCount=${messageWindow.windowCount} ScrollNotification=$notification');

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
    print(
        '_handlePageBackward: messagesState.length=${messageWindow.length} messagesState.windowTail=${messageWindow.windowTail} messagesState.windowCount=${messageWindow.windowCount} ScrollNotification=$notification');

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = makeChatTheme(scale, textTheme);

    // Get the enclosing chat component cubit that contains our state
    // (created by ChatComponentWidget.builder())
    final chatComponentCubit = context.watch<ChatComponentCubit>();
    final chatComponentState = chatComponentCubit.state;

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
                            child: Text(title,
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
                      child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (chatComponentCubit.scrollOffset != 0) {
                              return false;
                            }

                            if (!isFirstPage &&
                                notification.metrics.pixels <=
                                    ((notification.metrics.maxScrollExtent -
                                                notification
                                                    .metrics.minScrollExtent) *
                                            (1.0 - onEndReachedThreshold) +
                                        notification.metrics.minScrollExtent)) {
                              //
                              final scrollOffset = (notification
                                          .metrics.maxScrollExtent -
                                      notification.metrics.minScrollExtent) *
                                  (1.0 - onEndReachedThreshold);

                              chatComponentCubit.scrollOffset = scrollOffset;

                              //
                              singleFuture(chatComponentState.chatKey,
                                  () async {
                                await _handlePageForward(chatComponentCubit,
                                    messageWindow, notification);
                              });
                            } else if (!isLastPage &&
                                notification.metrics.pixels >=
                                    ((notification.metrics.maxScrollExtent -
                                                notification
                                                    .metrics.minScrollExtent) *
                                            onEndReachedThreshold +
                                        notification.metrics.minScrollExtent)) {
                              //
                              final scrollOffset = -(notification
                                          .metrics.maxScrollExtent -
                                      notification.metrics.minScrollExtent) *
                                  (1.0 - onEndReachedThreshold);

                              chatComponentCubit.scrollOffset = scrollOffset;
                              //
                              singleFuture(chatComponentState.chatKey,
                                  () async {
                                await _handlePageBackward(chatComponentCubit,
                                    messageWindow, notification);
                              });
                            }
                            return false;
                          },
                          child: Chat(
                              key: chatComponentState.chatKey,
                              theme: chatTheme,
                              messages: messageWindow.window.toList(),
                              scrollToBottomOnSend: isFirstPage,
                              scrollController:
                                  chatComponentState.scrollController,
                              // isLastPage: isLastPage,
                              // onEndReached: () async {
                              //   await _handlePageBackward(
                              //       chatComponentCubit, messageWindow);
                              // },
                              //onEndReachedThreshold: onEndReachedThreshold,
                              //onAttachmentPressed: _handleAttachmentPressed,
                              //onMessageTap: _handleMessageTap,
                              //onPreviewDataFetched: _handlePreviewDataFetched,
                              onSendPressed: (pt) =>
                                  _handleSendPressed(chatComponentCubit, pt),
                              //showUserAvatars: false,
                              //showUserNames: true,
                              user: chatComponentState.localUser,
                              emptyState: const EmptyChatWidget())),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
