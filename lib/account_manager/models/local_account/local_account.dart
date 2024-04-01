import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../models/encryption_key_type.dart';

part 'local_account.g.dart';
part 'local_account.freezed.dart';

// Local Accounts are stored in a table locally and not backed by a DHT key
// and represents the accounts that have been added/imported
// on the current device.
// Stores a copy of the IdentityMaster associated with the account
// and the identitySecretKey optionally encrypted by an unlock code
// This is the root of the account information tree for VeilidChat
//
@freezed
class LocalAccount with _$LocalAccount {
  const factory LocalAccount({
    // The master key record for the account, containing the identityPublicKey
    required IdentityMaster identityMaster,
    // The encrypted identity secret that goes with
    // the identityPublicKey with appended salt
    @Uint8ListJsonConverter() required Uint8List identitySecretBytes,
    // The kind of encryption input used on the account
    required EncryptionKeyType encryptionKeyType,
    // If account is not hidden, password can be retrieved via
    required bool biometricsEnabled,
    // Keep account hidden unless account password is entered
    // (tries all hidden accounts with auth method (no biometrics))
    required bool hiddenAccount,
    // Display name for account until it is unlocked
    required String name,
  }) = _LocalAccount;

  factory LocalAccount.fromJson(dynamic json) =>
      _$LocalAccountFromJson(json as Map<String, dynamic>);
}
