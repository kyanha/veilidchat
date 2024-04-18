import 'package:change_case/change_case.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

part 'message_state.freezed.dart';
part 'message_state.g.dart';

// Whether or not a message has been fully sent
enum MessageSendState {
  // message is still being sent
  sending,
  // message issued has not reached the network
  sent,
  // message was sent and has reached the network
  delivered;

  factory MessageSendState.fromJson(dynamic j) =>
      MessageSendState.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();
}

@freezed
class MessageState with _$MessageState {
  const factory MessageState({
    required TypedKey author,
    required Timestamp timestamp,
    required String text,
    required MessageSendState? sendState,
  }) = _MessageState;

  factory MessageState.fromJson(dynamic json) =>
      _$MessageStateFromJson(json as Map<String, dynamic>);
}
