// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserLoginImpl _$$UserLoginImplFromJson(Map<String, dynamic> json) =>
    _$UserLoginImpl(
      superIdentityRecordKey: Typed<FixedEncodedString43>.fromJson(
          json['super_identity_record_key']),
      identitySecret:
          Typed<FixedEncodedString43>.fromJson(json['identity_secret']),
      accountRecordInfo:
          AccountRecordInfo.fromJson(json['account_record_info']),
      lastActive: Timestamp.fromJson(json['last_active']),
    );

Map<String, dynamic> _$$UserLoginImplToJson(_$UserLoginImpl instance) =>
    <String, dynamic>{
      'super_identity_record_key': instance.superIdentityRecordKey.toJson(),
      'identity_secret': instance.identitySecret.toJson(),
      'account_record_info': instance.accountRecordInfo.toJson(),
      'last_active': instance.lastActive.toJson(),
    };
