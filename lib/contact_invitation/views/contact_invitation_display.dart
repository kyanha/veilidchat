import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../tools/tools.dart';

class InvitationGeneratorCubit extends FutureCubit<Uint8List> {
  InvitationGeneratorCubit(super.fut);
}

class ContactInvitationDisplayDialog extends StatefulWidget {
  const ContactInvitationDisplayDialog({
    required this.message,
    super.key,
  });

  final String message;

  @override
  ContactInvitationDisplayDialogState createState() =>
      ContactInvitationDisplayDialogState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
  }
}

class ContactInvitationDisplayDialogState
    extends State<ContactInvitationDisplayDialog> {
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
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

    return Dialog(
        backgroundColor: Colors.white,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: cardsize,
                maxWidth: cardsize,
                minHeight: cardsize,
                maxHeight: cardsize),
            child: signedContactInvitationBytesV.when(
                loading: buildProgressIndicator,
                data: (data) => Form(
                    key: formKey,
                    child: Column(children: [
                      FittedBox(
                              child: Text(
                                  translate(
                                      'send_invite_dialog.contact_invitation'),
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
                      Text(widget.message,
                              softWrap: true,
                              style: textTheme.labelLarge!
                                  .copyWith(color: Colors.black))
                          .paddingAll(8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: Text(
                            translate('send_invite_dialog.copy_invitation')),
                        onPressed: () async {
                          showInfoToast(
                              context,
                              translate(
                                  'send_invite_dialog.invitation_copied'));
                          await Clipboard.setData(ClipboardData(
                              text: makeTextInvite(widget.message, data)));
                        },
                      ).paddingAll(16),
                    ])),
                error: (e, s) {
                  Navigator.of(context).pop();
                  showErrorToast(context,
                      translate('send_invite_dialog.failed_to_generate'));
                  return const Text('');
                })));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', formKey));
  }
}
