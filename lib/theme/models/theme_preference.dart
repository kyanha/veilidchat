import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../views/widget_helpers.dart';
import 'contrast_generator.dart';
import 'radix_generator.dart';
import 'scale_scheme.dart';

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
  elite,
  contrast;

  factory ColorPreference.fromJson(dynamic j) =>
      ColorPreference.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();
}

@freezed
class ThemePreferences with _$ThemePreferences {
  const factory ThemePreferences({
    @Default(BrightnessPreference.system)
    BrightnessPreference brightnessPreference,
    @Default(ColorPreference.vapor) ColorPreference colorPreference,
    @Default(1) double displayScale,
  }) = _ThemePreferences;

  factory ThemePreferences.fromJson(dynamic json) =>
      _$ThemePreferencesFromJson(json as Map<String, dynamic>);

  static const ThemePreferences defaults = ThemePreferences();
}

extension ThemePreferencesExt on ThemePreferences {
  /// Get material 'ThemeData' for existing theme
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
        themeData = contrastGenerator(
          brightness: brightness,
          scaleConfig: ScaleConfig(
              useVisualIndicators: true,
              preferBorders: false,
              borderRadiusScale: 1),
          primaryFront: Colors.black,
          primaryBack: Colors.white,
          secondaryFront: Colors.black,
          secondaryBack: Colors.white,
          tertiaryFront: Colors.black,
          tertiaryBack: Colors.white,
          grayFront: Colors.black,
          grayBack: Colors.white,
          errorFront: Colors.black,
          errorBack: Colors.white,
        );
      case ColorPreference.elite:
        themeData = brightness == Brightness.light
            ? contrastGenerator(
                brightness: Brightness.light,
                scaleConfig: ScaleConfig(
                    useVisualIndicators: true,
                    preferBorders: true,
                    borderRadiusScale: 0.2),
                primaryFront: const Color(0xFF000000),
                primaryBack: const Color(0xFF00FF00),
                secondaryFront: const Color(0xFF000000),
                secondaryBack: const Color(0xFF00FFFF),
                tertiaryFront: const Color(0xFF000000),
                tertiaryBack: const Color(0xFFFF00FF),
                grayFront: const Color(0xFF000000),
                grayBack: const Color(0xFFFFFFFF),
                errorFront: const Color(0xFFC0C0C0),
                errorBack: const Color(0xFF0000FF),
                customTextTheme: makeMonoSpaceTextTheme(Brightness.light))
            : contrastGenerator(
                brightness: Brightness.dark,
                scaleConfig: ScaleConfig(
                    useVisualIndicators: true,
                    preferBorders: true,
                    borderRadiusScale: 0.5),
                primaryFront: const Color(0xFF000000),
                primaryBack: const Color(0xFF00FF00),
                secondaryFront: const Color(0xFF000000),
                secondaryBack: const Color(0xFF00FFFF),
                tertiaryFront: const Color(0xFF000000),
                tertiaryBack: const Color(0xFFFF00FF),
                grayFront: const Color(0xFF000000),
                grayBack: const Color(0xFFFFFFFF),
                errorFront: const Color(0xFF0000FF),
                errorBack: const Color(0xFFC0C0C0),
                customTextTheme: makeMonoSpaceTextTheme(Brightness.dark),
              );
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
