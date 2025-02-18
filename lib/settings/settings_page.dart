import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';

import '../layout/default_app_bar.dart';
import '../notifications/notifications.dart';
import '../theme/theme.dart';
import '../veilid_processor/veilid_processor.dart';
import 'settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  static const String formFieldTheme = 'theme';
  static const String formFieldBrightness = 'brightness';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      AsyncBlocBuilder<PreferencesCubit, Preferences>(
          builder: (context, state) => StyledScaffold(
              appBar: DefaultAppBar(
                  title: Text(translate('settings_page.titlebar')),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => GoRouterHelper(context).pop(),
                  ),
                  actions: <Widget>[
                    const SignalStrengthMeterWidget().paddingLTRB(16, 0, 16, 0),
                  ]),
              body: ThemeSwitchingArea(
                child: FormBuilder(
                  key: _formKey,
                  child: ListView(
                    children: [
                      buildSettingsPageColorPreferences(
                              context: context,
                              onChanged: () => setState(() {}))
                          .paddingLTRB(0, 8, 0, 0),
                      buildSettingsPageBrightnessPreferences(
                          context: context, onChanged: () => setState(() {})),
                      buildSettingsPageNotificationPreferences(
                          context: context, onChanged: () => setState(() {})),
                    ].map((x) => x.paddingLTRB(0, 0, 0, 8)).toList(),
                  ),
                ).paddingSymmetric(horizontal: 24, vertical: 16),
              )));
}
