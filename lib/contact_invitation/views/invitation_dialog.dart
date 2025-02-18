import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../notifications/notifications.dart';
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../contact_invitation.dart';

class InvitationDialog extends StatefulWidget {
  const InvitationDialog(
      {required Locator locator,
      required this.onValidationCancelled,
      required this.onValidationSuccess,
      required this.onValidationFailed,
      required this.inviteControlIsValid,
      required this.buildInviteControl,
      super.key})
      : _locator = locator;

  final void Function() onValidationCancelled;
  final void Function() onValidationSuccess;
  final void Function() onValidationFailed;
  final bool Function() inviteControlIsValid;
  final Widget Function(
      BuildContext context,
      InvitationDialogState dialogState,
      Future<void> Function({required Uint8List inviteData})
          validateInviteData) buildInviteControl;
  final Locator _locator;

  @override
  InvitationDialogState createState() => InvitationDialogState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<void Function()>.has(
          'onValidationCancelled', onValidationCancelled))
      ..add(ObjectFlagProperty<void Function()>.has(
          'onValidationSuccess', onValidationSuccess))
      ..add(ObjectFlagProperty<void Function()>.has(
          'onValidationFailed', onValidationFailed))
      ..add(ObjectFlagProperty<void Function()>.has(
          'inviteControlIsValid', inviteControlIsValid))
      ..add(ObjectFlagProperty<
              Widget Function(
                  BuildContext context,
                  InvitationDialogState dialogState,
                  Future<void> Function({required Uint8List inviteData})
                      validateInviteData)>.has(
          'buildInviteControl', buildInviteControl));
  }
}

class InvitationDialogState extends State<InvitationDialog> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _onCancel() async {
    final navigator = Navigator.of(context);
    _cancelRequest.cancel();
    setState(() {
      _isAccepting = false;
    });
    navigator.pop();
  }

  Future<void> _onAccept() async {
    final navigator = Navigator.of(context);
    final accountInfo = widget._locator<AccountInfoCubit>().state;
    final contactList = widget._locator<ContactListCubit>();
    final profile =
        widget._locator<AccountRecordCubit>().state.asData!.value.profile;

    setState(() {
      _isAccepting = true;
    });
    final validInvitation = _validInvitation;
    if (validInvitation != null) {
      final acceptedContact = await validInvitation.accept(profile);
      if (acceptedContact != null) {
        // initiator when accept is received will create
        // contact in the case of a 'note to self'
        final isSelf = accountInfo.identityPublicKey ==
            acceptedContact.remoteIdentity.currentInstance.publicKey;
        if (!isSelf) {
          await contactList.createContact(
            profile: acceptedContact.remoteProfile,
            remoteSuperIdentity: acceptedContact.remoteIdentity,
            remoteConversationRecordKey:
                acceptedContact.remoteConversationRecordKey,
            localConversationRecordKey:
                acceptedContact.localConversationRecordKey,
          );
        }
      } else {
        if (mounted) {
          context
              .read<NotificationsCubit>()
              .error(text: 'invitation_dialog.failed_to_accept');
        }
      }
    }
    setState(() {
      _isAccepting = false;
    });
    navigator.pop();
  }

  Future<void> _onReject() async {
    final navigator = Navigator.of(context);

    setState(() {
      _isAccepting = true;
    });
    final validInvitation = _validInvitation;
    if (validInvitation != null) {
      if (await validInvitation.reject()) {
        // do nothing right now
      } else {
        if (mounted) {
          context
              .read<NotificationsCubit>()
              .error(text: 'invitation_dialog.failed_to_reject');
        }
      }
    }
    setState(() {
      _isAccepting = false;
    });
    navigator.pop();
  }

  Future<void> _validateInviteData({
    required Uint8List inviteData,
  }) async {
    try {
      final contactInvitationListCubit =
          widget._locator<ContactInvitationListCubit>();

      setState(() {
        _isValidating = true;
        _validInvitation = null;
      });
      final validatedContactInvitation =
          await contactInvitationListCubit.validateInvitation(
              inviteData: inviteData,
              cancelRequest: _cancelRequest,
              getEncryptionKeyCallback:
                  (cs, encryptionKeyType, encryptedSecret) async {
                String encryptionKey;
                switch (encryptionKeyType) {
                  case EncryptionKeyType.none:
                    encryptionKey = '';
                  case EncryptionKeyType.pin:
                    final description =
                        translate('invitation_dialog.protected_with_pin');
                    if (!mounted) {
                      return null;
                    }
                    final pin = await showDialog<String>(
                        context: context,
                        builder: (context) => EnterPinDialog(
                            reenter: false, description: description));
                    if (pin == null) {
                      return null;
                    }
                    encryptionKey = pin;
                  case EncryptionKeyType.password:
                    final description =
                        translate('invitation_dialog.protected_with_password');
                    if (!mounted) {
                      return null;
                    }
                    final password = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            EnterPasswordDialog(description: description));
                    if (password == null) {
                      return null;
                    }
                    encryptionKey = password;
                }
                return encryptionKeyType.decryptSecretFromBytes(
                    secretBytes: encryptedSecret,
                    cryptoKind: cs.kind(),
                    encryptionKey: encryptionKey);
              });

      // Check if validation was cancelled
      if (validatedContactInvitation == null) {
        setState(() {
          _isValidating = false;
          _validInvitation = null;
          widget.onValidationCancelled();
        });
        return;
      }

      // Verify expiration
      // xxx

      setState(() {
        widget.onValidationSuccess();
        _isValidating = false;
        _validInvitation = validatedContactInvitation;
      });
    } on ContactInviteInvalidKeyException catch (e) {
      String errorText;
      switch (e.type) {
        case EncryptionKeyType.none:
          errorText = translate('invitation_dialog.invalid_invitation');
        case EncryptionKeyType.pin:
          errorText = translate('invitation_dialog.invalid_pin');
        case EncryptionKeyType.password:
          errorText = translate('invitation_dialog.invalid_password');
      }
      if (mounted) {
        context.read<NotificationsCubit>().error(text: errorText);
      }
      setState(() {
        _isValidating = false;
        _validInvitation = null;
        widget.onValidationFailed();
      });
    } on VeilidAPIException catch (e) {
      late final String errorText;
      if (e is VeilidAPIExceptionTryAgain) {
        errorText = translate('invitation_dialog.try_again_online');
      }
      if (e is VeilidAPIExceptionKeyNotFound) {
        errorText = translate('invitation_dialog.key_not_found');
      } else {
        errorText = translate('invitation_dialog.invalid_invitation');
      }
      if (mounted) {
        context.read<NotificationsCubit>().error(text: errorText);
      }
      setState(() {
        _isValidating = false;
        _validInvitation = null;
        widget.onValidationFailed();
      });
    } on CancelException {
      setState(() {
        _isValidating = false;
        _validInvitation = null;
        widget.onValidationCancelled();
      });
    } on Exception catch (e) {
      log.debug('exception: $e', e);
      setState(() {
        _isValidating = false;
        _validInvitation = null;
        widget.onValidationFailed();
      });
      rethrow;
    }
  }

  List<Widget> _buildPreAccept() => <Widget>[
        if (!_isValidating && _validInvitation == null)
          widget.buildInviteControl(context, this, _validateInviteData),
        if (_isValidating)
          Column(children: [
            Text(translate('invitation_dialog.validating'))
                .paddingLTRB(0, 0, 0, 16),
            buildProgressIndicator().paddingAll(16),
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: Text(translate('button.cancel')),
              onPressed: _onCancel,
            ).paddingAll(16),
          ]).toCenter(),
        if (_validInvitation == null &&
            !_isValidating &&
            widget.inviteControlIsValid())
          Column(children: [
            Text(translate('invitation_dialog.invalid_invitation')),
            const Icon(Icons.error).paddingAll(16)
          ]).toCenter(),
        if (_validInvitation != null && !_isValidating)
          Column(children: [
            Container(
                constraints: const BoxConstraints(maxHeight: 64),
                width: double.infinity,
                child: ProfileWidget(
                  profile: _validInvitation!.remoteProfile,
                  showPronouns: true,
                )).paddingLTRB(0, 0, 0, 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: Text(translate('button.accept')),
                  onPressed: _onAccept,
                ).paddingLTRB(0, 0, 8, 0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: Text(translate('button.reject')),
                  onPressed: _onReject,
                ).paddingLTRB(8, 0, 0, 0)
              ],
            ),
          ])
      ];

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final scale = theme.extension<ScaleScheme>()!;
    // final textTheme = theme.textTheme;
    // final height = MediaQuery.of(context).size.height;
    final dismissible = !_isAccepting && !_isValidating;

    final dialog = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _isAccepting
                ? [
                    buildProgressIndicator().paddingAll(16),
                  ]
                : _buildPreAccept()),
      ),
    );
    return PopControl(dismissible: dismissible, child: dialog);
  }

  ////////////////////////////////////////////////////////////////////////////

  ValidContactInvitation? _validInvitation;
  bool _isValidating = false;
  bool _isAccepting = false;
  final _cancelRequest = CancelRequest();

  bool get isValidating => _isValidating;
  bool get isAccepting => _isAccepting;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isValidating', isValidating))
      ..add(DiagnosticsProperty<bool>('isAccepting', isAccepting));
  }
}
