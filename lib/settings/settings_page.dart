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

  List<DropdownMenuItem<dynamic>> _getThemeDropdownItems() {
    const colorPrefs = ColorPreference.values;
    final colorNames = {
      ColorPreference.scarlet: translate('themes.scarlet'),
      ColorPreference.vapor: translate('themes.vapor'),
      ColorPreference.babydoll: translate('themes.babydoll'),
      ColorPreference.gold: translate('themes.gold'),
      ColorPreference.garden: translate('themes.garden'),
      ColorPreference.forest: translate('themes.forest'),
      ColorPreference.arctic: translate('themes.arctic'),
      ColorPreference.lapis: translate('themes.lapis'),
      ColorPreference.eggplant: translate('themes.eggplant'),
      ColorPreference.lime: translate('themes.lime'),
      ColorPreference.grim: translate('themes.grim'),
      ColorPreference.contrast: translate('themes.contrast')
    };

    return colorPrefs
        .map((e) => DropdownMenuItem(value: e, child: Text(colorNames[e]!)))
        .toList();
  }

  List<DropdownMenuItem<dynamic>> _getBrightnessDropdownItems() {
    const brightnessPrefs = BrightnessPreference.values;
    final brightnessNames = {
      BrightnessPreference.system: translate('brightness.system'),
      BrightnessPreference.light: translate('brightness.light'),
      BrightnessPreference.dark: translate('brightness.dark')
    };

    return brightnessPrefs
        .map(
            (e) => DropdownMenuItem(value: e, child: Text(brightnessNames[e]!)))
        .toList();
  }

  @override
  Widget build(BuildContext context) => AsyncBlocBuilder<PreferencesCubit,
          Preferences>(
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
                  const SignalStrengthMeterWidget().paddingLTRB(16, 0, 16, 0),
                ]),

            body: FormBuilder(
              key: _formKey,
              child: ListView(
                children: [
                  ThemeSwitcher.withTheme(
                      builder: (_, switcher, theme) => FormBuilderDropdown(
                          name: formFieldTheme,
                          decoration: InputDecoration(
                              label:
                                  Text(translate('settings_page.color_theme'))),
                          items: _getThemeDropdownItems(),
                          initialValue: state.themePreferences.colorPreference,
                          onChanged: (value) async {
                            final newPrefs = state.copyWith(
                                themePreferences: state.themePreferences
                                    .copyWith(
                                        colorPreference:
                                            value as ColorPreference));
                            switcher.changeTheme(
                                theme: newPrefs.themePreferences.themeData());
                            await PreferencesRepository.instance.set(newPrefs);
                            setState(() {});
                          })),
                  ThemeSwitcher.withTheme(
                      builder: (_, switcher, theme) => FormBuilderDropdown(
                          name: formFieldBrightness,
                          decoration: InputDecoration(
                              label: Text(
                                  translate('settings_page.brightness_mode'))),
                          items: _getBrightnessDropdownItems(),
                          initialValue:
                              state.themePreferences.brightnessPreference,
                          onChanged: (value) async {
                            final newPrefs = state.copyWith(
                                themePreferences: state.themePreferences
                                    .copyWith(
                                        brightnessPreference:
                                            value as BrightnessPreference));
                            switcher.changeTheme(
                                theme: newPrefs.themePreferences.themeData());
                            await PreferencesRepository.instance.set(newPrefs);
                            setState(() {});
                          })),
                ],
              ),
            ).paddingSymmetric(horizontal: 24, vertical: 8),
          )));
}
