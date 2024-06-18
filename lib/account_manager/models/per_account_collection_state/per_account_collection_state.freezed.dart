// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'per_account_collection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PerAccountCollectionState {
  AccountInfo get accountInfo => throw _privateConstructorUsedError;
  AsyncValue<Account> get avAccountRecordState =>
      throw _privateConstructorUsedError;
  ContactInvitationListCubit? get contactInvitationListCubit =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PerAccountCollectionStateCopyWith<PerAccountCollectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerAccountCollectionStateCopyWith<$Res> {
  factory $PerAccountCollectionStateCopyWith(PerAccountCollectionState value,
          $Res Function(PerAccountCollectionState) then) =
      _$PerAccountCollectionStateCopyWithImpl<$Res, PerAccountCollectionState>;
  @useResult
  $Res call(
      {AccountInfo accountInfo,
      AsyncValue<Account> avAccountRecordState,
      ContactInvitationListCubit? contactInvitationListCubit});

  $AsyncValueCopyWith<Account, $Res> get avAccountRecordState;
}

/// @nodoc
class _$PerAccountCollectionStateCopyWithImpl<$Res,
        $Val extends PerAccountCollectionState>
    implements $PerAccountCollectionStateCopyWith<$Res> {
  _$PerAccountCollectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountInfo = null,
    Object? avAccountRecordState = null,
    Object? contactInvitationListCubit = freezed,
  }) {
    return _then(_value.copyWith(
      accountInfo: null == accountInfo
          ? _value.accountInfo
          : accountInfo // ignore: cast_nullable_to_non_nullable
              as AccountInfo,
      avAccountRecordState: null == avAccountRecordState
          ? _value.avAccountRecordState
          : avAccountRecordState // ignore: cast_nullable_to_non_nullable
              as AsyncValue<Account>,
      contactInvitationListCubit: freezed == contactInvitationListCubit
          ? _value.contactInvitationListCubit
          : contactInvitationListCubit // ignore: cast_nullable_to_non_nullable
              as ContactInvitationListCubit?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AsyncValueCopyWith<Account, $Res> get avAccountRecordState {
    return $AsyncValueCopyWith<Account, $Res>(_value.avAccountRecordState,
        (value) {
      return _then(_value.copyWith(avAccountRecordState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PerAccountCollectionStateImplCopyWith<$Res>
    implements $PerAccountCollectionStateCopyWith<$Res> {
  factory _$$PerAccountCollectionStateImplCopyWith(
          _$PerAccountCollectionStateImpl value,
          $Res Function(_$PerAccountCollectionStateImpl) then) =
      __$$PerAccountCollectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AccountInfo accountInfo,
      AsyncValue<Account> avAccountRecordState,
      ContactInvitationListCubit? contactInvitationListCubit});

  @override
  $AsyncValueCopyWith<Account, $Res> get avAccountRecordState;
}

/// @nodoc
class __$$PerAccountCollectionStateImplCopyWithImpl<$Res>
    extends _$PerAccountCollectionStateCopyWithImpl<$Res,
        _$PerAccountCollectionStateImpl>
    implements _$$PerAccountCollectionStateImplCopyWith<$Res> {
  __$$PerAccountCollectionStateImplCopyWithImpl(
      _$PerAccountCollectionStateImpl _value,
      $Res Function(_$PerAccountCollectionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountInfo = null,
    Object? avAccountRecordState = null,
    Object? contactInvitationListCubit = freezed,
  }) {
    return _then(_$PerAccountCollectionStateImpl(
      accountInfo: null == accountInfo
          ? _value.accountInfo
          : accountInfo // ignore: cast_nullable_to_non_nullable
              as AccountInfo,
      avAccountRecordState: null == avAccountRecordState
          ? _value.avAccountRecordState
          : avAccountRecordState // ignore: cast_nullable_to_non_nullable
              as AsyncValue<Account>,
      contactInvitationListCubit: freezed == contactInvitationListCubit
          ? _value.contactInvitationListCubit
          : contactInvitationListCubit // ignore: cast_nullable_to_non_nullable
              as ContactInvitationListCubit?,
    ));
  }
}

/// @nodoc

class _$PerAccountCollectionStateImpl implements _PerAccountCollectionState {
  const _$PerAccountCollectionStateImpl(
      {required this.accountInfo,
      required this.avAccountRecordState,
      required this.contactInvitationListCubit});

  @override
  final AccountInfo accountInfo;
  @override
  final AsyncValue<Account> avAccountRecordState;
  @override
  final ContactInvitationListCubit? contactInvitationListCubit;

  @override
  String toString() {
    return 'PerAccountCollectionState(accountInfo: $accountInfo, avAccountRecordState: $avAccountRecordState, contactInvitationListCubit: $contactInvitationListCubit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerAccountCollectionStateImpl &&
            (identical(other.accountInfo, accountInfo) ||
                other.accountInfo == accountInfo) &&
            (identical(other.avAccountRecordState, avAccountRecordState) ||
                other.avAccountRecordState == avAccountRecordState) &&
            (identical(other.contactInvitationListCubit,
                    contactInvitationListCubit) ||
                other.contactInvitationListCubit ==
                    contactInvitationListCubit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accountInfo,
      avAccountRecordState, contactInvitationListCubit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PerAccountCollectionStateImplCopyWith<_$PerAccountCollectionStateImpl>
      get copyWith => __$$PerAccountCollectionStateImplCopyWithImpl<
          _$PerAccountCollectionStateImpl>(this, _$identity);
}

abstract class _PerAccountCollectionState implements PerAccountCollectionState {
  const factory _PerAccountCollectionState(
      {required final AccountInfo accountInfo,
      required final AsyncValue<Account> avAccountRecordState,
      required final ContactInvitationListCubit?
          contactInvitationListCubit}) = _$PerAccountCollectionStateImpl;

  @override
  AccountInfo get accountInfo;
  @override
  AsyncValue<Account> get avAccountRecordState;
  @override
  ContactInvitationListCubit? get contactInvitationListCubit;
  @override
  @JsonKey(ignore: true)
  _$$PerAccountCollectionStateImplCopyWith<_$PerAccountCollectionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
