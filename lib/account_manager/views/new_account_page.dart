import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';

import '../../layout/default_app_bar.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../../veilid_processor/veilid_processor.dart';
import '../account_manager.dart';
import 'profile_edit_form.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({super.key});

  @override
  State createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  bool _isInAsyncCall = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.portraitOnly);
    });
  }

  Widget _newAccountForm(BuildContext context,
      {required Future<void> Function(GlobalKey<FormBuilderState>) onSubmit}) {
    final networkReady = context
            .watch<ConnectionStateCubit>()
            .state
            .asData
            ?.value
            .isPublicInternetReady ??
        false;
    final canSubmit = networkReady;

    return EditProfileForm(
        header: translate('new_account_page.header'),
        instructions: translate('new_account_page.instructions'),
        submitText: translate('new_account_page.create'),
        submitDisabledText: translate('button.waiting_for_network'),
        onSubmit: !canSubmit ? null : onSubmit);
  }

  @override
  Widget build(BuildContext context) {
    final displayModalHUD = _isInAsyncCall;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
      body: _newAccountForm(
        context,
        onSubmit: (formKey) async {
          // dismiss the keyboard by unfocusing the textfield
          FocusScope.of(context).unfocus();

          try {
            final name = formKey.currentState!
                .fields[EditProfileForm.formFieldName]!.value as String;
            final pronouns = formKey
                    .currentState!
                    .fields[EditProfileForm.formFieldPronouns]!
                    .value as String? ??
                '';
            final newProfile = proto.Profile()
              ..name = name
              ..pronouns = pronouns;

            setState(() {
              _isInAsyncCall = true;
            });
            try {
              final superSecret = await AccountRepository.instance
                  .createWithNewSuperIdentity(newProfile);
              GoRouterHelper(context).pushReplacement(
                  '/new_account/recovery_key',
                  extra: superSecret);
            } finally {
              if (mounted) {
                setState(() {
                  _isInAsyncCall = false;
                });
              }
            }
          } on Exception catch (e) {
            if (context.mounted) {
              await showErrorModal(context, translate('new_account_page.error'),
                  'Exception: $e');
            }
          }
        },
      ).paddingSymmetric(horizontal: 24, vertical: 8),
    ).withModalHUD(context, displayModalHUD);
  }
}
