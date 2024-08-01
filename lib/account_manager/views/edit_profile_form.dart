import 'package:async_tools/async_tools.dart';
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

const _kDoUpdateSubmit = 'doUpdateSubmit';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({
    required this.header,
    required this.instructions,
    required this.submitText,
    required this.submitDisabledText,
    required this.initialValueCallback,
    this.onUpdate,
    this.onSubmit,
    super.key,
  });

  @override
  State createState() => _EditProfileFormState();

  final String header;
  final String instructions;
  final Future<void> Function(AccountSpec)? onUpdate;
  final Future<void> Function(AccountSpec)? onSubmit;
  final String submitText;
  final String submitDisabledText;
  final Object Function(String key) initialValueCallback;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('header', header))
      ..add(StringProperty('instructions', instructions))
      ..add(ObjectFlagProperty<Future<void> Function(AccountSpec)?>.has(
          'onUpdate', onUpdate))
      ..add(StringProperty('submitText', submitText))
      ..add(StringProperty('submitDisabledText', submitDisabledText))
      ..add(ObjectFlagProperty<Object Function(String key)?>.has(
          'initialValueCallback', initialValueCallback))
      ..add(ObjectFlagProperty<Future<void> Function(AccountSpec)?>.has(
          'onSubmit', onSubmit));
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
    _autoAwayEnabled =
        widget.initialValueCallback(EditProfileForm.formFieldAutoAway) as bool;

    super.initState();
  }

  FormBuilderDropdown<proto.Availability> _availabilityDropDown(
      BuildContext context) {
    final initialValueX =
        widget.initialValueCallback(EditProfileForm.formFieldAvailability)
            as proto.Availability;
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
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: translate('account.form_availability'),
          hintText: translate('account.empty_busy_message')),
      items: availabilities
          .map((x) => DropdownMenuItem<proto.Availability>(
              value: x,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AvailabilityWidget.availabilityIcon(x),
                Text(x == proto.Availability.AVAILABILITY_OFFLINE
                        ? translate('availability.always_show_offline')
                        : AvailabilityWidget.availabilityName(x))
                    .paddingLTRB(8, 0, 0, 0),
              ])))
          .toList(),
    );
  }

  AccountSpec _makeAccountSpec() {
    final name = _formKey
        .currentState!.fields[EditProfileForm.formFieldName]!.value as String;
    final pronouns = _formKey.currentState!
        .fields[EditProfileForm.formFieldPronouns]!.value as String;
    final about = _formKey
        .currentState!.fields[EditProfileForm.formFieldAbout]!.value as String;
    final availability = _formKey
        .currentState!
        .fields[EditProfileForm.formFieldAvailability]!
        .value as proto.Availability;

    final invisible = availability == proto.Availability.AVAILABILITY_OFFLINE;
    final freeMessage = _formKey.currentState!
        .fields[EditProfileForm.formFieldFreeMessage]!.value as String;
    final awayMessage = _formKey.currentState!
        .fields[EditProfileForm.formFieldAwayMessage]!.value as String;
    final busyMessage = _formKey.currentState!
        .fields[EditProfileForm.formFieldBusyMessage]!.value as String;
    final autoAway = _formKey
        .currentState!.fields[EditProfileForm.formFieldAutoAway]!.value as bool;
    final autoAwayTimeoutString = _formKey.currentState!
        .fields[EditProfileForm.formFieldAutoAwayTimeout]!.value as String;
    final autoAwayTimeout = int.parse(autoAwayTimeoutString);

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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
            initialValue: widget
                .initialValueCallback(EditProfileForm.formFieldName) as String,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: translate('account.form_name'),
                hintText: translate('account.empty_name')),
            maxLength: 64,
            // The validator receives the text that the user has entered.
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
            textInputAction: TextInputAction.next,
          ).onFocusChange(_onFocusChange),
          FormBuilderTextField(
            name: EditProfileForm.formFieldPronouns,
            initialValue:
                widget.initialValueCallback(EditProfileForm.formFieldPronouns)
                    as String,
            maxLength: 64,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: translate('account.form_pronouns'),
                hintText: translate('account.empty_pronouns')),
            textInputAction: TextInputAction.next,
          ).onFocusChange(_onFocusChange),
          FormBuilderTextField(
            name: EditProfileForm.formFieldAbout,
            initialValue: widget
                .initialValueCallback(EditProfileForm.formFieldAbout) as String,
            maxLength: 1024,
            maxLines: 8,
            minLines: 1,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: translate('account.form_about'),
                hintText: translate('account.empty_about')),
            textInputAction: TextInputAction.newline,
          ).onFocusChange(_onFocusChange),
          _availabilityDropDown(context)
              .paddingLTRB(0, 0, 0, 16)
              .onFocusChange(_onFocusChange),
          FormBuilderTextField(
            name: EditProfileForm.formFieldFreeMessage,
            initialValue: widget.initialValueCallback(
                EditProfileForm.formFieldFreeMessage) as String,
            maxLength: 128,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: translate('account.form_free_message'),
                hintText: translate('account.empty_free_message')),
            textInputAction: TextInputAction.next,
          ).onFocusChange(_onFocusChange),
          FormBuilderTextField(
            name: EditProfileForm.formFieldAwayMessage,
            initialValue: widget.initialValueCallback(
                EditProfileForm.formFieldAwayMessage) as String,
            maxLength: 128,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: translate('account.form_away_message'),
                hintText: translate('account.empty_away_message')),
            textInputAction: TextInputAction.next,
          ).onFocusChange(_onFocusChange),
          FormBuilderTextField(
            name: EditProfileForm.formFieldBusyMessage,
            initialValue: widget.initialValueCallback(
                EditProfileForm.formFieldBusyMessage) as String,
            maxLength: 128,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: translate('account.form_busy_message'),
                hintText: translate('account.empty_busy_message')),
            textInputAction: TextInputAction.next,
          ).onFocusChange(_onFocusChange),
          FormBuilderCheckbox(
            name: EditProfileForm.formFieldAutoAway,
            initialValue:
                widget.initialValueCallback(EditProfileForm.formFieldAutoAway)
                    as bool,
            side: BorderSide(color: scale.primaryScale.border, width: 2),
            title: Text(translate('account.form_auto_away'),
                style: textTheme.labelMedium),
            onChanged: (v) {
              setState(() {
                _autoAwayEnabled = v ?? false;
              });
            },
          ).onFocusChange(_onFocusChange),
          FormBuilderTextField(
            name: EditProfileForm.formFieldAutoAwayTimeout,
            enabled: _autoAwayEnabled,
            initialValue: widget.initialValueCallback(
                EditProfileForm.formFieldAutoAwayTimeout) as String,
            decoration: InputDecoration(
              labelText: translate('account.form_auto_away_timeout'),
            ),
            validator: FormBuilderValidators.positiveNumber(),
            textInputAction: TextInputAction.next,
          ).onFocusChange(_onFocusChange),
          Row(children: [
            const Spacer(),
            Text(widget.instructions).toCenter().flexible(flex: 6),
            const Spacer(),
          ]).paddingSymmetric(vertical: 4),
          if (widget.onSubmit != null)
            ElevatedButton(
              onPressed: widget.onSubmit == null ? null : _doSubmit,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check, size: 16).paddingLTRB(0, 0, 4, 0),
                Text((widget.onSubmit == null)
                        ? widget.submitDisabledText
                        : widget.submitText)
                    .paddingLTRB(0, 0, 4, 0)
              ]),
            )
        ],
      ),
    );
  }

  void _onFocusChange(bool focused) {
    if (!focused) {
      _doUpdate();
    }
  }

  void _doUpdate() {
    final onUpdate = widget.onUpdate;
    if (onUpdate != null) {
      singleFuture((this, _kDoUpdateSubmit), () async {
        if (_formKey.currentState?.saveAndValidate() ?? false) {
          final aus = _makeAccountSpec();
          await onUpdate(aus);
        }
      });
    }
  }

  void _doSubmit() {
    final onSubmit = widget.onSubmit;
    if (onSubmit != null) {
      singleFuture((this, _kDoUpdateSubmit), () async {
        if (_formKey.currentState?.saveAndValidate() ?? false) {
          final aus = _makeAccountSpec();
          await onSubmit(aus);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => _editProfileForm(
        context,
      );

  ///////////////////////////////////////////////////////////////////////////
  late bool _autoAwayEnabled;
}
