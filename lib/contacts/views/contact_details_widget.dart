import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../proto/proto.dart' as proto;
import '../contacts.dart';

class ContactDetailsWidget extends StatefulWidget {
  const ContactDetailsWidget({required this.contact, super.key});
  final proto.Contact contact;

  @override
  State<ContactDetailsWidget> createState() => _ContactDetailsWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<proto.Contact>('contact', contact));
  }
}

class _ContactDetailsWidgetState extends State<ContactDetailsWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      child: EditContactForm(
          formKey: GlobalKey(),
          contact: widget.contact,
          onSubmit: (fbs) async {
            final contactList = context.read<ContactListCubit>();
            await contactList.updateContactFields(
                localConversationRecordKey:
                    widget.contact.localConversationRecordKey.toVeilid(),
                nickname: fbs.currentState
                    ?.value[EditContactForm.formFieldNickname] as String,
                notes: fbs.currentState?.value[EditContactForm.formFieldNotes]
                    as String,
                showAvailability: fbs.currentState
                    ?.value[EditContactForm.formFieldShowAvailability] as bool);
          }));
}
