import 'package:flutter/material.dart';

import '../chat/chat.dart';
import '../tools/tools.dart';

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

  @override
  Widget build(BuildContext context) => SafeArea(
          child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
        child: buildChatComponent(),
      ));
}
