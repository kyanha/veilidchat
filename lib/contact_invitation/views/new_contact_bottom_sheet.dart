import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/theme.dart';
import 'create_invitation_dialog.dart';
import 'paste_invitation_dialog.dart';
import 'scan_invitation_dialog.dart';

Widget newContactBottomSheetBuilder(
    BuildContext sheetContext, BuildContext context) {
  final theme = Theme.of(sheetContext);
  final scale = theme.extension<ScaleScheme>()!;

  return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (ke) {
        if (ke.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(sheetContext);
        }
      },
      child: styledBottomSheet(
          context: context,
          title: translate('add_contact_sheet.new_contact'),
          child: SizedBox(
              height: 160,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      IconButton(
                          onPressed: () async {
                            Navigator.pop(sheetContext);
                            await CreateInvitationDialog.show(context);
                          },
                          iconSize: 64,
                          icon: const Icon(Icons.contact_page),
                          color: scale.primaryScale.hoverBorder),
                      Text(
                        translate('add_contact_sheet.create_invite'),
                      )
                    ]),
                    Column(children: [
                      IconButton(
                          onPressed: () async {
                            Navigator.pop(sheetContext);
                            await ScanInvitationDialog.show(context);
                          },
                          iconSize: 64,
                          icon: const Icon(Icons.qr_code_scanner),
                          color: scale.primaryScale.hoverBorder),
                      Text(
                        translate('add_contact_sheet.scan_invite'),
                      )
                    ]),
                    Column(children: [
                      IconButton(
                          onPressed: () async {
                            Navigator.pop(sheetContext);
                            await PasteInvitationDialog.show(context);
                          },
                          iconSize: 64,
                          icon: const Icon(Icons.paste),
                          color: scale.primaryScale.hoverBorder),
                      Text(
                        translate('add_contact_sheet.paste_invite'),
                      )
                    ])
                  ]).paddingAll(16))));
}
