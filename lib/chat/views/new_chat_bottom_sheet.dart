import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/theme.dart';
import '../../tools/tools.dart';

Widget newChatBottomSheetBuilder(
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
          title: translate('add_chat_sheet.new_chat'),
          child: SizedBox(
              height: 160,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        'Group and custom chat functionality is not available yet')
                    // Column(children: [
                    //   IconButton(
                    //       onPressed: () async {
                    //         Navigator.pop(sheetContext);
                    //         await CreateInvitationDialog.show(context);
                    //       },
                    //       iconSize: 64,
                    //       icon: const Icon(Icons.contact_page),
                    //       color: scale.primaryScale.background),
                    //   Text(
                    //     translate('accounts_menu.create_invite'),
                    //   )
                    // ]),
                    // Column(children: [
                    //   IconButton(
                    //       onPressed: () async {
                    //         Navigator.pop(sheetContext);
                    //         await ScanInvitationDialog.show(context);
                    //       },
                    //       iconSize: 64,
                    //       icon: const Icon(Icons.qr_code_scanner),
                    //       color: scale.primaryScale.background),
                    //   Text(
                    //     translate('accounts_menu.scan_invite'),
                    //   )
                    // ]),
                    // Column(children: [
                    //   IconButton(
                    //       onPressed: () async {
                    //         Navigator.pop(sheetContext);
                    //         await PasteInvitationDialog.show(context);
                    //       },
                    //       iconSize: 64,
                    //       icon: const Icon(Icons.paste),
                    //       color: scale.primaryScale.background),
                    //   Text(
                    //     translate('accounts_menu.paste_invite'),
                    //   )
                    // ])
                  ]).paddingAll(16))));
}
