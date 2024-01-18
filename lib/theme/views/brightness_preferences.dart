import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../settings/settings.dart';
import '../models/models.dart';

const String formFieldBrightness = 'brightness';

List<DropdownMenuItem<dynamic>> _getBrightnessDropdownItems() {
  const brightnessPrefs = BrightnessPreference.values;
  final brightnessNames = {
    BrightnessPreference.system: translate('brightness.system'),
    BrightnessPreference.light: translate('brightness.light'),
    BrightnessPreference.dark: translate('brightness.dark')
  };

  return brightnessPrefs
      .map((e) => DropdownMenuItem(value: e, child: Text(brightnessNames[e]!)))
      .toList();
}

Widget buildSettingsPageBrightnessPreferences(
    {required void Function() onChanged}) {
  final preferencesRepository = PreferencesRepository.instance;
  final themePreferences = preferencesRepository.value.themePreferences;
  return ThemeSwitcher.withTheme(
      builder: (_, switcher, theme) => FormBuilderDropdown(
          name: formFieldBrightness,
          decoration: InputDecoration(
              label: Text(translate('settings_page.brightness_mode'))),
          items: _getBrightnessDropdownItems(),
          initialValue: themePreferences.brightnessPreference,
          onChanged: (value) async {
            final newThemePrefs = themePreferences.copyWith(
                brightnessPreference: value as BrightnessPreference);
            final newPrefs = preferencesRepository.value
                .copyWith(themePreferences: newThemePrefs);

            await preferencesRepository.set(newPrefs);
            switcher.changeTheme(theme: newThemePrefs.themeData());
            onChanged();
          }));
}
