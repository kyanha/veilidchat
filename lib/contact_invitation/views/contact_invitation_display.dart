import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../contact_invitation.dart';

class ContactInvitationDisplayDialog extends StatelessWidget {
  const ContactInvitationDisplayDialog._({
    required this.modalContext,
    required this.message,
  });

  final BuildContext modalContext;
  final String message;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('message', message))
      ..add(DiagnosticsProperty<BuildContext>('modalContext', modalContext));
  }

  String makeTextInvite(String message, Uint8List data) {
    final invite = StringUtils.addCharAtPosition(
        base64UrlNoPadEncode(data), '\n', 40,
        repeat: true);
    final msg = message.isNotEmpty ? '$message\n' : '';
    return '$msg'
        '--- BEGIN VEILIDCHAT CONTACT INVITE ----\n'
        '$invite\n'
        '---- END VEILIDCHAT CONTACT INVITE -----\n';
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;

    final signedContactInvitationBytesV =
        context.watch<InvitationGeneratorCubit>().state;

    final cardsize =
        min<double>(MediaQuery.of(context).size.shortestSide - 48.0, 400);

    return PopControl(
        dismissible: !signedContactInvitationBytesV.isLoading,
        child: Dialog(
            backgroundColor: Colors.white,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: cardsize,
                    maxWidth: cardsize,
                    minHeight: cardsize,
                    maxHeight: cardsize),
                child: signedContactInvitationBytesV.when(
                    loading: buildProgressIndicator,
                    data: (data) => Column(children: [
                          FittedBox(
                                  child: Text(
                                      translate(
                                          'create_invitation_dialog.contact_invitation'),
                                      style: textTheme.headlineSmall!
                                          .copyWith(color: Colors.black)))
                              .paddingAll(8),
                          FittedBox(
                                  child: QrImageView.withQr(
                                      size: 300,
                                      qr: QrCode.fromUint8List(
                                          data: data,
                                          errorCorrectLevel:
                                              QrErrorCorrectLevel.L)))
                              .expanded(),
                          Text(message,
                                  softWrap: true,
                                  style: textTheme.labelLarge!
                                      .copyWith(color: Colors.black))
                              .paddingAll(8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.copy),
                            label: Text(translate(
                                'create_invitation_dialog.copy_invitation')),
                            onPressed: () async {
                              showInfoToast(
                                  context,
                                  translate(
                                      'create_invitation_dialog.invitation_copied'));
                              await Clipboard.setData(ClipboardData(
                                  text: makeTextInvite(message, data)));
                            },
                          ).paddingAll(16),
                        ]),
                    error: errorPage))));
  }

  static Future<void> show(
      {required BuildContext context,
      required InvitationGeneratorCubit Function(BuildContext) create,
      required String message}) async {
    await showPopControlDialog<void>(
        context: context,
        builder: (context) => BlocProvider(
            create: create,
            child: ContactInvitationDisplayDialog._(
              modalContext: context,
              message: message,
            )));
  }
}
