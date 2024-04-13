import 'dart:async';
import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../contact_invitation.dart';

class CreateInvitationDialog extends StatefulWidget {
  const CreateInvitationDialog._({required this.modalContext});

  @override
  CreateInvitationDialogState createState() => CreateInvitationDialogState();

  static Future<void> show(BuildContext context) async {
    await StyledDialog.show<void>(
        context: context,
        title: translate('create_invitation_dialog.title'),
        child: CreateInvitationDialog._(modalContext: context));
  }

  final BuildContext modalContext;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<BuildContext>('modalContext', modalContext));
  }
}

class CreateInvitationDialogState extends State<CreateInvitationDialog> {
  final _messageTextController = TextEditingController(
      text: translate('create_invitation_dialog.connect_with_me'));

  EncryptionKeyType _encryptionKeyType = EncryptionKeyType.none;
  String _encryptionKey = '';
  Timestamp? _expiration;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onNoneEncryptionSelected(bool selected) async {
    setState(() {
      if (selected) {
        _encryptionKeyType = EncryptionKeyType.none;
      }
    });
  }

  Future<void> _onPinEncryptionSelected(bool selected) async {
    final description = translate('create_invitation_dialog.pin_description');
    final pin = await showDialog<String>(
        context: context,
        builder: (context) =>
            EnterPinDialog(reenter: false, description: description));
    if (pin == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    final matchpin = await showDialog<String>(
        context: context,
        builder: (context) => EnterPinDialog(
              reenter: true,
              description: description,
            ));
    if (matchpin == null) {
      return;
    } else if (pin == matchpin) {
      setState(() {
        _encryptionKeyType = EncryptionKeyType.pin;
        _encryptionKey = pin;
      });
    } else {
      if (!mounted) {
        return;
      }
      showErrorToast(
          context, translate('create_invitation_dialog.pin_does_not_match'));
      setState(() {
        _encryptionKeyType = EncryptionKeyType.none;
        _encryptionKey = '';
      });
    }
  }

  Future<void> _onPasswordEncryptionSelected(bool selected) async {
    final description =
        translate('create_invitation_dialog.password_description');
    final password = await showDialog<String>(
        context: context,
        builder: (context) => EnterPasswordDialog(description: description));
    if (password == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    final matchpass = await showDialog<String>(
        context: context,
        builder: (context) => EnterPasswordDialog(
              matchPass: password,
              description: description,
            ));
    if (matchpass == null) {
      return;
    } else if (password == matchpass) {
      setState(() {
        _encryptionKeyType = EncryptionKeyType.password;
        _encryptionKey = password;
      });
    } else {
      if (!mounted) {
        return;
      }
      showErrorToast(context,
          translate('create_invitation_dialog.password_does_not_match'));
      setState(() {
        _encryptionKeyType = EncryptionKeyType.none;
        _encryptionKey = '';
      });
    }
  }

  Future<void> _onGenerateButtonPressed() async {
    final navigator = Navigator.of(context);

    // Start generation
    final contactInvitationListCubit =
        widget.modalContext.read<ContactInvitationListCubit>();

    final generator = contactInvitationListCubit.createInvitation(
        encryptionKeyType: _encryptionKeyType,
        encryptionKey: _encryptionKey,
        message: _messageTextController.text,
        expiration: _expiration);

    await ContactInvitationDisplayDialog.show(
        context: context,
        message: _messageTextController.text,
        create: (context) => InvitationGeneratorCubit(generator));

    navigator.pop();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final maxDialogWidth = min(windowSize.width - 64.0, 800.0 - 64.0);
    final maxDialogHeight = windowSize.height - 64.0;

    final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: maxDialogHeight, maxWidth: maxDialogWidth),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              translate('create_invitation_dialog.message_to_contact'),
            ).paddingAll(8),
            TextField(
              controller: _messageTextController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(128),
              ],
              decoration: InputDecoration(
                  //border: const OutlineInputBorder(),
                  hintText:
                      translate('create_invitation_dialog.enter_message_hint'),
                  labelText: translate('create_invitation_dialog.message')),
            ).paddingAll(8),
            const SizedBox(height: 10),
            Text(translate('create_invitation_dialog.protect_this_invitation'),
                    style: textTheme.labelLarge)
                .paddingAll(8),
            Wrap(spacing: 5, children: [
              ChoiceChip(
                label: Text(translate('create_invitation_dialog.unlocked')),
                selected: _encryptionKeyType == EncryptionKeyType.none,
                onSelected: _onNoneEncryptionSelected,
              ),
              ChoiceChip(
                label: Text(translate('create_invitation_dialog.pin')),
                selected: _encryptionKeyType == EncryptionKeyType.pin,
                onSelected: _onPinEncryptionSelected,
              ),
              ChoiceChip(
                label: Text(translate('create_invitation_dialog.password')),
                selected: _encryptionKeyType == EncryptionKeyType.password,
                onSelected: _onPasswordEncryptionSelected,
              )
            ]).paddingAll(8),
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: _onGenerateButtonPressed,
                child: Text(
                  translate('create_invitation_dialog.generate'),
                ),
              ),
            ),
            Text(translate('create_invitation_dialog.note')).paddingAll(8),
            Text(
              translate('create_invitation_dialog.note_text'),
              style: Theme.of(context).textTheme.bodySmall,
            ).paddingAll(8),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        'messageTextController', _messageTextController));
  }
}
