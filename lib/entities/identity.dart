import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

part 'identity.freezed.dart';
part 'identity.g.dart';

// AccountOwnerInfo is the key and owner info for the account dht key that is
// stored in the identity key
@freezed
class AccountOwnerInfo with _$AccountOwnerInfo {
  const factory AccountOwnerInfo({
    // Top level account keys and secrets
    required Map<String, TypedKeyPair> accountKeyPairs,
  }) = _AccountOwnerInfo;

  factory AccountOwnerInfo.fromJson(Map<String, dynamic> json) =>
      _$AccountOwnerInfoFromJson(json);
}

// Identity Key points to accounts associated with this identity
// accounts field has a map of service name or uuid to account key pairs
// DHT Schema: DFLT(1)
// DHT Key (Private): identityRecordKey
// DHT Owner Key: identityPublicKey
// DHT Secret: identitySecretKey (stored encrypted with unlock code in local table store)
@freezed
class Identity with _$Identity {
  const factory Identity({
    // Top level account keys and secrets
    required Map<String, TypedKeyPair> accountKeyPairs,
  }) = _Identity;

  factory Identity.fromJson(Map<String, dynamic> json) =>
      _$IdentityFromJson(json);
}

// Identity Master key structure for created account
// Master key allows for regeneration of identity DHT record
// Bidirectional Master<->Identity signature allows for
// chain of identity ownership for account recovery process
//
// Backed by a DHT key at masterRecordKey, the secret is kept
// completely offline and only written to upon account recovery
//
// DHT Schema: DFLT(1)
// DHT Record Key (Public): masterRecordKey
// DHT Owner Key: masterPublicKey
// DHT Owner Secret: masterSecretKey (kept offline)
// Encryption: None
@freezed
class IdentityMaster with _$IdentityMaster {
  const factory IdentityMaster(
      {
      // Private DHT record storing identity account mapping
      required TypedKey identityRecordKey,
      // Public key of identity
      required PublicKey identityPublicKey,
      // Public DHT record storing this structure for account recovery
      required TypedKey masterRecordKey,
      // Public key of master identity used to sign identity keys for recovery
      required PublicKey masterPublicKey,
      // Signature of identityRecordKey and identityPublicKey by masterPublicKey
      required Signature identitySignature,
      // Signature of masterRecordKey and masterPublicKey by identityPublicKey
      required Signature masterSignature}) = _IdentityMaster;

  factory IdentityMaster.fromJson(Map<String, dynamic> json) =>
      _$IdentityMasterFromJson(json);
}

extension IdentityMasterExtension on IdentityMaster {
  KeyPair identityWriter(SecretKey secret) {
    return KeyPair(key: identityPublicKey, secret: secret);
  }

  KeyPair masterWriter(SecretKey secret) {
    return KeyPair(key: masterPublicKey, secret: secret);
  }
}

// Identity Master with secrets
// Not freezed because we never persist this class in its entirety
class IdentityMasterWithSecrets {
  IdentityMaster identityMaster;
  SecretKey masterSecret;
  SecretKey identitySecret;
  IdentityMasterWithSecrets(
      {required this.identityMaster,
      required this.masterSecret,
      required this.identitySecret});
}
