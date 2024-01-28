import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../../account_manager/account_manager.dart';
import '../../../../proto/proto.dart' as proto;
import '../../../../theme/theme.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
  });

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    final records = widget.account.contactInvitationRecords;

    final contactInvitationRecordList =
        ref.watch(fetchContactInvitationRecordsProvider).asData?.value ??
            const IListConst([]);
    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    return SizedBox(
        child: Column(children: <Widget>[
      if (contactInvitationRecordList.isNotEmpty)
        ExpansionTile(
          tilePadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          backgroundColor: scale.primaryScale.border,
          collapsedBackgroundColor: scale.primaryScale.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            translate('account_page.contact_invitations'),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium!
                .copyWith(color: scale.primaryScale.subtleText),
          ),
          initiallyExpanded: true,
          children: [
            ContactInvitationListWidget(
                contactInvitationRecordList: contactInvitationRecordList)
          ],
        ).paddingLTRB(8, 0, 8, 8),
      ContactListWidget(contactList: contactList).expanded(),
    ]));
  }
}
