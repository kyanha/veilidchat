import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:protobuf/protobuf.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../layout/default_app_bar.dart';
import '../../notifications/notifications.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../../veilid_processor/veilid_processor.dart';
import '../account_manager.dart';
import 'profile_edit_form.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage(
      {required this.superIdentityRecordKey,
      required this.existingProfile,
      required this.accountRecord,
      super.key});

  @override
  State createState() => _EditAccountPageState();

  final TypedKey superIdentityRecordKey;
  final proto.Profile existingProfile;
  final OwnedDHTRecordPointer accountRecord;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TypedKey>(
          'superIdentityRecordKey', superIdentityRecordKey))
      ..add(DiagnosticsProperty<proto.Profile>(
          'existingProfile', existingProfile))
      ..add(DiagnosticsProperty<OwnedDHTRecordPointer>(
          'accountRecord', accountRecord));
  }
}

class _EditAccountPageState extends WindowSetupState<EditAccountPage> {
  _EditAccountPageState()
      : super(
            titleBarStyle: TitleBarStyle.normal,
            orientationCapability: OrientationCapability.portraitOnly);

  Widget _editAccountForm(BuildContext context,
          {required Future<void> Function(GlobalKey<FormBuilderState>)
              onSubmit}) =>
      EditProfileForm(
        header: translate('edit_account_page.header'),
        instructions: translate('edit_account_page.instructions'),
        submitText: translate('edit_account_page.update'),
        submitDisabledText: translate('button.waiting_for_network'),
        onSubmit: onSubmit,
        initialValueCallback: (key) => switch (key) {
          EditProfileForm.formFieldName => widget.existingProfile.name,
          EditProfileForm.formFieldPronouns => widget.existingProfile.pronouns,
          String() => throw UnimplementedError(),
        },
      );

  Future<void> _onRemoveAccount() async {
    final confirmed = await StyledDialog.show<bool>(
        context: context,
        title: translate('edit_account_page.remove_account_confirm'),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(translate('edit_account_page.remove_account_confirm_message'))
              .paddingLTRB(24, 24, 24, 0),
          Text(translate('edit_account_page.confirm_are_you_sure'))
              .paddingAll(8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cancel, size: 16).paddingLTRB(0, 0, 4, 0),
                  Text(translate('button.no_cancel')).paddingLTRB(0, 0, 4, 0)
                ])),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check, size: 16).paddingLTRB(0, 0, 4, 0),
                  Text(translate('button.yes_proceed')).paddingLTRB(0, 0, 4, 0)
                ]))
          ]).paddingAll(24)
        ]));
    if (confirmed != null && confirmed && mounted) {
      // dismiss the keyboard by unfocusing the textfield
      FocusScope.of(context).unfocus();

      try {
        setState(() {
          _isInAsyncCall = true;
        });
        try {
          final success = await AccountRepository.instance.deleteLocalAccount(
              widget.superIdentityRecordKey, widget.accountRecord);
          if (success && mounted) {
            context
                .read<NotificationsCubit>()
                .info(text: translate('edit_account_page.account_removed'));
            GoRouterHelper(context).pop();
          } else if (mounted) {
            context
                .read<NotificationsCubit>()
                .error(text: translate('edit_account_page.failed_to_remove'));
          }
        } finally {
          if (mounted) {
            setState(() {
              _isInAsyncCall = false;
            });
          }
        }
      } on Exception catch (e) {
        if (mounted) {
          await showErrorModal(
              context, translate('new_account_page.error'), 'Exception: $e');
        }
      }
    }
  }

  Future<void> _onDestroyAccount() async {
    final confirmed = await StyledDialog.show<bool>(
        context: context,
        title: translate('edit_account_page.destroy_account_confirm'),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(translate('edit_account_page.destroy_account_confirm_message'))
              .paddingLTRB(24, 24, 24, 0),
          Text(translate(
                  'edit_account_page.destroy_account_confirm_message_details'))
              .paddingLTRB(24, 24, 24, 0),
          Text(translate('edit_account_page.confirm_are_you_sure'))
              .paddingAll(8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cancel, size: 16).paddingLTRB(0, 0, 4, 0),
                  Text(translate('button.no_cancel')).paddingLTRB(0, 0, 4, 0)
                ])),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check, size: 16).paddingLTRB(0, 0, 4, 0),
                  Text(translate('button.yes_proceed')).paddingLTRB(0, 0, 4, 0)
                ]))
          ]).paddingAll(24)
        ]));
    if (confirmed != null && confirmed && mounted) {
      // dismiss the keyboard by unfocusing the textfield
      FocusScope.of(context).unfocus();

      try {
        setState(() {
          _isInAsyncCall = true;
        });
        try {
          final success = await AccountRepository.instance.destroyAccount(
              widget.superIdentityRecordKey, widget.accountRecord);
          if (success && mounted) {
            context
                .read<NotificationsCubit>()
                .info(text: translate('edit_account_page.account_destroyed'));
            GoRouterHelper(context).pop();
          } else if (mounted) {
            context
                .read<NotificationsCubit>()
                .error(text: translate('edit_account_page.failed_to_destroy'));
          }
        } finally {
          if (mounted) {
            setState(() {
              _isInAsyncCall = false;
            });
          }
        }
      } on Exception catch (e) {
        if (mounted) {
          await showErrorModal(
              context, translate('new_account_page.error'), 'Exception: $e');
        }
      }
    }
  }

  Future<void> _onSubmit(GlobalKey<FormBuilderState> formKey) async {
    // dismiss the keyboard by unfocusing the textfield
    FocusScope.of(context).unfocus();

    try {
      final name = formKey
          .currentState!.fields[EditProfileForm.formFieldName]!.value as String;
      final pronouns = formKey.currentState!
              .fields[EditProfileForm.formFieldPronouns]!.value as String? ??
          '';
      final newProfile = widget.existingProfile.deepCopy()
        ..name = name
        ..pronouns = pronouns
        ..timestamp = Veilid.instance.now().toInt64();

      setState(() {
        _isInAsyncCall = true;
      });
      try {
        // Look up account cubit for this specific account
        final perAccountCollectionBlocMapCubit =
            context.read<PerAccountCollectionBlocMapCubit>();
        final accountRecordCubit = await perAccountCollectionBlocMapCubit
            .operate(widget.superIdentityRecordKey,
                closure: (c) async => c.accountRecordCubit);
        if (accountRecordCubit == null) {
          return;
        }

        // Update account profile DHT record
        // This triggers ConversationCubits to update
        await accountRecordCubit.updateProfile(newProfile);

        // Update local account profile
        await AccountRepository.instance
            .editAccountProfile(widget.superIdentityRecordKey, newProfile);

        if (mounted) {
          Navigator.canPop(context)
              ? GoRouterHelper(context).pop()
              : GoRouterHelper(context).go('/');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isInAsyncCall = false;
          });
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        await showErrorModal(
            context, translate('edit_account_page.error'), 'Exception: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayModalHUD = _isInAsyncCall;

    return StyledScaffold(
            // resizeToAvoidBottomInset: false,
            appBar: DefaultAppBar(
                title: Text(translate('edit_account_page.titlebar')),
                leading: Navigator.canPop(context)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    : null,
                actions: [
                  const SignalStrengthMeterWidget(),
                  IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: translate('menu.settings_tooltip'),
                      onPressed: () async {
                        await GoRouterHelper(context).push('/settings');
                      })
                ]),
            body: SingleChildScrollView(
                child: Column(children: [
              _editAccountForm(
                context,
                onSubmit: _onSubmit,
              ).paddingLTRB(0, 0, 0, 32),
              OptionBox(
                instructions:
                    translate('edit_account_page.remove_account_description'),
                buttonIcon: Icons.person_remove_alt_1,
                buttonText: translate('edit_account_page.remove_account'),
                onClick: _onRemoveAccount,
              ),
              OptionBox(
                instructions:
                    translate('edit_account_page.destroy_account_description'),
                buttonIcon: Icons.person_off,
                buttonText: translate('edit_account_page.destroy_account'),
                onClick: _onDestroyAccount,
              )
            ]).paddingSymmetric(horizontal: 24, vertical: 8)))
        .withModalHUD(context, displayModalHUD);
  }

  ////////////////////////////////////////////////////////////////////////////

  bool _isInAsyncCall = false;
}
