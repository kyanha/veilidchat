import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/theme.dart';

Widget newChatBottomSheetBuilder(
    BuildContext sheetContext, BuildContext context) {
  //final theme = Theme.of(sheetContext);
  //final scale = theme.extension<ScaleScheme>()!;

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
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        'Group and custom chat functionality is not available yet')
                  ]).paddingAll(16))));
}
