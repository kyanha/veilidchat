// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_component_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatComponentState {
// GlobalKey for the chat
  GlobalKey<ChatState> get chatKey =>
      throw _privateConstructorUsedError; // ScrollController for the chat
  AutoScrollController get scrollController =>
      throw _privateConstructorUsedError; // Local user
  User get localUser => throw _privateConstructorUsedError; // Remote users
  IMap<Typed<FixedEncodedString43>, User> get remoteUsers =>
      throw _privateConstructorUsedError; // Messages state
  AsyncValue<WindowState<Message>> get messageWindow =>
      throw _privateConstructorUsedError; // Title of the chat
  String get title => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChatComponentStateCopyWith<ChatComponentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatComponentStateCopyWith<$Res> {
  factory $ChatComponentStateCopyWith(
          ChatComponentState value, $Res Function(ChatComponentState) then) =
      _$ChatComponentStateCopyWithImpl<$Res, ChatComponentState>;
  @useResult
  $Res call(
      {GlobalKey<ChatState> chatKey,
      AutoScrollController scrollController,
      User localUser,
      IMap<Typed<FixedEncodedString43>, User> remoteUsers,
      AsyncValue<WindowState<Message>> messageWindow,
      String title});

  $AsyncValueCopyWith<WindowState<Message>, $Res> get messageWindow;
}

/// @nodoc
class _$ChatComponentStateCopyWithImpl<$Res, $Val extends ChatComponentState>
    implements $ChatComponentStateCopyWith<$Res> {
  _$ChatComponentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatKey = null,
    Object? scrollController = null,
    Object? localUser = null,
    Object? remoteUsers = null,
    Object? messageWindow = null,
    Object? title = null,
  }) {
    return _then(_value.copyWith(
      chatKey: null == chatKey
          ? _value.chatKey
          : chatKey // ignore: cast_nullable_to_non_nullable
              as GlobalKey<ChatState>,
      scrollController: null == scrollController
          ? _value.scrollController
          : scrollController // ignore: cast_nullable_to_non_nullable
              as AutoScrollController,
      localUser: null == localUser
          ? _value.localUser
          : localUser // ignore: cast_nullable_to_non_nullable
              as User,
      remoteUsers: null == remoteUsers
          ? _value.remoteUsers
          : remoteUsers // ignore: cast_nullable_to_non_nullable
              as IMap<Typed<FixedEncodedString43>, User>,
      messageWindow: null == messageWindow
          ? _value.messageWindow
          : messageWindow // ignore: cast_nullable_to_non_nullable
              as AsyncValue<WindowState<Message>>,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AsyncValueCopyWith<WindowState<Message>, $Res> get messageWindow {
    return $AsyncValueCopyWith<WindowState<Message>, $Res>(_value.messageWindow,
        (value) {
      return _then(_value.copyWith(messageWindow: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatComponentStateImplCopyWith<$Res>
    implements $ChatComponentStateCopyWith<$Res> {
  factory _$$ChatComponentStateImplCopyWith(_$ChatComponentStateImpl value,
          $Res Function(_$ChatComponentStateImpl) then) =
      __$$ChatComponentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GlobalKey<ChatState> chatKey,
      AutoScrollController scrollController,
      User localUser,
      IMap<Typed<FixedEncodedString43>, User> remoteUsers,
      AsyncValue<WindowState<Message>> messageWindow,
      String title});

  @override
  $AsyncValueCopyWith<WindowState<Message>, $Res> get messageWindow;
}

/// @nodoc
class __$$ChatComponentStateImplCopyWithImpl<$Res>
    extends _$ChatComponentStateCopyWithImpl<$Res, _$ChatComponentStateImpl>
    implements _$$ChatComponentStateImplCopyWith<$Res> {
  __$$ChatComponentStateImplCopyWithImpl(_$ChatComponentStateImpl _value,
      $Res Function(_$ChatComponentStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatKey = null,
    Object? scrollController = null,
    Object? localUser = null,
    Object? remoteUsers = null,
    Object? messageWindow = null,
    Object? title = null,
  }) {
    return _then(_$ChatComponentStateImpl(
      chatKey: null == chatKey
          ? _value.chatKey
          : chatKey // ignore: cast_nullable_to_non_nullable
              as GlobalKey<ChatState>,
      scrollController: null == scrollController
          ? _value.scrollController
          : scrollController // ignore: cast_nullable_to_non_nullable
              as AutoScrollController,
      localUser: null == localUser
          ? _value.localUser
          : localUser // ignore: cast_nullable_to_non_nullable
              as User,
      remoteUsers: null == remoteUsers
          ? _value.remoteUsers
          : remoteUsers // ignore: cast_nullable_to_non_nullable
              as IMap<Typed<FixedEncodedString43>, User>,
      messageWindow: null == messageWindow
          ? _value.messageWindow
          : messageWindow // ignore: cast_nullable_to_non_nullable
              as AsyncValue<WindowState<Message>>,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ChatComponentStateImpl implements _ChatComponentState {
  const _$ChatComponentStateImpl(
      {required this.chatKey,
      required this.scrollController,
      required this.localUser,
      required this.remoteUsers,
      required this.messageWindow,
      required this.title});

// GlobalKey for the chat
  @override
  final GlobalKey<ChatState> chatKey;
// ScrollController for the chat
  @override
  final AutoScrollController scrollController;
// Local user
  @override
  final User localUser;
// Remote users
  @override
  final IMap<Typed<FixedEncodedString43>, User> remoteUsers;
// Messages state
  @override
  final AsyncValue<WindowState<Message>> messageWindow;
// Title of the chat
  @override
  final String title;

  @override
  String toString() {
    return 'ChatComponentState(chatKey: $chatKey, scrollController: $scrollController, localUser: $localUser, remoteUsers: $remoteUsers, messageWindow: $messageWindow, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatComponentStateImpl &&
            (identical(other.chatKey, chatKey) || other.chatKey == chatKey) &&
            (identical(other.scrollController, scrollController) ||
                other.scrollController == scrollController) &&
            (identical(other.localUser, localUser) ||
                other.localUser == localUser) &&
            (identical(other.remoteUsers, remoteUsers) ||
                other.remoteUsers == remoteUsers) &&
            (identical(other.messageWindow, messageWindow) ||
                other.messageWindow == messageWindow) &&
            (identical(other.title, title) || other.title == title));
  }

  @override
  int get hashCode => Object.hash(runtimeType, chatKey, scrollController,
      localUser, remoteUsers, messageWindow, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatComponentStateImplCopyWith<_$ChatComponentStateImpl> get copyWith =>
      __$$ChatComponentStateImplCopyWithImpl<_$ChatComponentStateImpl>(
          this, _$identity);
}

abstract class _ChatComponentState implements ChatComponentState {
  const factory _ChatComponentState(
      {required final GlobalKey<ChatState> chatKey,
      required final AutoScrollController scrollController,
      required final User localUser,
      required final IMap<Typed<FixedEncodedString43>, User> remoteUsers,
      required final AsyncValue<WindowState<Message>> messageWindow,
      required final String title}) = _$ChatComponentStateImpl;

  @override // GlobalKey for the chat
  GlobalKey<ChatState> get chatKey;
  @override // ScrollController for the chat
  AutoScrollController get scrollController;
  @override // Local user
  User get localUser;
  @override // Remote users
  IMap<Typed<FixedEncodedString43>, User> get remoteUsers;
  @override // Messages state
  AsyncValue<WindowState<Message>> get messageWindow;
  @override // Title of the chat
  String get title;
  @override
  @JsonKey(ignore: true)
  _$$ChatComponentStateImplCopyWith<_$ChatComponentStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
