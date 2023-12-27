// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_logins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActiveLoginsImpl _$$ActiveLoginsImplFromJson(Map<String, dynamic> json) =>
    _$ActiveLoginsImpl(
      userLogins: IList<UserLogin>.fromJson(
          json['user_logins'], (value) => UserLogin.fromJson(value)),
      activeUserLogin: json['active_user_login'] == null
          ? null
          : Typed<FixedEncodedString43>.fromJson(json['active_user_login']),
    );

Map<String, dynamic> _$$ActiveLoginsImplToJson(_$ActiveLoginsImpl instance) =>
    <String, dynamic>{
      'user_logins': instance.userLogins.toJson(
        (value) => value.toJson(),
      ),
      'active_user_login': instance.activeUserLogin?.toJson(),
    };
