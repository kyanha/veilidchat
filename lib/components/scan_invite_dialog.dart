import 'dart:async';
import 'dart:typed_data';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../tools/tools.dart';
import 'invite_dialog.dart';

class ScanInviteDialog extends ConsumerStatefulWidget {
  const ScanInviteDialog({super.key});

  @override
  ScanInviteDialogState createState() => ScanInviteDialogState();

  static Future<void> show(BuildContext context) async {
    await showStyledDialog<void>(
        context: context,
        title: translate('scan_invite_dialog.title'),
        child: const ScanInviteDialog());
  }
}

class ScanInviteDialogState extends ConsumerState<ScanInviteDialog> {
  // final _pasteTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _onPasteChanged(
  //     String text,
  //     Future<void> Function({
  //       required Uint8List inviteData,
  //     }) validateInviteData) async {
  //   final lines = text.split('\n');
  //   if (lines.isEmpty) {
  //     return;
  //   }

  //   var firstline =
  //       lines.indexWhere((element) => element.contains('BEGIN VEILIDCHAT'));
  //   firstline += 1;

  //   var lastline =
  //       lines.indexWhere((element) => element.contains('END VEILIDCHAT'));
  //   if (lastline == -1) {
  //     lastline = lines.length;
  //   }
  //   if (lastline <= firstline) {
  //     return;
  //   }
  //   final inviteDataBase64 = lines.sublist(firstline, lastline).join();
  //   final inviteData = base64UrlNoPadDecode(inviteDataBase64);

  //   await validateInviteData(inviteData: inviteData);
  // }

  void onValidationCancelled() {
    // _pasteTextController.clear();
  }

  void onValidationSuccess() {
    //_pasteTextController.clear();
  }
  void onValidationFailed() {
    //_pasteTextController.clear();
  }
  bool inviteControlIsValid() => false; // _pasteTextController.text.isNotEmpty;

  Widget buildInviteControl(
      BuildContext context,
      InviteDialogState dialogState,
      Future<void> Function({required Uint8List inviteData})
          validateInviteData) {
    final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;
    //final height = MediaQuery.of(context).size.height;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
        translate('scan_invite_dialog.scan_invite_here'),
      ).paddingLTRB(0, 0, 0, 8),
      // Container(
      //     constraints: const BoxConstraints(maxHeight: 200),
      //     child: TextField(
      //       enabled: !dialogState.isValidating,
      //       onChanged: (text) => _onPasteChanged(text, validateInviteData),
      //       style: textTheme.labelSmall!
      //           .copyWith(fontFamily: 'Victor Mono', fontSize: 11),
      //       keyboardType: TextInputType.multiline,
      //       maxLines: null,
      //       controller: _pasteTextController,
      //       decoration: const InputDecoration(
      //         border: OutlineInputBorder(),
      //         hintText: '--- BEGIN VEILIDCHAT CONTACT INVITE ----\n'
      //             'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n'
      //             '---- END VEILIDCHAT CONTACT INVITE -----\n',
      //         //labelText: translate('paste_invite_dialog.paste')
      //       ),
      //     )).paddingLTRB(0, 0, 0, 8)
    ]);
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return InviteDialog(
        onValidationCancelled: onValidationCancelled,
        onValidationSuccess: onValidationSuccess,
        onValidationFailed: onValidationFailed,
        inviteControlIsValid: inviteControlIsValid,
        buildInviteControl: buildInviteControl);
  }
}
