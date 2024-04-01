// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ThemePreferences _$ThemePreferencesFromJson(Map<String, dynamic> json) {
  return _ThemePreferences.fromJson(json);
}

/// @nodoc
mixin _$ThemePreferences {
  BrightnessPreference get brightnessPreference =>
      throw _privateConstructorUsedError;
  ColorPreference get colorPreference => throw _privateConstructorUsedError;
  double get displayScale => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ThemePreferencesCopyWith<ThemePreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemePreferencesCopyWith<$Res> {
  factory $ThemePreferencesCopyWith(
          ThemePreferences value, $Res Function(ThemePreferences) then) =
      _$ThemePreferencesCopyWithImpl<$Res, ThemePreferences>;
  @useResult
  $Res call(
      {BrightnessPreference brightnessPreference,
      ColorPreference colorPreference,
      double displayScale});
}

/// @nodoc
class _$ThemePreferencesCopyWithImpl<$Res, $Val extends ThemePreferences>
    implements $ThemePreferencesCopyWith<$Res> {
  _$ThemePreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brightnessPreference = null,
    Object? colorPreference = null,
    Object? displayScale = null,
  }) {
    return _then(_value.copyWith(
      brightnessPreference: null == brightnessPreference
          ? _value.brightnessPreference
          : brightnessPreference // ignore: cast_nullable_to_non_nullable
              as BrightnessPreference,
      colorPreference: null == colorPreference
          ? _value.colorPreference
          : colorPreference // ignore: cast_nullable_to_non_nullable
              as ColorPreference,
      displayScale: null == displayScale
          ? _value.displayScale
          : displayScale // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ThemePreferencesImplCopyWith<$Res>
    implements $ThemePreferencesCopyWith<$Res> {
  factory _$$ThemePreferencesImplCopyWith(_$ThemePreferencesImpl value,
          $Res Function(_$ThemePreferencesImpl) then) =
      __$$ThemePreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BrightnessPreference brightnessPreference,
      ColorPreference colorPreference,
      double displayScale});
}

/// @nodoc
class __$$ThemePreferencesImplCopyWithImpl<$Res>
    extends _$ThemePreferencesCopyWithImpl<$Res, _$ThemePreferencesImpl>
    implements _$$ThemePreferencesImplCopyWith<$Res> {
  __$$ThemePreferencesImplCopyWithImpl(_$ThemePreferencesImpl _value,
      $Res Function(_$ThemePreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brightnessPreference = null,
    Object? colorPreference = null,
    Object? displayScale = null,
  }) {
    return _then(_$ThemePreferencesImpl(
      brightnessPreference: null == brightnessPreference
          ? _value.brightnessPreference
          : brightnessPreference // ignore: cast_nullable_to_non_nullable
              as BrightnessPreference,
      colorPreference: null == colorPreference
          ? _value.colorPreference
          : colorPreference // ignore: cast_nullable_to_non_nullable
              as ColorPreference,
      displayScale: null == displayScale
          ? _value.displayScale
          : displayScale // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ThemePreferencesImpl implements _ThemePreferences {
  const _$ThemePreferencesImpl(
      {required this.brightnessPreference,
      required this.colorPreference,
      required this.displayScale});

  factory _$ThemePreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThemePreferencesImplFromJson(json);

  @override
  final BrightnessPreference brightnessPreference;
  @override
  final ColorPreference colorPreference;
  @override
  final double displayScale;

  @override
  String toString() {
    return 'ThemePreferences(brightnessPreference: $brightnessPreference, colorPreference: $colorPreference, displayScale: $displayScale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemePreferencesImpl &&
            (identical(other.brightnessPreference, brightnessPreference) ||
                other.brightnessPreference == brightnessPreference) &&
            (identical(other.colorPreference, colorPreference) ||
                other.colorPreference == colorPreference) &&
            (identical(other.displayScale, displayScale) ||
                other.displayScale == displayScale));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, brightnessPreference, colorPreference, displayScale);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemePreferencesImplCopyWith<_$ThemePreferencesImpl> get copyWith =>
      __$$ThemePreferencesImplCopyWithImpl<_$ThemePreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThemePreferencesImplToJson(
      this,
    );
  }
}

abstract class _ThemePreferences implements ThemePreferences {
  const factory _ThemePreferences(
      {required final BrightnessPreference brightnessPreference,
      required final ColorPreference colorPreference,
      required final double displayScale}) = _$ThemePreferencesImpl;

  factory _ThemePreferences.fromJson(Map<String, dynamic> json) =
      _$ThemePreferencesImpl.fromJson;

  @override
  BrightnessPreference get brightnessPreference;
  @override
  ColorPreference get colorPreference;
  @override
  double get displayScale;
  @override
  @JsonKey(ignore: true)
  _$$ThemePreferencesImplCopyWith<_$ThemePreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
