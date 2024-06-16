import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../chat_list/chat_list.dart';
import '../../layout/layout.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../contacts.dart';

class ContactItemWidget extends StatelessWidget {
  const ContactItemWidget(
      {required proto.Contact contact, required bool disabled, super.key})
      : _disabled = disabled,
        _contact = contact;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final localConversationRecordKey =
        _contact.localConversationRecordKey.toVeilid();

    const selected = false; // xxx: eventually when we have selectable contacts:
    // activeContactCubit.state == localConversationRecordKey;

    final tileDisabled = _disabled || context.watch<ContactListCubit>().isBusy;

    late final String title;
    late final String subtitle;
    if (_contact.nickname.isNotEmpty) {
      title = _contact.nickname;
      if (_contact.profile.pronouns.isNotEmpty) {
        subtitle = '${_contact.profile.name} (${_contact.profile.pronouns})';
      } else {
        subtitle = _contact.profile.name;
      }
    } else {
      title = _contact.profile.name;
      if (_contact.profile.pronouns.isNotEmpty) {
        subtitle = '(${_contact.profile.pronouns})';
      } else {
        subtitle = '';
      }
    }

    return SliderTile(
      key: ObjectKey(_contact),
      disabled: tileDisabled,
      selected: selected,
      tileScale: ScaleKind.primary,
      title: title,
      subtitle: subtitle,
      icon: Icons.person,
      onTap: () async {
        // Start a chat
        final chatListCubit = context.read<ChatListCubit>();

        await chatListCubit.getOrCreateChatSingleContact(contact: _contact);
        // Click over to chats
        if (context.mounted) {
          await MainPager.of(context)
              ?.pageController
              .animateToPage(1, duration: 250.ms, curve: Curves.easeInOut);
        }
      },
      endActions: [
        SliderTileAction(
            icon: Icons.delete,
            label: translate('button.delete'),
            actionScale: ScaleKind.tertiary,
            onPressed: (context) async {
              final contactListCubit = context.read<ContactListCubit>();
              final chatListCubit = context.read<ChatListCubit>();

              // Remove any chats for this contact
              await chatListCubit.deleteChat(
                  localConversationRecordKey: localConversationRecordKey);

              // Delete the contact itself
              await contactListCubit.deleteContact(
                  localConversationRecordKey: localConversationRecordKey);
            })
      ],
    );
  }

  ////////////////////////////////////////////////////////////////////////////

  final proto.Contact _contact;
  final bool _disabled;
}
