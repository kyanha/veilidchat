import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:veilid_support/veilid_support.dart';

part 'user_login.freezed.dart';
part 'user_login.g.dart';

// Represents a currently logged in account
// User logins are stored in the user_logins tablestore table
// indexed by the accountMasterKey
@freezed
class UserLogin with _$UserLogin {
  const factory UserLogin({
    // Master record key for the user used to index the local accounts table
    required TypedKey accountMasterRecordKey,
    // The identity secret as unlocked from the local accounts table
    required TypedSecret identitySecret,
    // The account record key, owner key and secret pulled from the identity
    required AccountRecordInfo accountRecordInfo,

    // The time this login was most recently used
    required Timestamp lastActive,
  }) = _UserLogin;

  factory UserLogin.fromJson(dynamic json) =>
      _$UserLoginFromJson(json as Map<String, dynamic>);
}
