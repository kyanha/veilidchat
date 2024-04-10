import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../settings/settings.dart';
import '../models/models.dart';

const String formFieldTheme = 'theme';

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

Widget buildSettingsPageColorPreferences(
    {required BuildContext context, required void Function() onChanged}) {
  final preferencesRepository = PreferencesRepository.instance;
  final themePreferences = preferencesRepository.value.themePreferences;
  return ThemeSwitcher.withTheme(
      builder: (_, switcher, theme) => FormBuilderDropdown(
          name: formFieldTheme,
          decoration: InputDecoration(
              label: Text(translate('settings_page.color_theme'))),
          items: _getThemeDropdownItems(),
          initialValue: themePreferences.colorPreference,
          onChanged: (value) async {
            final newThemePrefs = themePreferences.copyWith(
                colorPreference: value as ColorPreference);
            final newPrefs = preferencesRepository.value
                .copyWith(themePreferences: newThemePrefs);

            await preferencesRepository.set(newPrefs);
            switcher.changeTheme(theme: newThemePrefs.themeData());
            onChanged();
          }));
}
