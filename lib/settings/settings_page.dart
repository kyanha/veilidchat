import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../layout/default_app_bar.dart';
import '../theme/theme.dart';
import '../tools/tools.dart';
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
          builder: (context, state) => ThemeSwitchingArea(
                  child: Scaffold(
                // resizeToAvoidBottomInset: false,
                appBar: DefaultAppBar(
                    title: Text(translate('settings_page.titlebar')),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop<void>(),
                    ),
                    actions: <Widget>[
                      const SignalStrengthMeterWidget()
                          .paddingLTRB(16, 0, 16, 0),
                    ]),

                body: FormBuilder(
                  key: _formKey,
                  child: ListView(
                    children: [
                      buildSettingsPageColorPreferences(
                          onChanged: () => setState(() {})),
                      buildSettingsPageBrightnessPreferences(
                          onChanged: () => setState(() {})),
                    ],
                  ),
                ).paddingSymmetric(horizontal: 24, vertical: 8),
              )));
}
