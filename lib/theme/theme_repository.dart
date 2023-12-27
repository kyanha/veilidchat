// ignore_for_file: always_put_required_named_parameters_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'radix_generator.dart';
import 'theme_preference.dart';

////////////////////////////////////////////////////////////////////////

class ThemeRepository {
  ThemeRepository._({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        _themePreferences = defaultThemePreferences;

  final SharedPreferences _sharedPreferences;
  ThemePreferences _themePreferences;
  ThemeData? _cachedThemeData;

  /// Singleton instance of ThemeRepository
  static ThemeRepository? _instance;
  static Future<ThemeRepository> get instance async {
    if (_instance == null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      final instance = ThemeRepository._(sharedPreferences: sharedPreferences);
      await instance.load();
      _instance = instance;
    }
    return _instance!;
  }

  static bool get isPlatformDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  /// Defaults
  static ThemePreferences get defaultThemePreferences => const ThemePreferences(
        colorPreference: ColorPreference.vapor,
        brightnessPreference: BrightnessPreference.system,
        displayScale: 1,
      );

  /// Get theme preferences
  ThemePreferences get themePreferences => _themePreferences;

  /// Set theme preferences
  void setThemePreferences(ThemePreferences themePreferences) {
    _themePreferences = themePreferences;
    _cachedThemeData = null;
  }

  /// Load theme preferences from storage
  Future<void> load() async {
    final themePreferencesJson =
        _sharedPreferences.getString('themePreferences');

    ThemePreferences? newThemePreferences;
    if (themePreferencesJson != null) {
      try {
        newThemePreferences =
            ThemePreferences.fromJson(jsonDecode(themePreferencesJson));
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // ignore
      }
    }
    setThemePreferences(newThemePreferences ?? defaultThemePreferences);
  }

  /// Save theme preferences to storage
  Future<void> save() async {
    await _sharedPreferences.setString(
        'themePreferences', jsonEncode(_themePreferences.toJson()));
  }

  /// Get material 'ThemeData' for existinb
  ThemeData themeData() {
    final cachedThemeData = _cachedThemeData;
    if (cachedThemeData != null) {
      return cachedThemeData;
    }
    late final Brightness brightness;
    switch (_themePreferences.brightnessPreference) {
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
    switch (_themePreferences.colorPreference) {
      // Special cases
      case ColorPreference.contrast:
        // xxx do contrastGenerator
        themeData = radixGenerator(brightness, RadixThemeColor.grim);
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

    _cachedThemeData = themeData;
    return themeData;
  }
}
