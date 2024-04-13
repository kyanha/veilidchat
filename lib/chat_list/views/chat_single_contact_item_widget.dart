import 'package:async_tools/async_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../chat/cubits/active_chat_cubit.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../chat_list.dart';

class ChatSingleContactItemWidget extends StatelessWidget {
  const ChatSingleContactItemWidget({
    required proto.Contact contact,
    required bool disabled,
    super.key,
  })  : _contact = contact,
        _disabled = disabled;

  final proto.Contact _contact;
  final bool _disabled;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final activeChatCubit = context.watch<ActiveChatCubit>();
    final remoteConversationRecordKey =
        _contact.remoteConversationRecordKey.toVeilid();
    final selected = activeChatCubit.state == remoteConversationRecordKey;

    return SliderTile(
      key: ObjectKey(_contact),
      disabled: _disabled,
      selected: selected,
      tileScale: ScaleKind.secondary,
      title: _contact.editedProfile.name,
      subtitle: _contact.editedProfile.pronouns,
      icon: Icons.chat,
      onTap: () {
        singleFuture(activeChatCubit, () async {
          activeChatCubit.setActiveChat(remoteConversationRecordKey);
        });
      },
      endActions: [
        SliderTileAction(
            icon: Icons.delete,
            label: translate('button.delete'),
            actionScale: ScaleKind.tertiary,
            onPressed: (context) async {
              final chatListCubit = context.read<ChatListCubit>();
              await chatListCubit.deleteChat(
                  remoteConversationRecordKey: remoteConversationRecordKey);
            })
      ],
    );
  }
}
