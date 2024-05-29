// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageStateImpl _$$MessageStateImplFromJson(Map<String, dynamic> json) =>
    _$MessageStateImpl(
      content: messageFromJson(json['content'] as Map<String, dynamic>),
      sentTimestamp: Timestamp.fromJson(json['sent_timestamp']),
      reconciledTimestamp: json['reconciled_timestamp'] == null
          ? null
          : Timestamp.fromJson(json['reconciled_timestamp']),
      sendState: json['send_state'] == null
          ? null
          : MessageSendState.fromJson(json['send_state']),
    );

Map<String, dynamic> _$$MessageStateImplToJson(_$MessageStateImpl instance) =>
    <String, dynamic>{
      'content': messageToJson(instance.content),
      'sent_timestamp': instance.sentTimestamp.toJson(),
      'reconciled_timestamp': instance.reconciledTimestamp?.toJson(),
      'send_state': instance.sendState?.toJson(),
    };
