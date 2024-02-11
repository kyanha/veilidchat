import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../chat/chat.dart';
import '../../../tools/tools.dart';

class ChatOnlyPage extends StatefulWidget {
  const ChatOnlyPage({super.key});

  @override
  ChatOnlyPageState createState() => ChatOnlyPageState();
}

class ChatOnlyPageState extends State<ChatOnlyPage>
    with TickerProviderStateMixin {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
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
