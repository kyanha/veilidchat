import 'dart:math';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../layout/default_app_bar.dart';
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../../veilid_processor/veilid_processor.dart';

class ShowRecoveryKeyPage extends StatefulWidget {
  const ShowRecoveryKeyPage({required SecretKey secretKey, super.key})
      : _secretKey = secretKey;

  @override
  ShowRecoveryKeyPageState createState() => ShowRecoveryKeyPageState();

  final SecretKey _secretKey;
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

  Widget _recoveryKeyWidget(SecretKey _secretKey) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final cardsize =
        min<double>(MediaQuery.of(context).size.shortestSide - 48.0, 400);

    final phonoString = prettyPhonoString(
      encodePhono(_secretKey.decode()),
      wordsPerLine: 2,
    );
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
                minHeight: cardsize,
                maxHeight: cardsize),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                      style: textTheme.headlineSmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      translate('show_recovery_key_page.recovery_key'))
                  .paddingAll(32),
              Text(
                  style: textTheme.headlineSmall!.copyWith(
                      color: Colors.black, fontFamily: 'Source Code Pro'),
                  phonoString)
            ])));
  }

  Widget _optionBox(
      {required String instructions,
      required Icon buttonIcon,
      required String buttonText,
      required void Function() onClick}) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
                color: scale.primaryScale.subtleBackground,
                borderRadius:
                    BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
                border: Border.all(color: scale.primaryScale.border)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      style: theme.textTheme.labelMedium!
                          .copyWith(color: scale.primaryScale.appText),
                      softWrap: true,
                      textAlign: TextAlign.center,
                      instructions),
                  ElevatedButton(
                      onPressed: onClick,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        buttonIcon.paddingLTRB(0, 8, 12, 8),
                        Text(textAlign: TextAlign.center, buttonText)
                      ])).paddingLTRB(0, 12, 0, 0).toCenter()
                ]).paddingAll(12))
        .paddingLTRB(24, 0, 24, 12);
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final secretKey = widget._secretKey;
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

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
              .paddingLTRB(12, 0, 12, 12),
          _optionBox(
              instructions:
                  translate('show_recovery_key_page.instructions_print'),
              buttonIcon: const Icon(Icons.print),
              buttonText: translate('show_recovery_key_page.print'),
              onClick: () {
                //
                setState(() {
                  _codeHandled = true;
                });
              }),
          _optionBox(
              instructions:
                  translate('show_recovery_key_page.instructions_view'),
              buttonIcon: const Icon(Icons.edit_document),
              buttonText: translate('show_recovery_key_page.view'),
              onClick: () {
                //
                singleFuture(this, () async {
                  await showDialog<void>(
                      context: context,
                      builder: (context) => _recoveryKeyWidget(secretKey));
                });

                setState(() {
                  _codeHandled = true;
                });
              }),
          _optionBox(
              instructions:
                  translate('show_recovery_key_page.instructions_share'),
              buttonIcon: const Icon(Icons.ios_share),
              buttonText: translate('show_recovery_key_page.share'),
              onClick: () {
                //
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
        ])));
  }

  bool _codeHandled = false;
}
