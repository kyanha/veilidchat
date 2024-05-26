// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageStateImpl _$$MessageStateImplFromJson(Map<String, dynamic> json) =>
    _$MessageStateImpl(
      content: messageFromJson(json['content'] as Map<String, dynamic>),
      timestamp: Timestamp.fromJson(json['timestamp']),
      sendState: json['send_state'] == null
          ? null
          : MessageSendState.fromJson(json['send_state']),
    );

Map<String, dynamic> _$$MessageStateImplToJson(_$MessageStateImpl instance) =>
    <String, dynamic>{
      'content': messageToJson(instance.content),
      'timestamp': instance.timestamp.toJson(),
      'send_state': instance.sendState?.toJson(),
    };
