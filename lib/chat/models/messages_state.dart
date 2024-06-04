import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'message_state.dart';

part 'messages_state.freezed.dart';
part 'messages_state.g.dart';

@freezed
class MessagesState with _$MessagesState {
  const factory MessagesState({
    // List of messages in the window
    required IList<MessageState> windowMessages,
    // Total number of messages
    required int length,
    // One past the end of the last element
    required int windowTail,
    // The total number of elements to try to keep in 'messages'
    required int windowCount,
    // If we should have the tail following the array
    required bool follow,
  }) = _MessagesState;

  factory MessagesState.fromJson(dynamic json) =>
      _$MessagesStateFromJson(json as Map<String, dynamic>);
}
