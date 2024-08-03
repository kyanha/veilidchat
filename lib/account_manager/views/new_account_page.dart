import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';

import '../../layout/default_app_bar.dart';
import '../../notifications/cubits/notifications_cubit.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../../veilid_processor/veilid_processor.dart';
import '../account_manager.dart';
import 'edit_profile_form.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({super.key});

  @override
  State createState() => _NewAccountPageState();
}

class _NewAccountPageState extends WindowSetupState<NewAccountPage> {
  _NewAccountPageState()
      : super(
            titleBarStyle: TitleBarStyle.normal,
            orientationCapability: OrientationCapability.portraitOnly);

  Object _defaultAccountValues(String key) {
    switch (key) {
      case EditProfileForm.formFieldName:
        return '';
      case EditProfileForm.formFieldPronouns:
        return '';
      case EditProfileForm.formFieldAbout:
        return '';
      case EditProfileForm.formFieldAvailability:
        return proto.Availability.AVAILABILITY_FREE;
      case EditProfileForm.formFieldFreeMessage:
        return '';
      case EditProfileForm.formFieldAwayMessage:
        return '';
      case EditProfileForm.formFieldBusyMessage:
        return '';
      // case EditProfileForm.formFieldAvatar:
      //   return null;
      case EditProfileForm.formFieldAutoAway:
        return false;
      case EditProfileForm.formFieldAutoAwayTimeout:
        return '15';
      default:
        throw StateError('missing form element');
    }
  }

  Widget _newAccountForm(
    BuildContext context,
  ) =>
      EditProfileForm(
          header: translate('new_account_page.header'),
          instructions: translate('new_account_page.instructions'),
          submitText: translate('new_account_page.create'),
          submitDisabledText: translate('button.waiting_for_network'),
          initialValueCallback: _defaultAccountValues,
          onSubmit: _onSubmit);

  Future<void> _onSubmit(AccountSpec accountSpec) async {
    // dismiss the keyboard by unfocusing the textfield
    FocusScope.of(context).unfocus();

    try {
      setState(() {
        _isInAsyncCall = true;
      });
      try {
        final networkReady = context
                .read<ConnectionStateCubit>()
                .state
                .asData
                ?.value
                .isPublicInternetReady ??
            false;

        final canSubmit = networkReady;
        if (!canSubmit) {
          context.read<NotificationsCubit>().error(
              text: translate('new_account_page.network_is_offline'),
              title: translate('new_account_page.error'));
          return;
        }

        final writableSuperIdentity = await AccountRepository.instance
            .createWithNewSuperIdentity(accountSpec);
        GoRouterHelper(context).pushReplacement('/new_account/recovery_key',
            extra: [writableSuperIdentity, accountSpec.name]);
      } finally {
        if (mounted) {
          setState(() {
            _isInAsyncCall = false;
          });
        }
      }
    } on Exception catch (e, st) {
      if (mounted) {
        await showErrorStacktraceModal(
            context: context, error: e, stackTrace: st);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayModalHUD = _isInAsyncCall;

    return StyledScaffold(
      appBar: DefaultAppBar(
          title: Text(translate('new_account_page.titlebar')),
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
          child: _newAccountForm(
        context,
      )).paddingSymmetric(horizontal: 24, vertical: 8),
    ).withModalHUD(context, displayModalHUD);
  }

  ////////////////////////////////////////////////////////////////////////////

  bool _isInAsyncCall = false;
}
