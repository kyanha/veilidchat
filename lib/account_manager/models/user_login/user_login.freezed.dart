// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_login.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserLogin _$UserLoginFromJson(Map<String, dynamic> json) {
  return _UserLogin.fromJson(json);
}

/// @nodoc
mixin _$UserLogin {
// SuperIdentity record key for the user
// used to index the local accounts table
  Typed<FixedEncodedString43> get superIdentityRecordKey =>
      throw _privateConstructorUsedError; // The identity secret as unlocked from the local accounts table
  Typed<FixedEncodedString43> get identitySecret =>
      throw _privateConstructorUsedError; // The account record key, owner key and secret pulled from the identity
  AccountRecordInfo get accountRecordInfo =>
      throw _privateConstructorUsedError; // The time this login was most recently used
  Timestamp get lastActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserLoginCopyWith<UserLogin> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLoginCopyWith<$Res> {
  factory $UserLoginCopyWith(UserLogin value, $Res Function(UserLogin) then) =
      _$UserLoginCopyWithImpl<$Res, UserLogin>;
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> superIdentityRecordKey,
      Typed<FixedEncodedString43> identitySecret,
      AccountRecordInfo accountRecordInfo,
      Timestamp lastActive});

  $AccountRecordInfoCopyWith<$Res> get accountRecordInfo;
}

/// @nodoc
class _$UserLoginCopyWithImpl<$Res, $Val extends UserLogin>
    implements $UserLoginCopyWith<$Res> {
  _$UserLoginCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? superIdentityRecordKey = null,
    Object? identitySecret = null,
    Object? accountRecordInfo = null,
    Object? lastActive = null,
  }) {
    return _then(_value.copyWith(
      superIdentityRecordKey: null == superIdentityRecordKey
          ? _value.superIdentityRecordKey
          : superIdentityRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      identitySecret: null == identitySecret
          ? _value.identitySecret
          : identitySecret // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      accountRecordInfo: null == accountRecordInfo
          ? _value.accountRecordInfo
          : accountRecordInfo // ignore: cast_nullable_to_non_nullable
              as AccountRecordInfo,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AccountRecordInfoCopyWith<$Res> get accountRecordInfo {
    return $AccountRecordInfoCopyWith<$Res>(_value.accountRecordInfo, (value) {
      return _then(_value.copyWith(accountRecordInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserLoginImplCopyWith<$Res>
    implements $UserLoginCopyWith<$Res> {
  factory _$$UserLoginImplCopyWith(
          _$UserLoginImpl value, $Res Function(_$UserLoginImpl) then) =
      __$$UserLoginImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> superIdentityRecordKey,
      Typed<FixedEncodedString43> identitySecret,
      AccountRecordInfo accountRecordInfo,
      Timestamp lastActive});

  @override
  $AccountRecordInfoCopyWith<$Res> get accountRecordInfo;
}

/// @nodoc
class __$$UserLoginImplCopyWithImpl<$Res>
    extends _$UserLoginCopyWithImpl<$Res, _$UserLoginImpl>
    implements _$$UserLoginImplCopyWith<$Res> {
  __$$UserLoginImplCopyWithImpl(
      _$UserLoginImpl _value, $Res Function(_$UserLoginImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? superIdentityRecordKey = null,
    Object? identitySecret = null,
    Object? accountRecordInfo = null,
    Object? lastActive = null,
  }) {
    return _then(_$UserLoginImpl(
      superIdentityRecordKey: null == superIdentityRecordKey
          ? _value.superIdentityRecordKey
          : superIdentityRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      identitySecret: null == identitySecret
          ? _value.identitySecret
          : identitySecret // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      accountRecordInfo: null == accountRecordInfo
          ? _value.accountRecordInfo
          : accountRecordInfo // ignore: cast_nullable_to_non_nullable
              as AccountRecordInfo,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLoginImpl implements _UserLogin {
  const _$UserLoginImpl(
      {required this.superIdentityRecordKey,
      required this.identitySecret,
      required this.accountRecordInfo,
      required this.lastActive});

  factory _$UserLoginImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLoginImplFromJson(json);

// SuperIdentity record key for the user
// used to index the local accounts table
  @override
  final Typed<FixedEncodedString43> superIdentityRecordKey;
// The identity secret as unlocked from the local accounts table
  @override
  final Typed<FixedEncodedString43> identitySecret;
// The account record key, owner key and secret pulled from the identity
  @override
  final AccountRecordInfo accountRecordInfo;
// The time this login was most recently used
  @override
  final Timestamp lastActive;

  @override
  String toString() {
    return 'UserLogin(superIdentityRecordKey: $superIdentityRecordKey, identitySecret: $identitySecret, accountRecordInfo: $accountRecordInfo, lastActive: $lastActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLoginImpl &&
            (identical(other.superIdentityRecordKey, superIdentityRecordKey) ||
                other.superIdentityRecordKey == superIdentityRecordKey) &&
            (identical(other.identitySecret, identitySecret) ||
                other.identitySecret == identitySecret) &&
            (identical(other.accountRecordInfo, accountRecordInfo) ||
                other.accountRecordInfo == accountRecordInfo) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, superIdentityRecordKey,
      identitySecret, accountRecordInfo, lastActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLoginImplCopyWith<_$UserLoginImpl> get copyWith =>
      __$$UserLoginImplCopyWithImpl<_$UserLoginImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLoginImplToJson(
      this,
    );
  }
}

abstract class _UserLogin implements UserLogin {
  const factory _UserLogin(
      {required final Typed<FixedEncodedString43> superIdentityRecordKey,
      required final Typed<FixedEncodedString43> identitySecret,
      required final AccountRecordInfo accountRecordInfo,
      required final Timestamp lastActive}) = _$UserLoginImpl;

  factory _UserLogin.fromJson(Map<String, dynamic> json) =
      _$UserLoginImpl.fromJson;

  @override // SuperIdentity record key for the user
// used to index the local accounts table
  Typed<FixedEncodedString43> get superIdentityRecordKey;
  @override // The identity secret as unlocked from the local accounts table
  Typed<FixedEncodedString43> get identitySecret;
  @override // The account record key, owner key and secret pulled from the identity
  AccountRecordInfo get accountRecordInfo;
  @override // The time this login was most recently used
  Timestamp get lastActive;
  @override
  @JsonKey(ignore: true)
  _$$UserLoginImplCopyWith<_$UserLoginImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
