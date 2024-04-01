import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../chat/chat.dart';
import '../../../tools/tools.dart';

class HomeAccountReadyChat extends StatefulWidget {
  const HomeAccountReadyChat({super.key});

  @override
  HomeAccountReadyChatState createState() => HomeAccountReadyChatState();
}

class HomeAccountReadyChatState extends State<HomeAccountReadyChat> {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.normal);
    });
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  Widget buildChatComponent(BuildContext context) {
    final activeChatRemoteConversationKey =
        context.watch<ActiveChatCubit>().state;
    if (activeChatRemoteConversationKey == null) {
      return const EmptyChatWidget();
    }
    return ChatComponent.builder(
        remoteConversationRecordKey: activeChatRemoteConversationKey);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
        child: buildChatComponent(context),
      ));
}
