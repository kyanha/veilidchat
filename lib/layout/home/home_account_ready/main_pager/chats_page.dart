import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../chat_list/chat_list.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      const ChatSingleContactListWidget().expanded(),
    ]);
  }
}
