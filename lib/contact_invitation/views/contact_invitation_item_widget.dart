import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../contact_invitation.dart';

class ContactInvitationItemWidget extends StatelessWidget {
  const ContactInvitationItemWidget(
      {required this.contactInvitationRecord,
      required this.disabled,
      super.key});

  final proto.ContactInvitationRecord contactInvitationRecord;
  final bool disabled;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<proto.ContactInvitationRecord>(
          'contactInvitationRecord', contactInvitationRecord))
      ..add(DiagnosticsProperty<bool>('disabled', disabled));
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    // final remoteConversationKey =
    //     contact.remoteConversationRecordKey.toVeilid();

    const selected =
        false; // xxx: eventually when we have selectable invitations:
    // activeContactCubit.state == remoteConversationRecordKey;

    final tileDisabled =
        disabled || context.watch<ContactInvitationListCubit>().isBusy;

    return SliderTile(
      key: ObjectKey(contactInvitationRecord),
      disabled: tileDisabled,
      selected: selected,
      tileScale: ScaleKind.primary,
      title: contactInvitationRecord.message.isEmpty
          ? translate('contact_list.invitation')
          : contactInvitationRecord.message,
      icon: Icons.person_add,
      onTap: () async {
        if (!context.mounted) {
          return;
        }
        await ContactInvitationDisplayDialog.show(
            context: context,
            message: contactInvitationRecord.message,
            create: (context) => InvitationGeneratorCubit.value(
                Uint8List.fromList(contactInvitationRecord.invitation)));
      },
      endActions: [
        SliderTileAction(
          icon: Icons.delete,
          label: translate('button.delete'),
          actionScale: ScaleKind.tertiary,
          onPressed: (context) async {
            final contactInvitationListCubit =
                context.read<ContactInvitationListCubit>();
            await contactInvitationListCubit.deleteInvitation(
                accepted: false,
                contactRequestInboxRecordKey: contactInvitationRecord
                    .contactRequestInbox.recordKey
                    .toVeilid());
          },
        )
      ],
    );
  }
}
