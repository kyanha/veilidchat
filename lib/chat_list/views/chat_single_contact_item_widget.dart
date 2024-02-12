import 'package:async_tools/async_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../chat/cubits/active_chat_cubit.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../chat_list.dart';

class ChatSingleContactItemWidget extends StatelessWidget {
  const ChatSingleContactItemWidget({required proto.Contact contact, super.key})
      : _contact = contact;

  final proto.Contact _contact;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    final activeChatCubit = context.watch<ActiveChatCubit>();
    final remoteConversationRecordKey =
        _contact.remoteConversationRecordKey.toVeilid();
    final selected = activeChatCubit.state == remoteConversationRecordKey;

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
            color: scale.tertiaryScale.subtleBorder,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
        child: Slidable(
            key: ObjectKey(_contact),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                    onPressed: (context) async {
                      final chatListCubit = context.read<ChatListCubit>();
                      await chatListCubit.deleteChat(
                          remoteConversationRecordKey:
                              remoteConversationRecordKey);
                    },
                    backgroundColor: scale.tertiaryScale.background,
                    foregroundColor: scale.tertiaryScale.text,
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
                onTap: () {
                  final activeConversationsCubit =
                      context.read<ActiveConversationsCubit>();
                  singleFuture(activeChatCubit, () async {
                    await activeConversationsCubit.addConversation(
                        contact: _contact);
                    activeChatCubit.setActiveChat(remoteConversationRecordKey);
                  });
                },
                title: Text(_contact.editedProfile.name),

                /// xxx show last message here
                subtitle: (_contact.editedProfile.pronouns.isNotEmpty)
                    ? Text(_contact.editedProfile.pronouns)
                    : null,
                iconColor: scale.tertiaryScale.background,
                textColor: scale.tertiaryScale.text,
                selected: selected,
                //Text(Timestamp.fromInt64(contactInvitationRecord.expiration) / ),
                leading: const Icon(Icons.chat))));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<proto.Contact>('contact', _contact));
  }
}
