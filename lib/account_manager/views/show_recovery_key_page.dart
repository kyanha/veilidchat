import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../layout/default_app_bar.dart';
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

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final secretKey = widget._secretKey;

    return Scaffold(
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
        body: Column(children: [
          Text('ASS: $secretKey'),
          ElevatedButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.canPop(context)
                      ? GoRouterHelper(context).pop()
                      : GoRouterHelper(context).go('/');
                }
              },
              child: Text(translate('button.finish')))
        ]).paddingSymmetric(horizontal: 24, vertical: 8));
  }
}
