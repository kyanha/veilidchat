import 'package:change_case/change_case.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;
import '../../proto/proto.dart' show messageFromJson, messageToJson;

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
    // Content of the message
    @JsonKey(fromJson: messageFromJson, toJson: messageToJson)
    required proto.Message content,
    // Sent timestamp
    required Timestamp sentTimestamp,
    // Reconciled timestamp
    required Timestamp? reconciledTimestamp,
    // The state of the message
    required MessageSendState? sendState,
  }) = _MessageState;

  factory MessageState.fromJson(dynamic json) =>
      _$MessageStateFromJson(json as Map<String, dynamic>);
}
