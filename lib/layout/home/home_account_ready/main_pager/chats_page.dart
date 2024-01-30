import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

import '../../../../proto/proto.dart' as proto;
import '../../../account_manager/account_manager.dart';
import '../../../tools/tools.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);
    final chatList =
        ref.watch(fetchChatListProvider).asData?.value ?? const IListConst([]);

    return Column(children: <Widget>[
      if (chatList.isNotEmpty)
        ChatSingleContactListWidget(
                contactList: contactList, chatList: chatList)
            .expanded(),
      if (chatList.isEmpty) const EmptyChatListWidget().expanded(),
    ]);
}
