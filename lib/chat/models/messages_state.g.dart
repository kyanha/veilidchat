// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessagesStateImpl _$$MessagesStateImplFromJson(Map<String, dynamic> json) =>
    _$MessagesStateImpl(
      windowMessages: IList<MessageState>.fromJson(
          json['window_messages'], (value) => MessageState.fromJson(value)),
      length: (json['length'] as num).toInt(),
      windowTail: (json['window_tail'] as num).toInt(),
      windowCount: (json['window_count'] as num).toInt(),
      follow: json['follow'] as bool,
    );

Map<String, dynamic> _$$MessagesStateImplToJson(_$MessagesStateImpl instance) =>
    <String, dynamic>{
      'window_messages': instance.windowMessages.toJson(
        (value) => value.toJson(),
      ),
      'length': instance.length,
      'window_tail': instance.windowTail,
      'window_count': instance.windowCount,
      'follow': instance.follow,
    };
