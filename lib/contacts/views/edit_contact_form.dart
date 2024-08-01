import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import 'availability_widget.dart';

class EditContactForm extends StatefulWidget {
  const EditContactForm({
    required this.formKey,
    required this.contact,
    this.onSubmit,
    super.key,
  });

  @override
  State createState() => _EditContactFormState();

  final proto.Contact contact;
  final Future<void> Function(GlobalKey<FormBuilderState>)? onSubmit;
  final GlobalKey<FormBuilderState> formKey;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<
          Future<void> Function(
              GlobalKey<FormBuilderState> p1)?>.has('onSubmit', onSubmit))
      ..add(DiagnosticsProperty<proto.Contact>('contact', contact))
      ..add(
          DiagnosticsProperty<GlobalKey<FormBuilderState>>('formKey', formKey));
  }

  static const String formFieldNickname = 'nickname';
  static const String formFieldNotes = 'notes';
  static const String formFieldShowAvailability = 'show_availability';
}

class _EditContactFormState extends State<EditContactForm> {
  @override
  void initState() {
    super.initState();
  }

  Widget _availabilityWidget(
          BuildContext context, proto.Availability availability) =>
      AvailabilityWidget(availability: availability);

  @override
  Widget build(BuildContext context) {
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
      key: widget.formKey,
      child: Column(
        children: [
          AvatarWidget(
            name: widget.contact.profile.name,
            size: 128,
            borderColor: border,
            foregroundColor: scale.primaryScale.primaryText,
            backgroundColor: scale.primaryScale.primary,
            scaleConfig: scaleConfig,
            textStyle: theme.textTheme.titleLarge!.copyWith(fontSize: 64),
          ).paddingLTRB(0, 0, 0, 16),
          SelectableText(widget.contact.profile.name,
                  style: textTheme.headlineMedium)
              .decoratorLabel(
                context,
                translate('contact_form.form_name'),
                scale: scale.secondaryScale,
              )
              .paddingSymmetric(vertical: 8),
          SelectableText(widget.contact.profile.pronouns,
                  style: textTheme.headlineSmall)
              .decoratorLabel(
                context,
                translate('contact_form.form_pronouns'),
                scale: scale.secondaryScale,
              )
              .paddingSymmetric(vertical: 8),
          Row(children: [
            _availabilityWidget(context, widget.contact.profile.availability),
            SelectableText(widget.contact.profile.status,
                    style: textTheme.bodyMedium)
                .paddingSymmetric(horizontal: 8)
          ])
              .decoratorLabel(
                context,
                translate('contact_form.form_status'),
                scale: scale.secondaryScale,
              )
              .paddingSymmetric(vertical: 8),
          SelectableText(widget.contact.profile.about,
                  minLines: 1, maxLines: 8, style: textTheme.bodyMedium)
              .decoratorLabel(
                context,
                translate('contact_form.form_about'),
                scale: scale.secondaryScale,
              )
              .paddingSymmetric(vertical: 8),
          SelectableText(
                  widget.contact.identityPublicKey.value.toVeilid().toString(),
                  style: textTheme.labelMedium!
                      .copyWith(fontFamily: 'Source Code Pro'))
              .decoratorLabel(
                context,
                translate('contact_form.form_fingerprint'),
                scale: scale.secondaryScale,
              )
              .paddingSymmetric(vertical: 8),
          Divider(color: border).paddingLTRB(8, 0, 8, 8),
          FormBuilderTextField(
            autofocus: true,
            name: EditContactForm.formFieldNickname,
            initialValue: widget.contact.nickname,
            decoration: InputDecoration(
                labelText: translate('contact_form.form_nickname')),
            maxLength: 64,
            textInputAction: TextInputAction.next,
          ),
          FormBuilderCheckbox(
            name: EditContactForm.formFieldShowAvailability,
            initialValue: widget.contact.showAvailability,
            side: BorderSide(color: scale.primaryScale.border, width: 2),
            title: Text(translate('contact_form.form_show_availability'),
                style: textTheme.labelMedium),
          ),
          FormBuilderTextField(
            name: EditContactForm.formFieldNotes,
            initialValue: widget.contact.notes,
            minLines: 1,
            maxLines: 8,
            maxLength: 1024,
            decoration: InputDecoration(
                labelText: translate('contact_form.form_notes')),
            textInputAction: TextInputAction.newline,
          ),
          ElevatedButton(
            onPressed: widget.onSubmit == null
                ? null
                : () async {
                    if (widget.formKey.currentState?.saveAndValidate() ??
                        false) {
                      await widget.onSubmit!(widget.formKey);
                    }
                  },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check, size: 16).paddingLTRB(0, 0, 4, 0),
              Text((widget.onSubmit == null)
                      ? translate('contact_form.save')
                      : translate('contact_form.save'))
                  .paddingLTRB(0, 0, 4, 0)
            ]),
          ).paddingSymmetric(vertical: 4).alignAtCenterRight(),
        ],
      ),
    );
  }
}
