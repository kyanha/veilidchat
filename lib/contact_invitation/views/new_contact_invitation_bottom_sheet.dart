import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/theme.dart';
import 'paste_invitation_dialog.dart';
import 'scan_invitation_dialog.dart';
import 'create_invitation_dialog.dart';

Widget newContactInvitationBottomSheetBuilder(
    BuildContext sheetContext, BuildContext context) {
  final theme = Theme.of(sheetContext);
  final textTheme = theme.textTheme;
  final scale = theme.extension<ScaleScheme>()!;

  return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (ke) {
        if (ke.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(sheetContext);
        }
      },
      child: SizedBox(
          height: 200,
          child: Column(children: [
            Text(translate('accounts_menu.invite_contact'),
                    style: textTheme.titleMedium)
                .paddingAll(8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(children: [
                IconButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await CreateInvitationDialog.show(context);
                    },
                    iconSize: 64,
                    icon: const Icon(Icons.contact_page),
                    color: scale.primaryScale.background),
                Text(translate('accounts_menu.create_invite'))
              ]),
              Column(children: [
                IconButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await ScanInvitationDialog.show(context);
                    },
                    iconSize: 64,
                    icon: const Icon(Icons.qr_code_scanner),
                    color: scale.primaryScale.background),
                Text(translate('accounts_menu.scan_invite'))
              ]),
              Column(children: [
                IconButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await PasteInvitationDialog.show(context);
                    },
                    iconSize: 64,
                    icon: const Icon(Icons.paste),
                    color: scale.primaryScale.background),
                Text(translate('accounts_menu.paste_invite'))
              ])
            ]).expanded()
          ])));
}
