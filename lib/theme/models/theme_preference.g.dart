// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThemePreferencesImpl _$$ThemePreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$ThemePreferencesImpl(
      brightnessPreference:
          BrightnessPreference.fromJson(json['brightness_preference']),
      colorPreference: ColorPreference.fromJson(json['color_preference']),
      displayScale: (json['display_scale'] as num).toDouble(),
    );

Map<String, dynamic> _$$ThemePreferencesImplToJson(
        _$ThemePreferencesImpl instance) =>
    <String, dynamic>{
      'brightness_preference': instance.brightnessPreference.toJson(),
      'color_preference': instance.colorPreference.toJson(),
      'display_scale': instance.displayScale,
    };
