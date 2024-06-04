// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessagesState _$MessagesStateFromJson(Map<String, dynamic> json) {
  return _MessagesState.fromJson(json);
}

/// @nodoc
mixin _$MessagesState {
// List of messages in the window
  IList<MessageState> get windowMessages =>
      throw _privateConstructorUsedError; // Total number of messages
  int get length =>
      throw _privateConstructorUsedError; // One past the end of the last element
  int get windowTail =>
      throw _privateConstructorUsedError; // The total number of elements to try to keep in 'messages'
  int get windowCount =>
      throw _privateConstructorUsedError; // If we should have the tail following the array
  bool get follow => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessagesStateCopyWith<MessagesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessagesStateCopyWith<$Res> {
  factory $MessagesStateCopyWith(
          MessagesState value, $Res Function(MessagesState) then) =
      _$MessagesStateCopyWithImpl<$Res, MessagesState>;
  @useResult
  $Res call(
      {IList<MessageState> windowMessages,
      int length,
      int windowTail,
      int windowCount,
      bool follow});
}

/// @nodoc
class _$MessagesStateCopyWithImpl<$Res, $Val extends MessagesState>
    implements $MessagesStateCopyWith<$Res> {
  _$MessagesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? windowMessages = null,
    Object? length = null,
    Object? windowTail = null,
    Object? windowCount = null,
    Object? follow = null,
  }) {
    return _then(_value.copyWith(
      windowMessages: null == windowMessages
          ? _value.windowMessages
          : windowMessages // ignore: cast_nullable_to_non_nullable
              as IList<MessageState>,
      length: null == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int,
      windowTail: null == windowTail
          ? _value.windowTail
          : windowTail // ignore: cast_nullable_to_non_nullable
              as int,
      windowCount: null == windowCount
          ? _value.windowCount
          : windowCount // ignore: cast_nullable_to_non_nullable
              as int,
      follow: null == follow
          ? _value.follow
          : follow // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessagesStateImplCopyWith<$Res>
    implements $MessagesStateCopyWith<$Res> {
  factory _$$MessagesStateImplCopyWith(
          _$MessagesStateImpl value, $Res Function(_$MessagesStateImpl) then) =
      __$$MessagesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IList<MessageState> windowMessages,
      int length,
      int windowTail,
      int windowCount,
      bool follow});
}

/// @nodoc
class __$$MessagesStateImplCopyWithImpl<$Res>
    extends _$MessagesStateCopyWithImpl<$Res, _$MessagesStateImpl>
    implements _$$MessagesStateImplCopyWith<$Res> {
  __$$MessagesStateImplCopyWithImpl(
      _$MessagesStateImpl _value, $Res Function(_$MessagesStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? windowMessages = null,
    Object? length = null,
    Object? windowTail = null,
    Object? windowCount = null,
    Object? follow = null,
  }) {
    return _then(_$MessagesStateImpl(
      windowMessages: null == windowMessages
          ? _value.windowMessages
          : windowMessages // ignore: cast_nullable_to_non_nullable
              as IList<MessageState>,
      length: null == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as int,
      windowTail: null == windowTail
          ? _value.windowTail
          : windowTail // ignore: cast_nullable_to_non_nullable
              as int,
      windowCount: null == windowCount
          ? _value.windowCount
          : windowCount // ignore: cast_nullable_to_non_nullable
              as int,
      follow: null == follow
          ? _value.follow
          : follow // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessagesStateImpl
    with DiagnosticableTreeMixin
    implements _MessagesState {
  const _$MessagesStateImpl(
      {required this.windowMessages,
      required this.length,
      required this.windowTail,
      required this.windowCount,
      required this.follow});

  factory _$MessagesStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessagesStateImplFromJson(json);

// List of messages in the window
  @override
  final IList<MessageState> windowMessages;
// Total number of messages
  @override
  final int length;
// One past the end of the last element
  @override
  final int windowTail;
// The total number of elements to try to keep in 'messages'
  @override
  final int windowCount;
// If we should have the tail following the array
  @override
  final bool follow;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessagesState(windowMessages: $windowMessages, length: $length, windowTail: $windowTail, windowCount: $windowCount, follow: $follow)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessagesState'))
      ..add(DiagnosticsProperty('windowMessages', windowMessages))
      ..add(DiagnosticsProperty('length', length))
      ..add(DiagnosticsProperty('windowTail', windowTail))
      ..add(DiagnosticsProperty('windowCount', windowCount))
      ..add(DiagnosticsProperty('follow', follow));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagesStateImpl &&
            const DeepCollectionEquality()
                .equals(other.windowMessages, windowMessages) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.windowTail, windowTail) ||
                other.windowTail == windowTail) &&
            (identical(other.windowCount, windowCount) ||
                other.windowCount == windowCount) &&
            (identical(other.follow, follow) || other.follow == follow));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(windowMessages),
      length,
      windowTail,
      windowCount,
      follow);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagesStateImplCopyWith<_$MessagesStateImpl> get copyWith =>
      __$$MessagesStateImplCopyWithImpl<_$MessagesStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessagesStateImplToJson(
      this,
    );
  }
}

abstract class _MessagesState implements MessagesState {
  const factory _MessagesState(
      {required final IList<MessageState> windowMessages,
      required final int length,
      required final int windowTail,
      required final int windowCount,
      required final bool follow}) = _$MessagesStateImpl;

  factory _MessagesState.fromJson(Map<String, dynamic> json) =
      _$MessagesStateImpl.fromJson;

  @override // List of messages in the window
  IList<MessageState> get windowMessages;
  @override // Total number of messages
  int get length;
  @override // One past the end of the last element
  int get windowTail;
  @override // The total number of elements to try to keep in 'messages'
  int get windowCount;
  @override // If we should have the tail following the array
  bool get follow;
  @override
  @JsonKey(ignore: true)
  _$$MessagesStateImplCopyWith<_$MessagesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
