// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageStateImpl _$$MessageStateImplFromJson(Map<String, dynamic> json) =>
    _$MessageStateImpl(
      author: Typed<FixedEncodedString43>.fromJson(json['author']),
      timestamp: Timestamp.fromJson(json['timestamp']),
      text: json['text'] as String,
      sendState: json['send_state'] == null
          ? null
          : MessageSendState.fromJson(json['send_state']),
    );

Map<String, dynamic> _$$MessageStateImplToJson(_$MessageStateImpl instance) =>
    <String, dynamic>{
      'author': instance.author.toJson(),
      'timestamp': instance.timestamp.toJson(),
      'text': instance.text,
      'send_state': instance.sendState?.toJson(),
    };
