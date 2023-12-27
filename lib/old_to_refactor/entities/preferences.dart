import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';
part 'preferences.g.dart';

// Lock preference changes how frequently the messenger locks its
// interface and requires the identitySecretKey to be entered (pin/password/etc)
@freezed
class LockPreference with _$LockPreference {
  const factory LockPreference({
    required int inactivityLockSecs,
    required bool lockWhenSwitching,
    required bool lockWithSystemLock,
  }) = _LockPreference;

  factory LockPreference.fromJson(dynamic json) =>
      _$LockPreferenceFromJson(json as Map<String, dynamic>);
}

// Theme supports multiple translations
enum LanguagePreference {
  englishUS;

  factory LanguagePreference.fromJson(dynamic j) =>
      LanguagePreference.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();
}

// Preferences are stored in a table locally and globally affect all
// accounts imported/added and the app in general
@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    required ThemePreferences themePreferences,
    required LanguagePreference language,
    required LockPreference locking,
  }) = _Preferences;

  factory Preferences.fromJson(dynamic json) =>
      _$PreferencesFromJson(json as Map<String, dynamic>);
}
