import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
}
