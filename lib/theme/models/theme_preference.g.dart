// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThemePreferencesImpl _$$ThemePreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$ThemePreferencesImpl(
      brightnessPreference: json['brightness_preference'] == null
          ? BrightnessPreference.system
          : BrightnessPreference.fromJson(json['brightness_preference']),
      colorPreference: json['color_preference'] == null
          ? ColorPreference.vapor
          : ColorPreference.fromJson(json['color_preference']),
      displayScale: (json['display_scale'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$$ThemePreferencesImplToJson(
        _$ThemePreferencesImpl instance) =>
    <String, dynamic>{
      'brightness_preference': instance.brightnessPreference.toJson(),
      'color_preference': instance.colorPreference.toJson(),
      'display_scale': instance.displayScale,
    };
