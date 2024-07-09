import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({
    required this.header,
    required this.instructions,
    required this.submitText,
    required this.submitDisabledText,
    super.key,
    this.onSubmit,
    this.initialValueCallback,
  });

  @override
  State createState() => _EditProfileFormState();

  final String header;
  final String instructions;
  final Future<void> Function(GlobalKey<FormBuilderState>)? onSubmit;
  final String submitText;
  final String submitDisabledText;
  final Object? Function(String key)? initialValueCallback;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('header', header))
      ..add(StringProperty('instructions', instructions))
      ..add(ObjectFlagProperty<
          Future<void> Function(
              GlobalKey<FormBuilderState> p1)?>.has('onSubmit', onSubmit))
      ..add(StringProperty('submitText', submitText))
      ..add(StringProperty('submitDisabledText', submitDisabledText))
      ..add(ObjectFlagProperty<Object? Function(String key)?>.has(
          'initialValueCallback', initialValueCallback));
  }

  static const String formFieldName = 'name';
  static const String formFieldPronouns = 'pronouns';
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _editProfileForm(
    BuildContext context,
  ) =>
      FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Text(widget.header)
                .textStyle(context.headlineSmall)
                .paddingSymmetric(vertical: 16),
            FormBuilderTextField(
              autofocus: true,
              name: EditProfileForm.formFieldName,
              initialValue: widget.initialValueCallback
                  ?.call(EditProfileForm.formFieldName) as String?,
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
              name: EditProfileForm.formFieldPronouns,
              initialValue: widget.initialValueCallback
                  ?.call(EditProfileForm.formFieldPronouns) as String?,
              maxLength: 64,
              decoration: InputDecoration(
                  labelText: translate('account.form_pronouns')),
              textInputAction: TextInputAction.next,
            ),
            Row(children: [
              const Spacer(),
              Text(widget.instructions).toCenter().flexible(flex: 6),
              const Spacer(),
            ]).paddingSymmetric(vertical: 4),
            ElevatedButton(
              onPressed: widget.onSubmit == null
                  ? null
                  : () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        await widget.onSubmit!(_formKey);
                      }
                    },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check, size: 16).paddingLTRB(0, 0, 4, 0),
                Text((widget.onSubmit == null)
                        ? widget.submitDisabledText
                        : widget.submitText)
                    .paddingLTRB(0, 0, 4, 0)
              ]),
            ).paddingSymmetric(vertical: 4).alignAtCenterRight(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => _editProfileForm(
        context,
      );
}
