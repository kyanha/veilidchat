import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    final remoteConversationKey =
        contact.remoteConversationRecordKey.toVeilid();

    const selected =
        false; // xxx: eventually when we have selectable contacts: activeContactCubit.state == remoteConversationRecordKey;

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
            color: selected
                ? scale.primaryScale.activeElementBackground
                : scale.primaryScale.hoverElementBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
        child: Slidable(
            key: ObjectKey(contact),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                    onPressed: disabled || context.watch<ChatListCubit>().isBusy
                        ? null
                        : (context) async {
                            final contactListCubit =
                                context.read<ContactListCubit>();
                            final chatListCubit = context.read<ChatListCubit>();

                            // Remove any chats for this contact
                            await chatListCubit.deleteChat(
                                remoteConversationRecordKey:
                                    remoteConversationKey);

                            // Delete the contact itself
                            await contactListCubit.deleteContact(
                                contact: contact);
                          },
                    backgroundColor: scale.tertiaryScale.background,
                    foregroundColor: scale.tertiaryScale.appText,
                    icon: Icons.delete,
                    label: translate('button.delete'),
                    padding: const EdgeInsets.all(2)),
                // SlidableAction(
                //   onPressed: (context) => (),
                //   backgroundColor: scale.secondaryScale.background,
                //   foregroundColor: scale.secondaryScale.text,
                //   icon: Icons.edit,
                //   label: 'Edit',
                // ),
              ],
            ),

            // The child of the Slidable is what the user sees when the
            // component is not dragged.
            child: ListTile(
                onTap: disabled || context.watch<ChatListCubit>().isBusy
                    ? null
                    : () async {
                        // Start a chat
                        final chatListCubit = context.read<ChatListCubit>();
                        await chatListCubit.getOrCreateChatSingleContact(
                            remoteConversationRecordKey: remoteConversationKey);
                        // Click over to chats
                        if (context.mounted) {
                          await MainPager.of(context)
                              ?.pageController
                              .animateToPage(1,
                                  duration: 250.ms, curve: Curves.easeInOut);
                        }
                      },
                title: Text(contact.editedProfile.name),
                subtitle: (contact.editedProfile.pronouns.isNotEmpty)
                    ? Text(contact.editedProfile.pronouns)
                    : null,
                iconColor: selected
                    ? scale.primaryScale.appText
                    : scale.primaryScale.subtleText,
                textColor: selected
                    ? scale.primaryScale.appText
                    : scale.primaryScale.subtleText,
                selectedColor: scale.primaryScale.appText,
                leading: const Icon(Icons.person))));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<proto.Contact>('contact', contact));
  }
}
