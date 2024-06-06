// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'window_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WindowState<T> {
// List of objects in the window
  IList<T> get window =>
      throw _privateConstructorUsedError; // Total number of objects (windowTail max)
  int get length =>
      throw _privateConstructorUsedError; // One past the end of the last element
  int get windowTail =>
      throw _privateConstructorUsedError; // The total number of elements to try to keep in the window
  int get windowCount =>
      throw _privateConstructorUsedError; // If we should have the tail following the array
  bool get follow => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WindowStateCopyWith<T, WindowState<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WindowStateCopyWith<T, $Res> {
  factory $WindowStateCopyWith(
          WindowState<T> value, $Res Function(WindowState<T>) then) =
      _$WindowStateCopyWithImpl<T, $Res, WindowState<T>>;
  @useResult
  $Res call(
      {IList<T> window,
      int length,
      int windowTail,
      int windowCount,
      bool follow});
}

/// @nodoc
class _$WindowStateCopyWithImpl<T, $Res, $Val extends WindowState<T>>
    implements $WindowStateCopyWith<T, $Res> {
  _$WindowStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? window = null,
    Object? length = null,
    Object? windowTail = null,
    Object? windowCount = null,
    Object? follow = null,
  }) {
    return _then(_value.copyWith(
      window: null == window
          ? _value.window
          : window // ignore: cast_nullable_to_non_nullable
              as IList<T>,
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
abstract class _$$WindowStateImplCopyWith<T, $Res>
    implements $WindowStateCopyWith<T, $Res> {
  factory _$$WindowStateImplCopyWith(_$WindowStateImpl<T> value,
          $Res Function(_$WindowStateImpl<T>) then) =
      __$$WindowStateImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {IList<T> window,
      int length,
      int windowTail,
      int windowCount,
      bool follow});
}

/// @nodoc
class __$$WindowStateImplCopyWithImpl<T, $Res>
    extends _$WindowStateCopyWithImpl<T, $Res, _$WindowStateImpl<T>>
    implements _$$WindowStateImplCopyWith<T, $Res> {
  __$$WindowStateImplCopyWithImpl(
      _$WindowStateImpl<T> _value, $Res Function(_$WindowStateImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? window = null,
    Object? length = null,
    Object? windowTail = null,
    Object? windowCount = null,
    Object? follow = null,
  }) {
    return _then(_$WindowStateImpl<T>(
      window: null == window
          ? _value.window
          : window // ignore: cast_nullable_to_non_nullable
              as IList<T>,
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

class _$WindowStateImpl<T>
    with DiagnosticableTreeMixin
    implements _WindowState<T> {
  const _$WindowStateImpl(
      {required this.window,
      required this.length,
      required this.windowTail,
      required this.windowCount,
      required this.follow});

// List of objects in the window
  @override
  final IList<T> window;
// Total number of objects (windowTail max)
  @override
  final int length;
// One past the end of the last element
  @override
  final int windowTail;
// The total number of elements to try to keep in the window
  @override
  final int windowCount;
// If we should have the tail following the array
  @override
  final bool follow;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WindowState<$T>(window: $window, length: $length, windowTail: $windowTail, windowCount: $windowCount, follow: $follow)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'WindowState<$T>'))
      ..add(DiagnosticsProperty('window', window))
      ..add(DiagnosticsProperty('length', length))
      ..add(DiagnosticsProperty('windowTail', windowTail))
      ..add(DiagnosticsProperty('windowCount', windowCount))
      ..add(DiagnosticsProperty('follow', follow));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WindowStateImpl<T> &&
            const DeepCollectionEquality().equals(other.window, window) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.windowTail, windowTail) ||
                other.windowTail == windowTail) &&
            (identical(other.windowCount, windowCount) ||
                other.windowCount == windowCount) &&
            (identical(other.follow, follow) || other.follow == follow));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(window),
      length,
      windowTail,
      windowCount,
      follow);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WindowStateImplCopyWith<T, _$WindowStateImpl<T>> get copyWith =>
      __$$WindowStateImplCopyWithImpl<T, _$WindowStateImpl<T>>(
          this, _$identity);
}

abstract class _WindowState<T> implements WindowState<T> {
  const factory _WindowState(
      {required final IList<T> window,
      required final int length,
      required final int windowTail,
      required final int windowCount,
      required final bool follow}) = _$WindowStateImpl<T>;

  @override // List of objects in the window
  IList<T> get window;
  @override // Total number of objects (windowTail max)
  int get length;
  @override // One past the end of the last element
  int get windowTail;
  @override // The total number of elements to try to keep in the window
  int get windowCount;
  @override // If we should have the tail following the array
  bool get follow;
  @override
  @JsonKey(ignore: true)
  _$$WindowStateImplCopyWith<T, _$WindowStateImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
