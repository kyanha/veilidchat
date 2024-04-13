import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../views/widget_helpers.dart';
import 'contrast_generator.dart';
import 'radix_generator.dart';

part 'theme_preference.freezed.dart';
part 'theme_preference.g.dart';

// Theme supports light and dark mode, optionally selected by the
// operating system
enum BrightnessPreference {
  system,
  light,
  dark;

  factory BrightnessPreference.fromJson(dynamic j) =>
      BrightnessPreference.values.byName((j as String).toCamelCase());

  String toJson() => name.toPascalCase();
}

// Theme supports multiple color variants based on 'Radix'
enum ColorPreference {
  // Radix Colors
  scarlet,
  babydoll,
  vapor,
  gold,
  garden,
  forest,
  arctic,
  lapis,
  eggplant,
  lime,
  grim,
  // Accessible Colors
  contrast;

  factory ColorPreference.fromJson(dynamic j) =>
      ColorPreference.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();
}

@freezed
class ThemePreferences with _$ThemePreferences {
  const factory ThemePreferences({
    required BrightnessPreference brightnessPreference,
    required ColorPreference colorPreference,
    required double displayScale,
  }) = _ThemePreferences;

  factory ThemePreferences.fromJson(dynamic json) =>
      _$ThemePreferencesFromJson(json as Map<String, dynamic>);

  static const ThemePreferences defaults = ThemePreferences(
    colorPreference: ColorPreference.vapor,
    brightnessPreference: BrightnessPreference.system,
    displayScale: 1,
  );
}

extension ThemePreferencesExt on ThemePreferences {
  /// Get material 'ThemeData' for existinb
  ThemeData themeData() {
    late final Brightness brightness;
    switch (brightnessPreference) {
      case BrightnessPreference.system:
        if (isPlatformDark) {
          brightness = Brightness.dark;
        } else {
          brightness = Brightness.light;
        }
      case BrightnessPreference.light:
        brightness = Brightness.light;
      case BrightnessPreference.dark:
        brightness = Brightness.dark;
    }

    late final ThemeData themeData;
    switch (colorPreference) {
      // Special cases
      case ColorPreference.contrast:
        // xxx do contrastGenerator
        themeData = contrastGenerator(brightness);
      // Generate from Radix
      case ColorPreference.scarlet:
        themeData = radixGenerator(brightness, RadixThemeColor.scarlet);
      case ColorPreference.babydoll:
        themeData = radixGenerator(brightness, RadixThemeColor.babydoll);
      case ColorPreference.vapor:
        themeData = radixGenerator(brightness, RadixThemeColor.vapor);
      case ColorPreference.gold:
        themeData = radixGenerator(brightness, RadixThemeColor.gold);
      case ColorPreference.garden:
        themeData = radixGenerator(brightness, RadixThemeColor.garden);
      case ColorPreference.forest:
        themeData = radixGenerator(brightness, RadixThemeColor.forest);
      case ColorPreference.arctic:
        themeData = radixGenerator(brightness, RadixThemeColor.arctic);
      case ColorPreference.lapis:
        themeData = radixGenerator(brightness, RadixThemeColor.lapis);
      case ColorPreference.eggplant:
        themeData = radixGenerator(brightness, RadixThemeColor.eggplant);
      case ColorPreference.lime:
        themeData = radixGenerator(brightness, RadixThemeColor.lime);
      case ColorPreference.grim:
        themeData = radixGenerator(brightness, RadixThemeColor.grim);
    }

    return themeData;
  }
}
