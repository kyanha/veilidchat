import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'window_state.freezed.dart';

@freezed
class WindowState<T> with _$WindowState<T> {
  const factory WindowState({
    // List of objects in the window
    required IList<T> window,
    // Total number of objects (windowTail max)
    required int length,
    // One past the end of the last element
    required int windowTail,
    // The total number of elements to try to keep in the window
    required int windowCount,
    // If we should have the tail following the array
    required bool follow,
  }) = _WindowState;
}

extension WindowStateExt<T> on WindowState<T> {
  int get windowEnd => (length == 0) ? -1 : (windowTail - 1) % length;
  int get windowStart =>
      (length == 0) ? 0 : (windowTail - window.length) % length;
}
