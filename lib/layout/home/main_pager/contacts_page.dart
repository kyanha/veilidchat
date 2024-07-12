import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../contact_invitation/contact_invitation.dart';
import '../../../contacts/contacts.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({
    super.key,
  });

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final textTheme = theme.textTheme;
    // final scale = theme.extension<ScaleScheme>()!;
    // final scaleConfig = theme.extension<ScaleConfig>()!;

    final cilState = context.watch<ContactInvitationListCubit>().state;
    final cilBusy = cilState.busy;
    final contactInvitationRecordList =
        cilState.state.asData?.value.map((x) => x.value).toIList() ??
            const IListConst([]);

    final ciState = context.watch<ContactListCubit>().state;
    final ciBusy = ciState.busy;
    final contactList =
        ciState.state.asData?.value.map((x) => x.value).toIList() ??
            const IListConst([]);

    return CustomScrollView(slivers: [
      if (contactInvitationRecordList.isNotEmpty)
        SliverPadding(
            padding: const EdgeInsets.only(bottom: 8),
            sliver: ContactInvitationListWidget(
                contactInvitationRecordList: contactInvitationRecordList,
                disabled: cilBusy)),
      ContactListWidget(contactList: contactList, disabled: ciBusy),
    ]).paddingLTRB(8, 0, 8, 8);
  }
}
