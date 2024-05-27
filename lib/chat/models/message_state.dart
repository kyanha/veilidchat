import 'package:change_case/change_case.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;

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
    @JsonKey(fromJson: proto.messageFromJson, toJson: proto.messageToJson)
    required proto.Message content,
    // Received or delivered timestamp
    required Timestamp timestamp,
    // The state of the message
    required MessageSendState? sendState,
  }) = _MessageState;

  factory MessageState.fromJson(dynamic json) =>
      _$MessageStateFromJson(json as Map<String, dynamic>);
}

extension MessageStateExt on MessageState {
  String get uniqueId {
    final author = content.author.toVeilid().toString();
    final id = base64UrlNoPadEncode(content.id);
    return '$author|$id';
  }

  static (proto.TypedKey, Uint8List) splitUniqueId(String uniqueId) {
    final parts = uniqueId.split('|');
    if (parts.length != 2) {
      throw Exception('invalid unique id');
    }
    final author = TypedKey.fromString(parts[0]).toProto();
    final id = base64UrlNoPadDecode(parts[1]);
    return (author, id);
  }
}
