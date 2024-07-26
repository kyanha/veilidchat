import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../notifications/notifications.dart';
import '../../theme/theme.dart';

part 'preferences.freezed.dart';
part 'preferences.g.dart';

// Lock preference changes how frequently the messenger locks its
// interface and requires the identitySecretKey to be entered (pin/password/etc)
@freezed
class LockPreference with _$LockPreference {
  const factory LockPreference({
    @Default(0) int inactivityLockSecs,
    @Default(false) bool lockWhenSwitching,
    @Default(false) bool lockWithSystemLock,
  }) = _LockPreference;

  factory LockPreference.fromJson(dynamic json) =>
      _$LockPreferenceFromJson(json as Map<String, dynamic>);

  static const LockPreference defaults = LockPreference();
}

// Theme supports multiple translations
enum LanguagePreference {
  englishUs;

  factory LanguagePreference.fromJson(dynamic j) =>
      LanguagePreference.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();

  static const LanguagePreference defaults = LanguagePreference.englishUs;
}

// Preferences are stored in a table locally and globally affect all
// accounts imported/added and the app in general
@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    @Default(ThemePreferences.defaults) ThemePreferences themePreference,
    @Default(LanguagePreference.defaults) LanguagePreference languagePreference,
    @Default(LockPreference.defaults) LockPreference lockPreference,
    @Default(NotificationsPreference.defaults)
    NotificationsPreference notificationsPreference,
  }) = _Preferences;

  factory Preferences.fromJson(dynamic json) =>
      _$PreferencesFromJson(json as Map<String, dynamic>);

  static const Preferences defaults = Preferences();
}
