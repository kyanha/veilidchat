// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouterStateImpl _$$RouterStateImplFromJson(Map<String, dynamic> json) =>
    _$RouterStateImpl(
      isInitialized: json['is_initialized'] as bool,
      hasAnyAccount: json['has_any_account'] as bool,
      hasActiveChat: json['has_active_chat'] as bool,
    );

Map<String, dynamic> _$$RouterStateImplToJson(_$RouterStateImpl instance) =>
    <String, dynamic>{
      'is_initialized': instance.isInitialized,
      'has_any_account': instance.hasAnyAccount,
      'has_active_chat': instance.hasActiveChat,
    };
