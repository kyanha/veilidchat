// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageState _$MessageStateFromJson(Map<String, dynamic> json) {
  return _MessageState.fromJson(json);
}

/// @nodoc
mixin _$MessageState {
// Content of the message
  @JsonKey(fromJson: messageFromJson, toJson: messageToJson)
  proto.Message get content =>
      throw _privateConstructorUsedError; // Sent timestamp
  Timestamp get sentTimestamp =>
      throw _privateConstructorUsedError; // Reconciled timestamp
  Timestamp? get reconciledTimestamp =>
      throw _privateConstructorUsedError; // The state of the message
  MessageSendState? get sendState => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageStateCopyWith<MessageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageStateCopyWith<$Res> {
  factory $MessageStateCopyWith(
          MessageState value, $Res Function(MessageState) then) =
      _$MessageStateCopyWithImpl<$Res, MessageState>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: messageFromJson, toJson: messageToJson)
      proto.Message content,
      Timestamp sentTimestamp,
      Timestamp? reconciledTimestamp,
      MessageSendState? sendState});
}

/// @nodoc
class _$MessageStateCopyWithImpl<$Res, $Val extends MessageState>
    implements $MessageStateCopyWith<$Res> {
  _$MessageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? sentTimestamp = null,
    Object? reconciledTimestamp = freezed,
    Object? sendState = freezed,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as proto.Message,
      sentTimestamp: null == sentTimestamp
          ? _value.sentTimestamp
          : sentTimestamp // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      reconciledTimestamp: freezed == reconciledTimestamp
          ? _value.reconciledTimestamp
          : reconciledTimestamp // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      sendState: freezed == sendState
          ? _value.sendState
          : sendState // ignore: cast_nullable_to_non_nullable
              as MessageSendState?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageStateImplCopyWith<$Res>
    implements $MessageStateCopyWith<$Res> {
  factory _$$MessageStateImplCopyWith(
          _$MessageStateImpl value, $Res Function(_$MessageStateImpl) then) =
      __$$MessageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: messageFromJson, toJson: messageToJson)
      proto.Message content,
      Timestamp sentTimestamp,
      Timestamp? reconciledTimestamp,
      MessageSendState? sendState});
}

/// @nodoc
class __$$MessageStateImplCopyWithImpl<$Res>
    extends _$MessageStateCopyWithImpl<$Res, _$MessageStateImpl>
    implements _$$MessageStateImplCopyWith<$Res> {
  __$$MessageStateImplCopyWithImpl(
      _$MessageStateImpl _value, $Res Function(_$MessageStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? sentTimestamp = null,
    Object? reconciledTimestamp = freezed,
    Object? sendState = freezed,
  }) {
    return _then(_$MessageStateImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as proto.Message,
      sentTimestamp: null == sentTimestamp
          ? _value.sentTimestamp
          : sentTimestamp // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      reconciledTimestamp: freezed == reconciledTimestamp
          ? _value.reconciledTimestamp
          : reconciledTimestamp // ignore: cast_nullable_to_non_nullable
              as Timestamp?,
      sendState: freezed == sendState
          ? _value.sendState
          : sendState // ignore: cast_nullable_to_non_nullable
              as MessageSendState?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageStateImpl with DiagnosticableTreeMixin implements _MessageState {
  const _$MessageStateImpl(
      {@JsonKey(fromJson: messageFromJson, toJson: messageToJson)
      required this.content,
      required this.sentTimestamp,
      required this.reconciledTimestamp,
      required this.sendState});

  factory _$MessageStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageStateImplFromJson(json);

// Content of the message
  @override
  @JsonKey(fromJson: messageFromJson, toJson: messageToJson)
  final proto.Message content;
// Sent timestamp
  @override
  final Timestamp sentTimestamp;
// Reconciled timestamp
  @override
  final Timestamp? reconciledTimestamp;
// The state of the message
  @override
  final MessageSendState? sendState;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessageState(content: $content, sentTimestamp: $sentTimestamp, reconciledTimestamp: $reconciledTimestamp, sendState: $sendState)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessageState'))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('sentTimestamp', sentTimestamp))
      ..add(DiagnosticsProperty('reconciledTimestamp', reconciledTimestamp))
      ..add(DiagnosticsProperty('sendState', sendState));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageStateImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.sentTimestamp, sentTimestamp) ||
                other.sentTimestamp == sentTimestamp) &&
            (identical(other.reconciledTimestamp, reconciledTimestamp) ||
                other.reconciledTimestamp == reconciledTimestamp) &&
            (identical(other.sendState, sendState) ||
                other.sendState == sendState));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, content, sentTimestamp, reconciledTimestamp, sendState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageStateImplCopyWith<_$MessageStateImpl> get copyWith =>
      __$$MessageStateImplCopyWithImpl<_$MessageStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageStateImplToJson(
      this,
    );
  }
}

abstract class _MessageState implements MessageState {
  const factory _MessageState(
      {@JsonKey(fromJson: messageFromJson, toJson: messageToJson)
      required final proto.Message content,
      required final Timestamp sentTimestamp,
      required final Timestamp? reconciledTimestamp,
      required final MessageSendState? sendState}) = _$MessageStateImpl;

  factory _MessageState.fromJson(Map<String, dynamic> json) =
      _$MessageStateImpl.fromJson;

  @override // Content of the message
  @JsonKey(fromJson: messageFromJson, toJson: messageToJson)
  proto.Message get content;
  @override // Sent timestamp
  Timestamp get sentTimestamp;
  @override // Reconciled timestamp
  Timestamp? get reconciledTimestamp;
  @override // The state of the message
  MessageSendState? get sendState;
  @override
  @JsonKey(ignore: true)
  _$$MessageStateImplCopyWith<_$MessageStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
