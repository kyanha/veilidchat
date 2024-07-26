// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LockPreference _$LockPreferenceFromJson(Map<String, dynamic> json) {
  return _LockPreference.fromJson(json);
}

/// @nodoc
mixin _$LockPreference {
  int get inactivityLockSecs => throw _privateConstructorUsedError;
  bool get lockWhenSwitching => throw _privateConstructorUsedError;
  bool get lockWithSystemLock => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LockPreferenceCopyWith<LockPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LockPreferenceCopyWith<$Res> {
  factory $LockPreferenceCopyWith(
          LockPreference value, $Res Function(LockPreference) then) =
      _$LockPreferenceCopyWithImpl<$Res, LockPreference>;
  @useResult
  $Res call(
      {int inactivityLockSecs,
      bool lockWhenSwitching,
      bool lockWithSystemLock});
}

/// @nodoc
class _$LockPreferenceCopyWithImpl<$Res, $Val extends LockPreference>
    implements $LockPreferenceCopyWith<$Res> {
  _$LockPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inactivityLockSecs = null,
    Object? lockWhenSwitching = null,
    Object? lockWithSystemLock = null,
  }) {
    return _then(_value.copyWith(
      inactivityLockSecs: null == inactivityLockSecs
          ? _value.inactivityLockSecs
          : inactivityLockSecs // ignore: cast_nullable_to_non_nullable
              as int,
      lockWhenSwitching: null == lockWhenSwitching
          ? _value.lockWhenSwitching
          : lockWhenSwitching // ignore: cast_nullable_to_non_nullable
              as bool,
      lockWithSystemLock: null == lockWithSystemLock
          ? _value.lockWithSystemLock
          : lockWithSystemLock // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LockPreferenceImplCopyWith<$Res>
    implements $LockPreferenceCopyWith<$Res> {
  factory _$$LockPreferenceImplCopyWith(_$LockPreferenceImpl value,
          $Res Function(_$LockPreferenceImpl) then) =
      __$$LockPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int inactivityLockSecs,
      bool lockWhenSwitching,
      bool lockWithSystemLock});
}

/// @nodoc
class __$$LockPreferenceImplCopyWithImpl<$Res>
    extends _$LockPreferenceCopyWithImpl<$Res, _$LockPreferenceImpl>
    implements _$$LockPreferenceImplCopyWith<$Res> {
  __$$LockPreferenceImplCopyWithImpl(
      _$LockPreferenceImpl _value, $Res Function(_$LockPreferenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inactivityLockSecs = null,
    Object? lockWhenSwitching = null,
    Object? lockWithSystemLock = null,
  }) {
    return _then(_$LockPreferenceImpl(
      inactivityLockSecs: null == inactivityLockSecs
          ? _value.inactivityLockSecs
          : inactivityLockSecs // ignore: cast_nullable_to_non_nullable
              as int,
      lockWhenSwitching: null == lockWhenSwitching
          ? _value.lockWhenSwitching
          : lockWhenSwitching // ignore: cast_nullable_to_non_nullable
              as bool,
      lockWithSystemLock: null == lockWithSystemLock
          ? _value.lockWithSystemLock
          : lockWithSystemLock // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LockPreferenceImpl implements _LockPreference {
  const _$LockPreferenceImpl(
      {this.inactivityLockSecs = 0,
      this.lockWhenSwitching = false,
      this.lockWithSystemLock = false});

  factory _$LockPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$LockPreferenceImplFromJson(json);

  @override
  @JsonKey()
  final int inactivityLockSecs;
  @override
  @JsonKey()
  final bool lockWhenSwitching;
  @override
  @JsonKey()
  final bool lockWithSystemLock;

  @override
  String toString() {
    return 'LockPreference(inactivityLockSecs: $inactivityLockSecs, lockWhenSwitching: $lockWhenSwitching, lockWithSystemLock: $lockWithSystemLock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LockPreferenceImpl &&
            (identical(other.inactivityLockSecs, inactivityLockSecs) ||
                other.inactivityLockSecs == inactivityLockSecs) &&
            (identical(other.lockWhenSwitching, lockWhenSwitching) ||
                other.lockWhenSwitching == lockWhenSwitching) &&
            (identical(other.lockWithSystemLock, lockWithSystemLock) ||
                other.lockWithSystemLock == lockWithSystemLock));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, inactivityLockSecs, lockWhenSwitching, lockWithSystemLock);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LockPreferenceImplCopyWith<_$LockPreferenceImpl> get copyWith =>
      __$$LockPreferenceImplCopyWithImpl<_$LockPreferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LockPreferenceImplToJson(
      this,
    );
  }
}

abstract class _LockPreference implements LockPreference {
  const factory _LockPreference(
      {final int inactivityLockSecs,
      final bool lockWhenSwitching,
      final bool lockWithSystemLock}) = _$LockPreferenceImpl;

  factory _LockPreference.fromJson(Map<String, dynamic> json) =
      _$LockPreferenceImpl.fromJson;

  @override
  int get inactivityLockSecs;
  @override
  bool get lockWhenSwitching;
  @override
  bool get lockWithSystemLock;
  @override
  @JsonKey(ignore: true)
  _$$LockPreferenceImplCopyWith<_$LockPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Preferences _$PreferencesFromJson(Map<String, dynamic> json) {
  return _Preferences.fromJson(json);
}

/// @nodoc
mixin _$Preferences {
  ThemePreferences get themePreference => throw _privateConstructorUsedError;
  LanguagePreference get languagePreference =>
      throw _privateConstructorUsedError;
  LockPreference get lockPreference => throw _privateConstructorUsedError;
  NotificationsPreference get notificationsPreference =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreferencesCopyWith<Preferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreferencesCopyWith<$Res> {
  factory $PreferencesCopyWith(
          Preferences value, $Res Function(Preferences) then) =
      _$PreferencesCopyWithImpl<$Res, Preferences>;
  @useResult
  $Res call(
      {ThemePreferences themePreference,
      LanguagePreference languagePreference,
      LockPreference lockPreference,
      NotificationsPreference notificationsPreference});

  $ThemePreferencesCopyWith<$Res> get themePreference;
  $LockPreferenceCopyWith<$Res> get lockPreference;
  $NotificationsPreferenceCopyWith<$Res> get notificationsPreference;
}

/// @nodoc
class _$PreferencesCopyWithImpl<$Res, $Val extends Preferences>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themePreference = null,
    Object? languagePreference = null,
    Object? lockPreference = null,
    Object? notificationsPreference = null,
  }) {
    return _then(_value.copyWith(
      themePreference: null == themePreference
          ? _value.themePreference
          : themePreference // ignore: cast_nullable_to_non_nullable
              as ThemePreferences,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as LanguagePreference,
      lockPreference: null == lockPreference
          ? _value.lockPreference
          : lockPreference // ignore: cast_nullable_to_non_nullable
              as LockPreference,
      notificationsPreference: null == notificationsPreference
          ? _value.notificationsPreference
          : notificationsPreference // ignore: cast_nullable_to_non_nullable
              as NotificationsPreference,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ThemePreferencesCopyWith<$Res> get themePreference {
    return $ThemePreferencesCopyWith<$Res>(_value.themePreference, (value) {
      return _then(_value.copyWith(themePreference: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LockPreferenceCopyWith<$Res> get lockPreference {
    return $LockPreferenceCopyWith<$Res>(_value.lockPreference, (value) {
      return _then(_value.copyWith(lockPreference: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationsPreferenceCopyWith<$Res> get notificationsPreference {
    return $NotificationsPreferenceCopyWith<$Res>(
        _value.notificationsPreference, (value) {
      return _then(_value.copyWith(notificationsPreference: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PreferencesImplCopyWith<$Res>
    implements $PreferencesCopyWith<$Res> {
  factory _$$PreferencesImplCopyWith(
          _$PreferencesImpl value, $Res Function(_$PreferencesImpl) then) =
      __$$PreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemePreferences themePreference,
      LanguagePreference languagePreference,
      LockPreference lockPreference,
      NotificationsPreference notificationsPreference});

  @override
  $ThemePreferencesCopyWith<$Res> get themePreference;
  @override
  $LockPreferenceCopyWith<$Res> get lockPreference;
  @override
  $NotificationsPreferenceCopyWith<$Res> get notificationsPreference;
}

/// @nodoc
class __$$PreferencesImplCopyWithImpl<$Res>
    extends _$PreferencesCopyWithImpl<$Res, _$PreferencesImpl>
    implements _$$PreferencesImplCopyWith<$Res> {
  __$$PreferencesImplCopyWithImpl(
      _$PreferencesImpl _value, $Res Function(_$PreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themePreference = null,
    Object? languagePreference = null,
    Object? lockPreference = null,
    Object? notificationsPreference = null,
  }) {
    return _then(_$PreferencesImpl(
      themePreference: null == themePreference
          ? _value.themePreference
          : themePreference // ignore: cast_nullable_to_non_nullable
              as ThemePreferences,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as LanguagePreference,
      lockPreference: null == lockPreference
          ? _value.lockPreference
          : lockPreference // ignore: cast_nullable_to_non_nullable
              as LockPreference,
      notificationsPreference: null == notificationsPreference
          ? _value.notificationsPreference
          : notificationsPreference // ignore: cast_nullable_to_non_nullable
              as NotificationsPreference,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferencesImpl implements _Preferences {
  const _$PreferencesImpl(
      {this.themePreference = ThemePreferences.defaults,
      this.languagePreference = LanguagePreference.defaults,
      this.lockPreference = LockPreference.defaults,
      this.notificationsPreference = NotificationsPreference.defaults});

  factory _$PreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferencesImplFromJson(json);

  @override
  @JsonKey()
  final ThemePreferences themePreference;
  @override
  @JsonKey()
  final LanguagePreference languagePreference;
  @override
  @JsonKey()
  final LockPreference lockPreference;
  @override
  @JsonKey()
  final NotificationsPreference notificationsPreference;

  @override
  String toString() {
    return 'Preferences(themePreference: $themePreference, languagePreference: $languagePreference, lockPreference: $lockPreference, notificationsPreference: $notificationsPreference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferencesImpl &&
            (identical(other.themePreference, themePreference) ||
                other.themePreference == themePreference) &&
            (identical(other.languagePreference, languagePreference) ||
                other.languagePreference == languagePreference) &&
            (identical(other.lockPreference, lockPreference) ||
                other.lockPreference == lockPreference) &&
            (identical(
                    other.notificationsPreference, notificationsPreference) ||
                other.notificationsPreference == notificationsPreference));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, themePreference,
      languagePreference, lockPreference, notificationsPreference);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      __$$PreferencesImplCopyWithImpl<_$PreferencesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferencesImplToJson(
      this,
    );
  }
}

abstract class _Preferences implements Preferences {
  const factory _Preferences(
          {final ThemePreferences themePreference,
          final LanguagePreference languagePreference,
          final LockPreference lockPreference,
          final NotificationsPreference notificationsPreference}) =
      _$PreferencesImpl;

  factory _Preferences.fromJson(Map<String, dynamic> json) =
      _$PreferencesImpl.fromJson;

  @override
  ThemePreferences get themePreference;
  @override
  LanguagePreference get languagePreference;
  @override
  LockPreference get lockPreference;
  @override
  NotificationsPreference get notificationsPreference;
  @override
  @JsonKey(ignore: true)
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
