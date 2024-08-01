import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../notifications/notifications.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../contact_invitation.dart';

class ContactInvitationDisplayDialog extends StatelessWidget {
  const ContactInvitationDisplayDialog._({
    required this.locator,
    required this.message,
    required this.fingerprint,
  });

  final Locator locator;
  final String message;
  final String fingerprint;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('message', message))
      ..add(DiagnosticsProperty<Locator>('locator', locator))
      ..add(StringProperty('fingerprint', fingerprint));
  }

  String makeTextInvite(String message, Uint8List data) {
    final invite = StringUtils.addCharAtPosition(
        base64UrlNoPadEncode(data), '\n', 40,
        repeat: true);
    final msg = message.isNotEmpty ? '$message\n' : '';

    return '$msg'
        '--- BEGIN VEILIDCHAT CONTACT INVITE ----\n'
        '$invite\n'
        '---- END VEILIDCHAT CONTACT INVITE -----\n'
        'Fingerprint:\n$fingerprint\n';
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final generatorOutputV = context.watch<InvitationGeneratorCubit>().state;

    final cardsize =
        min<double>(MediaQuery.of(context).size.shortestSide - 48.0, 400);

    return BlocListener<ContactInvitationListCubit,
            ContactInvitiationListState>(
        bloc: locator<ContactInvitationListCubit>(),
        listener: (context, state) {
          final listState = state.state.asData?.value;
          final data = generatorOutputV.asData?.value;

          if (listState != null && data != null) {
            final idx = listState.indexWhere((x) =>
                x.value.contactRequestInbox.recordKey.toVeilid() == data.$2);
            if (idx == -1) {
              // This invitation is gone, close it
              Navigator.pop(context);
            }
          }
        },
        child: PopControl(
            dismissible: !generatorOutputV.isLoading,
            child: Dialog(
                shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(
                        16 * scaleConfig.borderRadiusScale)),
                backgroundColor: Colors.white,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: cardsize,
                        maxWidth: cardsize,
                        minHeight: cardsize,
                        maxHeight: cardsize),
                    child: generatorOutputV.when(
                        loading: buildProgressIndicator,
                        data: (data) => Column(children: [
                              FittedBox(
                                      child: Text(
                                          translate('create_invitation_dialog'
                                              '.contact_invitation'),
                                          style: textTheme.headlineSmall!
                                              .copyWith(color: Colors.black)))
                                  .paddingAll(8),
                              FittedBox(
                                child: QrImageView.withQr(
                                    size: 300,
                                    qr: QrCode.fromUint8List(
                                        data: data.$1,
                                        errorCorrectLevel:
                                            QrErrorCorrectLevel.L)),
                              ).expanded(),
                              Text(message,
                                      softWrap: true,
                                      style: textTheme.labelLarge!
                                          .copyWith(color: Colors.black))
                                  .paddingAll(8),
                              Text(
                                      '${translate('create_invitation_dialog.fingerprint')}\n'
                                      '$fingerprint',
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: textTheme.labelSmall!.copyWith(
                                          color: Colors.black,
                                          fontFamily: 'Source Code Pro'))
                                  .paddingAll(2),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.copy),
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide()),
                                label: Text(translate(
                                    'create_invitation_dialog.copy_invitation')),
                                onPressed: () async {
                                  context.read<NotificationsCubit>().info(
                                      text: translate('create_invitation_dialog'
                                          '.invitation_copied'));
                                  await Clipboard.setData(ClipboardData(
                                      text: makeTextInvite(message, data.$1)));
                                },
                              ).paddingAll(16),
                            ]),
                        error: errorPage)))));
  }

  static Future<void> show({
    required BuildContext context,
    required Locator locator,
    required InvitationGeneratorCubit Function(BuildContext) create,
    required String message,
  }) async {
    final fingerprint =
        locator<AccountInfoCubit>().state.identityPublicKey.toString();

    await showPopControlDialog<void>(
        context: context,
        builder: (context) => BlocProvider(
            create: create,
            child: ContactInvitationDisplayDialog._(
              locator: locator,
              message: message,
              fingerprint: fingerprint,
            )));
  }
}
