import 'package:flutter/foundation.dart';
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
      {required this.contact, required this.disabled, super.key});

  final proto.Contact contact;
  final bool disabled;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<proto.Contact>('contact', contact))
      ..add(DiagnosticsProperty<bool>('disabled', disabled));
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final remoteConversationKey =
        contact.remoteConversationRecordKey.toVeilid();

    const selected = false; // xxx: eventually when we have selectable contacts:
    // activeContactCubit.state == remoteConversationRecordKey;

    final tileDisabled = disabled || context.watch<ContactListCubit>().isBusy;

    return SliderTile(
      key: ObjectKey(contact),
      disabled: tileDisabled,
      selected: selected,
      tileScale: ScaleKind.primary,
      title: contact.editedProfile.name,
      subtitle: contact.editedProfile.pronouns,
      icon: Icons.person,
      onTap: () async {
        // Start a chat
        final chatListCubit = context.read<ChatListCubit>();

        await chatListCubit.getOrCreateChatSingleContact(
            remoteConversationRecordKey: remoteConversationKey);
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
                  remoteConversationRecordKey: remoteConversationKey);

              // Delete the contact itself
              await contactListCubit.deleteContact(contact: contact);
            })
      ],
    );
  }
}
