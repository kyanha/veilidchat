// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'router_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RouterState _$RouterStateFromJson(Map<String, dynamic> json) {
  return _RouterState.fromJson(json);
}

/// @nodoc
mixin _$RouterState {
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get hasAnyAccount => throw _privateConstructorUsedError;
  bool get hasActiveChat => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RouterStateCopyWith<RouterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouterStateCopyWith<$Res> {
  factory $RouterStateCopyWith(
          RouterState value, $Res Function(RouterState) then) =
      _$RouterStateCopyWithImpl<$Res, RouterState>;
  @useResult
  $Res call({bool isInitialized, bool hasAnyAccount, bool hasActiveChat});
}

/// @nodoc
class _$RouterStateCopyWithImpl<$Res, $Val extends RouterState>
    implements $RouterStateCopyWith<$Res> {
  _$RouterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isInitialized = null,
    Object? hasAnyAccount = null,
    Object? hasActiveChat = null,
  }) {
    return _then(_value.copyWith(
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAnyAccount: null == hasAnyAccount
          ? _value.hasAnyAccount
          : hasAnyAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      hasActiveChat: null == hasActiveChat
          ? _value.hasActiveChat
          : hasActiveChat // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RouterStateImplCopyWith<$Res>
    implements $RouterStateCopyWith<$Res> {
  factory _$$RouterStateImplCopyWith(
          _$RouterStateImpl value, $Res Function(_$RouterStateImpl) then) =
      __$$RouterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isInitialized, bool hasAnyAccount, bool hasActiveChat});
}

/// @nodoc
class __$$RouterStateImplCopyWithImpl<$Res>
    extends _$RouterStateCopyWithImpl<$Res, _$RouterStateImpl>
    implements _$$RouterStateImplCopyWith<$Res> {
  __$$RouterStateImplCopyWithImpl(
      _$RouterStateImpl _value, $Res Function(_$RouterStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isInitialized = null,
    Object? hasAnyAccount = null,
    Object? hasActiveChat = null,
  }) {
    return _then(_$RouterStateImpl(
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAnyAccount: null == hasAnyAccount
          ? _value.hasAnyAccount
          : hasAnyAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      hasActiveChat: null == hasActiveChat
          ? _value.hasActiveChat
          : hasActiveChat // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RouterStateImpl with DiagnosticableTreeMixin implements _RouterState {
  const _$RouterStateImpl(
      {required this.isInitialized,
      required this.hasAnyAccount,
      required this.hasActiveChat});

  factory _$RouterStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouterStateImplFromJson(json);

  @override
  final bool isInitialized;
  @override
  final bool hasAnyAccount;
  @override
  final bool hasActiveChat;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RouterState(isInitialized: $isInitialized, hasAnyAccount: $hasAnyAccount, hasActiveChat: $hasActiveChat)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RouterState'))
      ..add(DiagnosticsProperty('isInitialized', isInitialized))
      ..add(DiagnosticsProperty('hasAnyAccount', hasAnyAccount))
      ..add(DiagnosticsProperty('hasActiveChat', hasActiveChat));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouterStateImpl &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.hasAnyAccount, hasAnyAccount) ||
                other.hasAnyAccount == hasAnyAccount) &&
            (identical(other.hasActiveChat, hasActiveChat) ||
                other.hasActiveChat == hasActiveChat));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isInitialized, hasAnyAccount, hasActiveChat);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RouterStateImplCopyWith<_$RouterStateImpl> get copyWith =>
      __$$RouterStateImplCopyWithImpl<_$RouterStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouterStateImplToJson(
      this,
    );
  }
}

abstract class _RouterState implements RouterState {
  const factory _RouterState(
      {required final bool isInitialized,
      required final bool hasAnyAccount,
      required final bool hasActiveChat}) = _$RouterStateImpl;

  factory _RouterState.fromJson(Map<String, dynamic> json) =
      _$RouterStateImpl.fromJson;

  @override
  bool get isInitialized;
  @override
  bool get hasAnyAccount;
  @override
  bool get hasActiveChat;
  @override
  @JsonKey(ignore: true)
  _$$RouterStateImplCopyWith<_$RouterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
