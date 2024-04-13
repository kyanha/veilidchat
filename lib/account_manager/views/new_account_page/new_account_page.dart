import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../layout/default_app_bar.dart';
import '../../../theme/theme.dart';
import '../../../tools/tools.dart';
import '../../../veilid_processor/veilid_processor.dart';
import '../../account_manager.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({super.key});

  @override
  NewAccountPageState createState() => NewAccountPageState();
}

class NewAccountPageState extends State<NewAccountPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  late bool isInAsyncCall = false;
  static const String formFieldName = 'name';
  static const String formFieldPronouns = 'pronouns';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.portraitOnly);
    });
  }

  Widget _newAccountForm(BuildContext context,
          {required Future<void> Function(GlobalKey<FormBuilderState>)
              onSubmit}) =>
      FormBuilder(
        key: _formKey,
        child: ListView(
          children: [
            Text(translate('new_account_page.header'))
                .textStyle(context.headlineSmall)
                .paddingSymmetric(vertical: 16),
            FormBuilderTextField(
              autofocus: true,
              name: formFieldName,
              decoration:
                  InputDecoration(labelText: translate('account.form_name')),
              maxLength: 64,
              // The validator receives the text that the user has entered.
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              textInputAction: TextInputAction.next,
            ),
            FormBuilderTextField(
              name: formFieldPronouns,
              maxLength: 64,
              decoration: InputDecoration(
                  labelText: translate('account.form_pronouns')),
              textInputAction: TextInputAction.next,
            ),
            Row(children: [
              const Spacer(),
              Text(translate('new_account_page.instructions'))
                  .toCenter()
                  .flexible(flex: 6),
              const Spacer(),
            ]).paddingSymmetric(vertical: 4),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  setState(() {
                    isInAsyncCall = true;
                  });
                  try {
                    await onSubmit(_formKey);
                  } finally {
                    if (mounted) {
                      setState(() {
                        isInAsyncCall = false;
                      });
                    }
                  }
                }
              },
              child: Text(translate('new_account_page.create')),
            ).paddingSymmetric(vertical: 4).alignAtCenterRight(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final displayModalHUD = isInAsyncCall;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(
          title: Text(translate('new_account_page.titlebar')),
          actions: [
            const SignalStrengthMeterWidget(),
            IconButton(
                icon: const Icon(Icons.settings),
                tooltip: translate('app_bar.settings_tooltip'),
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
            final name =
                _formKey.currentState!.fields[formFieldName]!.value as String;
            final pronouns = _formKey.currentState!.fields[formFieldPronouns]!
                    .value as String? ??
                '';
            final newProfileSpec =
                NewProfileSpec(name: name, pronouns: pronouns);

            await AccountRepository.instance
                .createWithNewMasterIdentity(newProfileSpec);
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isInAsyncCall', isInAsyncCall));
  }
}
