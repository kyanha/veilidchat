import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../contact_invitation.dart';

class ContactInvitationItemWidget extends StatelessWidget {
  const ContactInvitationItemWidget(
      {required this.contactInvitationRecord, super.key});

  final proto.ContactInvitationRecord contactInvitationRecord;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<proto.ContactInvitationRecord>(
        'contactInvitationRecord', contactInvitationRecord));
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
            color: scale.tertiaryScale.subtleBorder,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
        child: Slidable(
            // Specify a key if the Slidable is dismissible.
            key: ObjectKey(contactInvitationRecord),
            endActionPane: ActionPane(
              // A motion is a widget used to control how the pane animates.
              motion: const DrawerMotion(),

              // A pane can dismiss the Slidable.
              //dismissible: DismissiblePane(onDismissed: () {}),

              // All actions are defined in the children parameter.
              children: [
                // A SlidableAction can have an icon and/or a label.
                SlidableAction(
                    onPressed: (context) async {
                      final contactInvitationListCubit =
                          context.read<ContactInvitationListCubit>();
                      await contactInvitationListCubit.deleteInvitation(
                          accepted: false,
                          contactInvitationRecord: contactInvitationRecord);
                    },
                    backgroundColor: scale.tertiaryScale.background,
                    foregroundColor: scale.tertiaryScale.text,
                    icon: Icons.delete,
                    label: translate('button.delete'),
                    padding: const EdgeInsets.all(2)),
              ],
            ),

            // startActionPane: ActionPane(
            //   motion: const DrawerMotion(),
            //   children: [
            //     SlidableAction(
            //       // An action can be bigger than the others.
            //       flex: 2,
            //       onPressed: (context) => (),
            //       backgroundColor: Color(0xFF7BC043),
            //       foregroundColor: Colors.white,
            //       icon: Icons.archive,
            //       label: 'Archive',
            //     ),
            //     SlidableAction(
            //       onPressed: (context) => (),
            //       backgroundColor: Color(0xFF0392CF),
            //       foregroundColor: Colors.white,
            //       icon: Icons.save,
            //       label: 'Save',
            //     ),
            //   ],
            // ),

            // The child of the Slidable is what the user sees when the
            // component is not dragged.
            child: ListTile(
                //title: Text(translate('contact_list.invitation')),
                onTap: () async {
                  // ignore: use_build_context_synchronously
                  if (!context.mounted) {
                    return;
                  }
                  await showDialog<void>(
                      context: context,
                      builder: (context) => BlocProvider(
                          create: (context) => InvitationGeneratorCubit(
                              Future.value(Uint8List.fromList(
                                  contactInvitationRecord.invitation))),
                          child: ContactInvitationDisplayDialog(
                            message: contactInvitationRecord.message,
                          )));
                },
                title: Text(
                  contactInvitationRecord.message.isEmpty
                      ? translate('contact_list.invitation')
                      : contactInvitationRecord.message,
                  softWrap: true,
                ),
                iconColor: scale.tertiaryScale.background,
                textColor: scale.tertiaryScale.text,
                //Text(Timestamp.fromInt64(contactInvitationRecord.expiration) / ),
                leading: const Icon(Icons.person_add))));
  }
}
