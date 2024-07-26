// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LockPreferenceImpl _$$LockPreferenceImplFromJson(Map<String, dynamic> json) =>
    _$LockPreferenceImpl(
      inactivityLockSecs: (json['inactivity_lock_secs'] as num?)?.toInt() ?? 0,
      lockWhenSwitching: json['lock_when_switching'] as bool? ?? false,
      lockWithSystemLock: json['lock_with_system_lock'] as bool? ?? false,
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
      themePreference: json['theme_preference'] == null
          ? ThemePreferences.defaults
          : ThemePreferences.fromJson(json['theme_preference']),
      languagePreference: json['language_preference'] == null
          ? LanguagePreference.defaults
          : LanguagePreference.fromJson(json['language_preference']),
      lockPreference: json['lock_preference'] == null
          ? LockPreference.defaults
          : LockPreference.fromJson(json['lock_preference']),
      notificationsPreference: json['notifications_preference'] == null
          ? NotificationsPreference.defaults
          : NotificationsPreference.fromJson(json['notifications_preference']),
    );

Map<String, dynamic> _$$PreferencesImplToJson(_$PreferencesImpl instance) =>
    <String, dynamic>{
      'theme_preference': instance.themePreference.toJson(),
      'language_preference': instance.languagePreference.toJson(),
      'lock_preference': instance.lockPreference.toJson(),
      'notifications_preference': instance.notificationsPreference.toJson(),
    };
