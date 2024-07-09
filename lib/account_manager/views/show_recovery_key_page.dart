import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../layout/default_app_bar.dart';
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../../veilid_processor/veilid_processor.dart';

class ShowRecoveryKeyPage extends StatefulWidget {
  const ShowRecoveryKeyPage(
      {required WritableSuperIdentity writableSuperIdentity,
      required String name,
      super.key})
      : _writableSuperIdentity = writableSuperIdentity,
        _name = name;

  @override
  ShowRecoveryKeyPageState createState() => ShowRecoveryKeyPageState();

  final WritableSuperIdentity _writableSuperIdentity;
  final String _name;
}

class ShowRecoveryKeyPageState extends State<ShowRecoveryKeyPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.portraitOnly);
    });
  }

  Future<void> _shareRecoveryKey(
      BuildContext context, Uint8List recoveryKey, String name) async {
    setState(() {
      _isInAsyncCall = true;
    });

    final screenshotController = ScreenshotController();
    final bytes = await screenshotController.captureFromWidget(
      Container(
          color: Colors.white,
          width: 400,
          height: 400,
          child: _recoveryKeyWidget(context, recoveryKey, name)),
    );

    setState(() {
      _isInAsyncCall = false;
    });

    if (Platform.isLinux) {
      // Share plus doesn't do Linux yet
      await FileSaver.instance.saveFile(name: 'recovery_key.png', bytes: bytes);
    } else {
      final xfile = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'recovery_key.png',
      );
      await Share.shareXFiles([xfile]);
    }
  }

  static Future<void> _printRecoveryKey(
      BuildContext context, Uint8List recoveryKey, String name) async {
    final wrapped = await WidgetWrapper.fromWidget(
        context: context,
        widget: SizedBox(
            width: 400,
            height: 400,
            child: _recoveryKeyWidget(context, recoveryKey, name)),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
        pixelRatio: 3);

    final doc = pw.Document()
      ..addPage(pw.Page(
          build: (context) =>
              pw.Center(child: pw.Image(wrapped, width: 400)) // Center
          )); // Page

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static Widget _recoveryKeyWidget(
      BuildContext context, Uint8List recoveryKey, String name) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    //final scaleConfig = theme.extension<ScaleConfig>()!;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
              style: textTheme.headlineSmall!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              translate('show_recovery_key_page.recovery_key'))
          .paddingLTRB(16, 16, 16, 0),
      FittedBox(
              child: QrImageView.withQr(
                  size: 300,
                  qr: QrCode.fromUint8List(
                      data: recoveryKey,
                      errorCorrectLevel: QrErrorCorrectLevel.L)))
          .paddingLTRB(16, 16, 16, 8)
          .expanded(),
      Text(
              style: textTheme.labelMedium!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              name)
          .paddingLTRB(16, 8, 16, 24),
    ]);
  }

  static Widget _recoveryKeyDialog(
      BuildContext context, Uint8List recoveryKey, String name) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final cardsize =
        min<double>(MediaQuery.of(context).size.shortestSide - 48.0, 400);

    return Dialog(
        shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2),
            borderRadius:
                BorderRadius.circular(16 * scaleConfig.borderRadiusScale)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: cardsize,
                maxWidth: cardsize,
                minHeight: cardsize + 16,
                maxHeight: cardsize + 16),
            child: _recoveryKeyWidget(context, recoveryKey, name)));
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final scale = theme.extension<ScaleScheme>()!;
    // final scaleConfig = theme.extension<ScaleConfig>()!;

    final displayModalHUD = _isInAsyncCall;

    return StyledScaffold(
        // resizeToAvoidBottomInset: false,
        appBar: DefaultAppBar(
            title: Text(translate('show_recovery_key_page.titlebar')),
            actions: [
              const SignalStrengthMeterWidget(),
              IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: translate('menu.settings_tooltip'),
                  onPressed: () async {
                    await GoRouterHelper(context).push('/settings');
                  })
            ]),
        body: SingleChildScrollView(
            child: Column(children: [
          Text(
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  translate('show_recovery_key_page.instructions'))
              .paddingAll(24),
          ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Text(
                      softWrap: true,
                      textAlign: TextAlign.center,
                      translate('show_recovery_key_page.instructions_details')))
              .toCenter()
              .paddingLTRB(24, 0, 24, 24),
          Text(
                  textAlign: TextAlign.center,
                  translate('show_recovery_key_page.instructions_options'))
              .paddingLTRB(12, 0, 12, 24),
          OptionBox(
              instructions:
                  translate('show_recovery_key_page.instructions_print'),
              buttonIcon: Icons.print,
              buttonText: translate('show_recovery_key_page.print'),
              onClick: () {
                //
                singleFuture(this, () async {
                  await _printRecoveryKey(context,
                      widget._writableSuperIdentity.recoveryKey, widget._name);
                });

                setState(() {
                  _codeHandled = true;
                });
              }),
          OptionBox(
              instructions:
                  translate('show_recovery_key_page.instructions_view'),
              buttonIcon: Icons.edit_document,
              buttonText: translate('show_recovery_key_page.view'),
              onClick: () {
                //
                singleFuture(this, () async {
                  await showDialog<void>(
                      context: context,
                      builder: (context) => _recoveryKeyDialog(
                          context,
                          widget._writableSuperIdentity.recoveryKey,
                          widget._name));
                });

                setState(() {
                  _codeHandled = true;
                });
              }),
          OptionBox(
              instructions:
                  translate('show_recovery_key_page.instructions_share'),
              buttonIcon: Icons.ios_share,
              buttonText: translate('show_recovery_key_page.share'),
              onClick: () {
                //
                singleFuture(this, () async {
                  await _shareRecoveryKey(context,
                      widget._writableSuperIdentity.recoveryKey, widget._name);
                });

                setState(() {
                  _codeHandled = true;
                });
              }),
          Offstage(
              offstage: !_codeHandled,
              child: ElevatedButton(
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.canPop(context)
                              ? GoRouterHelper(context).pop()
                              : GoRouterHelper(context).go('/');
                        }
                      },
                      child: Text(translate('button.finish')).paddingAll(8))
                  .paddingAll(12))
        ]))).withModalHUD(context, displayModalHUD);
  }

  bool _codeHandled = false;
  bool _isInAsyncCall = false;
}
