import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:protobuf/protobuf.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../contacts/cubits/contact_list_cubit.dart';
import '../../conversation/conversation.dart';
import '../../layout/default_app_bar.dart';
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
      super.key});

  @override
  State createState() => _EditAccountPageState();

  final TypedKey superIdentityRecordKey;
  final proto.Profile existingProfile;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TypedKey>(
          'superIdentityRecordKey', superIdentityRecordKey))
      ..add(DiagnosticsProperty<proto.Profile>(
          'existingProfile', existingProfile));
  }
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isInAsyncCall = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.portraitOnly);
    });
  }

  Widget _editAccountForm(BuildContext context,
          {required Future<void> Function(GlobalKey<FormBuilderState>)
              onSubmit}) =>
      EditProfileForm(
          header: translate('edit_account_page.header'),
          instructions: translate('edit_account_page.instructions'),
          submitText: translate('edit_account_page.update'),
          submitDisabledText: translate('button.waiting_for_network'),
          onSubmit: onSubmit);

  @override
  Widget build(BuildContext context) {
    final displayModalHUD = _isInAsyncCall;
    final accountRecordCubit = context.read<AccountRecordCubit>();
    final activeConversationsBlocMapCubit =
        context.read<ActiveConversationsBlocMapCubit>();
    final contactListCubit = context.read<ContactListCubit>();

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(
          title: Text(translate('edit_account_page.titlebar')),
          actions: [
            const SignalStrengthMeterWidget(),
            IconButton(
                icon: const Icon(Icons.settings),
                tooltip: translate('menu.settings_tooltip'),
                onPressed: () async {
                  await GoRouterHelper(context).push('/settings');
                })
          ]),
      body: _editAccountForm(
        context,
        onSubmit: (formKey) async {
          // dismiss the keyboard by unfocusing the textfield
          FocusScope.of(context).unfocus();

          try {
            final name = _formKey.currentState!
                .fields[EditProfileForm.formFieldName]!.value as String;
            final pronouns = _formKey
                    .currentState!
                    .fields[EditProfileForm.formFieldPronouns]!
                    .value as String? ??
                '';
            final newProfile = widget.existingProfile.deepCopy()
              ..name = name
              ..pronouns = pronouns;

            setState(() {
              _isInAsyncCall = true;
            });
            try {
              // Update account profile DHT record
              final newValue = await accountRecordCubit.record
                  .tryWriteProtobuf(proto.Account.fromBuffer, newProfile);
              if (newValue != null) {
                if (context.mounted) {
                  await showErrorModal(
                      context,
                      translate('edit_account_page.error'),
                      'Failed to update profile online');
                  return;
                }
              }

              // Update local account profile
              await AccountRepository.instance.editAccountProfile(
                  widget.superIdentityRecordKey, newProfile);

              // Update all conversations with new profile
              final updates = <Future<void>>[];
              for (final key in activeConversationsBlocMapCubit.state.keys) {
                await activeConversationsBlocMapCubit.operateAsync(key,
                    closure: (cubit) async {
                  final newLocalConversation =
                      cubit.state.asData?.value.localConversation.deepCopy();
                  if (newLocalConversation != null) {
                    newLocalConversation.profile = newProfile;
                    updates.add(cubit.input.writeLocalConversation(
                        conversation: newLocalConversation));
                  }
                });
              }

              // Wait for updates
              await updates.wait;

              // XXX: how to do this for non-chat contacts?
            } finally {
              if (mounted) {
                setState(() {
                  _isInAsyncCall = false;
                });
              }
            }
          } on Exception catch (e) {
            if (context.mounted) {
              await showErrorModal(context,
                  translate('edit_account_page.error'), 'Exception: $e');
            }
          }
        },
      ).paddingSymmetric(horizontal: 24, vertical: 8),
    ).withModalHUD(context, displayModalHUD);
  }
}
