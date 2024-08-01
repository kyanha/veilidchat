import 'package:async_tools/async_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../chat/cubits/active_chat_cubit.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../chat_list.dart';

class ChatSingleContactItemWidget extends StatelessWidget {
  const ChatSingleContactItemWidget({
    required proto.Contact contact,
    bool disabled = false,
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
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final activeChatCubit = context.watch<ActiveChatCubit>();
    final localConversationRecordKey =
        _contact.localConversationRecordKey.toVeilid();
    final selected = activeChatCubit.state == localConversationRecordKey;

    final name = _contact.nameOrNickname;
    final title = _contact.displayName;
    final subtitle = _contact.profile.status;

    final avatar = AvatarWidget(
      name: name,
      size: 34,
      borderColor: _disabled
          ? scale.grayScale.primaryText
          : scale.secondaryScale.primaryText,
      foregroundColor: _disabled
          ? scale.grayScale.primaryText
          : scale.secondaryScale.primaryText,
      backgroundColor:
          _disabled ? scale.grayScale.primary : scale.secondaryScale.primary,
      scaleConfig: scaleConfig,
      textStyle: theme.textTheme.titleLarge!,
    );

    return SliderTile(
      key: ObjectKey(_contact),
      disabled: _disabled,
      selected: selected,
      tileScale: ScaleKind.secondary,
      title: title,
      subtitle: subtitle,
      leading: avatar,
      trailing: AvailabilityWidget(availability: _contact.profile.availability),
      onTap: () {
        singleFuture(activeChatCubit, () async {
          activeChatCubit.setActiveChat(localConversationRecordKey);
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
                  localConversationRecordKey: localConversationRecordKey);
            })
      ],
    );
  }
}
