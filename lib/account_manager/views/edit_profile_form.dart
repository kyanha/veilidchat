import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../models/models.dart';

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
  final Future<void> Function(AccountSpec)? onSubmit;
  final String submitText;
  final String submitDisabledText;
  final Object? Function(String key)? initialValueCallback;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('header', header))
      ..add(StringProperty('instructions', instructions))
      ..add(ObjectFlagProperty<Future<void> Function(AccountSpec)?>.has(
          'onSubmit', onSubmit))
      ..add(StringProperty('submitText', submitText))
      ..add(StringProperty('submitDisabledText', submitDisabledText))
      ..add(ObjectFlagProperty<Object? Function(String key)?>.has(
          'initialValueCallback', initialValueCallback));
  }

  static const String formFieldName = 'name';
  static const String formFieldPronouns = 'pronouns';
  static const String formFieldAbout = 'about';
  static const String formFieldAvailability = 'availability';
  static const String formFieldFreeMessage = 'free_message';
  static const String formFieldAwayMessage = 'away_message';
  static const String formFieldBusyMessage = 'busy_message';
  static const String formFieldAvatar = 'avatar';
  static const String formFieldAutoAway = 'auto_away';
  static const String formFieldAutoAwayTimeout = 'auto_away_timeout';
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  FormBuilderDropdown<proto.Availability> _availabilityDropDown(
      BuildContext context) {
    final initialValueX =
        widget.initialValueCallback?.call(EditProfileForm.formFieldAvailability)
                as proto.Availability? ??
            proto.Availability.AVAILABILITY_FREE;
    final initialValue =
        initialValueX == proto.Availability.AVAILABILITY_UNSPECIFIED
            ? proto.Availability.AVAILABILITY_FREE
            : initialValueX;

    final availabilities = [
      proto.Availability.AVAILABILITY_FREE,
      proto.Availability.AVAILABILITY_AWAY,
      proto.Availability.AVAILABILITY_BUSY,
      proto.Availability.AVAILABILITY_OFFLINE,
    ];

    return FormBuilderDropdown<proto.Availability>(
      name: EditProfileForm.formFieldAvailability,
      initialValue: initialValue,
      items: availabilities
          .map((x) => DropdownMenuItem<proto.Availability>(
              value: x,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(AvailabilityWidget.availabilityIcon(x)),
                Text(x == proto.Availability.AVAILABILITY_OFFLINE
                    ? translate('availability.always_show_offline')
                    : AvailabilityWidget.availabilityName(x)),
              ])))
          .toList(),
    );
  }

  AccountSpec _makeAccountSpec() {
    final name = _formKey
        .currentState!.fields[EditProfileForm.formFieldName]!.value as String;
    final pronouns = _formKey.currentState!
            .fields[EditProfileForm.formFieldPronouns]!.value as String? ??
        '';
    final about = _formKey.currentState!.fields[EditProfileForm.formFieldAbout]!
            .value as String? ??
        '';
    final availability = _formKey
            .currentState!
            .fields[EditProfileForm.formFieldAvailability]!
            .value as proto.Availability? ??
        proto.Availability.AVAILABILITY_FREE;

    final invisible = availability == proto.Availability.AVAILABILITY_OFFLINE;

    final freeMessage = _formKey.currentState!
            .fields[EditProfileForm.formFieldFreeMessage]!.value as String? ??
        '';
    final awayMessage = _formKey.currentState!
            .fields[EditProfileForm.formFieldAwayMessage]!.value as String? ??
        '';
    final busyMessage = _formKey.currentState!
            .fields[EditProfileForm.formFieldBusyMessage]!.value as String? ??
        '';
    final autoAway = _formKey.currentState!
            .fields[EditProfileForm.formFieldAutoAway]!.value as bool? ??
        false;
    final autoAwayTimeout = _formKey.currentState!
            .fields[EditProfileForm.formFieldAutoAwayTimeout]!.value as int? ??
        30;

    return AccountSpec(
        name: name,
        pronouns: pronouns,
        about: about,
        availability: availability,
        invisible: invisible,
        freeMessage: freeMessage,
        awayMessage: awayMessage,
        busyMessage: busyMessage,
        avatar: null,
        autoAway: autoAway,
        autoAwayTimeout: autoAwayTimeout);
  }

  Widget _editProfileForm(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;
    final textTheme = theme.textTheme;

    late final Color border;
    if (scaleConfig.useVisualIndicators && !scaleConfig.preferBorders) {
      border = scale.primaryScale.elementBackground;
    } else {
      border = scale.primaryScale.border;
    }

    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          AvatarWidget(
            name: _formKey.currentState?.value[EditProfileForm.formFieldName]
                    as String? ??
                '?',
            size: 128,
            borderColor: border,
            foregroundColor: scale.primaryScale.primaryText,
            backgroundColor: scale.primaryScale.primary,
            scaleConfig: scaleConfig,
            textStyle: theme.textTheme.titleLarge!.copyWith(fontSize: 64),
          ).paddingLTRB(0, 0, 0, 16),
          FormBuilderTextField(
            autofocus: true,
            name: EditProfileForm.formFieldName,
            initialValue: widget.initialValueCallback
                ?.call(EditProfileForm.formFieldName) as String?,
            decoration: InputDecoration(
                labelText: translate('account.form_name'),
                hintText: translate('account.empty_name')),
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
                labelText: translate('account.form_pronouns'),
                hintText: translate('account.empty_pronouns')),
            textInputAction: TextInputAction.next,
          ),
          FormBuilderTextField(
            name: EditProfileForm.formFieldAbout,
            initialValue: widget.initialValueCallback
                ?.call(EditProfileForm.formFieldAbout) as String?,
            maxLength: 1024,
            maxLines: 8,
            minLines: 1,
            decoration: InputDecoration(
                labelText: translate('account.form_about'),
                hintText: translate('account.empty_about')),
            textInputAction: TextInputAction.newline,
          ),
          _availabilityDropDown(context),
          FormBuilderTextField(
            name: EditProfileForm.formFieldFreeMessage,
            initialValue: widget.initialValueCallback
                ?.call(EditProfileForm.formFieldFreeMessage) as String?,
            maxLength: 128,
            decoration: InputDecoration(
                labelText: translate('account.form_free_message'),
                hintText: translate('account.empty_free_message')),
            textInputAction: TextInputAction.next,
          ),
          FormBuilderTextField(
            name: EditProfileForm.formFieldAwayMessage,
            initialValue: widget.initialValueCallback
                ?.call(EditProfileForm.formFieldAwayMessage) as String?,
            maxLength: 128,
            decoration: InputDecoration(
                labelText: translate('account.form_away_message'),
                hintText: translate('account.empty_away_message')),
            textInputAction: TextInputAction.next,
          ),
          FormBuilderTextField(
            name: EditProfileForm.formFieldBusyMessage,
            initialValue: widget.initialValueCallback
                ?.call(EditProfileForm.formFieldBusyMessage) as String?,
            maxLength: 128,
            decoration: InputDecoration(
                labelText: translate('account.form_busy_message'),
                hintText: translate('account.empty_busy_message')),
            textInputAction: TextInputAction.next,
          ),
          FormBuilderCheckbox(
            name: EditProfileForm.formFieldAutoAway,
            initialValue: widget.initialValueCallback
                    ?.call(EditProfileForm.formFieldAutoAway) as bool? ??
                false,
            side: BorderSide(color: scale.primaryScale.border, width: 2),
            title: Text(translate('account.form_auto_away'),
                style: textTheme.labelMedium),
          ),
          FormBuilderTextField(
            name: EditProfileForm.formFieldAutoAwayTimeout,
            enabled: _formKey.currentState
                    ?.value[EditProfileForm.formFieldAutoAway] as bool? ??
                false,
            initialValue: widget.initialValueCallback
                        ?.call(EditProfileForm.formFieldAutoAwayTimeout)
                    as String? ??
                '15',
            decoration: InputDecoration(
              labelText: translate('account.form_auto_away_timeout'),
            ),
            validator: FormBuilderValidators.positiveNumber(),
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
                      final aus = _makeAccountSpec();
                      await widget.onSubmit!(aus);
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
  }

  @override
  Widget build(BuildContext context) => _editProfileForm(
        context,
      );
}
