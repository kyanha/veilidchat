// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LockPreferenceImpl _$$LockPreferenceImplFromJson(Map<String, dynamic> json) =>
    _$LockPreferenceImpl(
      inactivityLockSecs: json['inactivity_lock_secs'] as int,
      lockWhenSwitching: json['lock_when_switching'] as bool,
      lockWithSystemLock: json['lock_with_system_lock'] as bool,
    );

Map<String, dynamic> _$$LockPreferenceImplToJson(
        _$LockPreferenceImpl instance) =>
    <String, dynamic>{
      'inactivity_lock_secs': instance.inactivityLockSecs,
      'lock_when_switching': instance.lockWhenSwitching,
      'lock_with_system_lock': instance.lockWithSystemLock,
    };

_$PreferencesImpl _$$PreferencesImplFromJson(Map<String, dynamic> json) =>
    _$PreferencesImpl(
      themePreferences: ThemePreferences.fromJson(json['theme_preferences']),
      language: LanguagePreference.fromJson(json['language']),
      locking: LockPreference.fromJson(json['locking']),
    );

Map<String, dynamic> _$$PreferencesImplToJson(_$PreferencesImpl instance) =>
    <String, dynamic>{
      'theme_preferences': instance.themePreferences.toJson(),
      'language': instance.language.toJson(),
      'locking': instance.locking.toJson(),
    };
