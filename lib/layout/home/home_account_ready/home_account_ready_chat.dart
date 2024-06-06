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
    super.dispose();
  }

  Widget buildChatComponent(BuildContext context) {
    final activeChatLocalConversationKey =
        context.watch<ActiveChatCubit>().state;
    if (activeChatLocalConversationKey == null) {
      return const NoConversationWidget();
    }
    return ChatComponentWidget.builder(
        localConversationRecordKey: activeChatLocalConversationKey,
        key: ValueKey(activeChatLocalConversationKey));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: buildChatComponent(context),
      );
}
