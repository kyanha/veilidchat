import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../src/veilid_log.dart';
import '../veilid_support.dart';
import 'exceptions.dart';

part 'identity_instance.freezed.dart';
part 'identity_instance.g.dart';

@freezed
class IdentityInstance with _$IdentityInstance {
  const factory IdentityInstance({
    // Private DHT record storing identity account mapping
    required TypedKey recordKey,

    // Public key of identity instance
    required PublicKey publicKey,

    // Secret key of identity instance
    // Encrypted with DH(publicKey, SuperIdentity.secret) with appended salt
    // Used to recover accounts without generating a new instance
    @Uint8ListJsonConverter() required Uint8List encryptedSecretKey,

    // Signature of SuperInstance recordKey and SuperInstance publicKey
    // by publicKey
    required Signature superSignature,

    // Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
    // by SuperIdentity publicKey
    required Signature signature,
  }) = _IdentityInstance;

  factory IdentityInstance.fromJson(dynamic json) =>
      _$IdentityInstanceFromJson(json as Map<String, dynamic>);

  const IdentityInstance._();

  ////////////////////////////////////////////////////////////////////////////
  // Public interface

  /// Delete this identity instance record
  /// Only deletes from the local machine not the DHT
  Future<void> delete() async {
    final pool = DHTRecordPool.instance;
    await pool.deleteRecord(recordKey);
  }

  Future<VeilidCryptoSystem> get cryptoSystem =>
      Veilid.instance.getCryptoSystem(recordKey.kind);

  Future<VeilidCrypto> getPrivateCrypto(SecretKey secretKey) async =>
      DHTRecordPool.privateCryptoFromTypedSecret(
          TypedKey(kind: recordKey.kind, value: secretKey));

  KeyPair writer(SecretKey secret) => KeyPair(key: publicKey, secret: secret);

  TypedKey get typedPublicKey =>
      TypedKey(kind: recordKey.kind, value: publicKey);

  Future<VeilidCryptoSystem> validateIdentitySecret(SecretKey secretKey) async {
    final cs = await cryptoSystem;
    final keyOk = await cs.validateKeyPair(publicKey, secretKey);
    if (!keyOk) {
      throw IdentityException.invalid;
    }
    return cs;
  }

  /// Read the account record info for a specific accountKey from the identity
  /// instance record using the identity instance secret key to decrypt
  Future<List<AccountRecordInfo>> readAccount(
      {required TypedKey superRecordKey,
      required SecretKey secretKey,
      required String accountKey}) async {
    // Read the identity key to get the account keys
    final pool = DHTRecordPool.instance;

    final identityRecordCrypto = await getPrivateCrypto(secretKey);

    late final List<AccountRecordInfo> accountRecordInfo;
    await (await pool.openRecordRead(recordKey,
            debugName: 'IdentityInstance::readAccounts::IdentityRecord',
            parent: superRecordKey,
            crypto: identityRecordCrypto))
        .scope((identityRec) async {
      final identity = await identityRec.getJson(Identity.fromJson);
      if (identity == null) {
        // Identity could not be read or decrypted from DHT
        throw IdentityException.readError;
      }
      final accountRecords = IMapOfSets.from(identity.accountRecords);
      final vcAccounts = accountRecords.get(accountKey);

      accountRecordInfo = vcAccounts.toList();
    });

    return accountRecordInfo;
  }

  /// Creates a new Account associated with super identity and store it in the
  /// identity instance record.
  Future<AccountRecordInfo> addAccount({
    required TypedKey superRecordKey,
    required SecretKey secretKey,
    required String accountKey,
    required Future<Uint8List> Function(TypedKey parent) createAccountCallback,
    int maxAccounts = 1,
  }) async {
    final pool = DHTRecordPool.instance;

    /////// Add account with profile to DHT

    // Open identity key for writing
    veilidLoggy.debug('Opening identity record');
    return (await pool.openRecordWrite(recordKey, writer(secretKey),
            debugName: 'IdentityInstance::addAccount::IdentityRecord',
            parent: superRecordKey))
        .scope((identityRec) async {
      // Create new account to insert into identity
      veilidLoggy.debug('Creating new account');
      return (await pool.createRecord(
              debugName:
                  'IdentityInstance::addAccount::IdentityRecord::AccountRecord',
              parent: identityRec.key))
          .deleteScope((accountRec) async {
        final account = await createAccountCallback(accountRec.key);
        // Write account key
        veilidLoggy.debug('Writing account record');
        await accountRec.eventualWriteBytes(account);

        // Update identity key to include account
        final newAccountRecordInfo = AccountRecordInfo(
            accountRecord: OwnedDHTRecordPointer(
                recordKey: accountRec.key, owner: accountRec.ownerKeyPair!));

        veilidLoggy.debug('Updating identity with new account');
        await identityRec.eventualUpdateJson(Identity.fromJson,
            (oldIdentity) async {
          if (oldIdentity == null) {
            throw IdentityException.readError;
          }
          final oldAccountRecords = IMapOfSets.from(oldIdentity.accountRecords);

          if (oldAccountRecords.get(accountKey).length >= maxAccounts) {
            throw IdentityException.limitExceeded;
          }
          final accountRecords =
              oldAccountRecords.add(accountKey, newAccountRecordInfo).asIMap();
          return oldIdentity.copyWith(accountRecords: accountRecords);
        });

        return newAccountRecordInfo;
      });
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // Internal implementation

  Future<bool> validateIdentityInstance(
      {required TypedKey superRecordKey,
      required PublicKey superPublicKey}) async {
    final sigValid = await IdentityInstance.validateIdentitySignature(
        recordKey: recordKey,
        publicKey: publicKey,
        encryptedSecretKey: encryptedSecretKey,
        superSignature: superSignature,
        superPublicKey: superPublicKey,
        signature: signature);
    if (!sigValid) {
      return false;
    }

    final superSigValid = await IdentityInstance.validateSuperSignature(
        superRecordKey: superRecordKey,
        superPublicKey: superPublicKey,
        publicKey: publicKey,
        superSignature: superSignature);
    if (!superSigValid) {
      return false;
    }

    return true;
  }

  static Uint8List signatureBytes({
    required TypedKey recordKey,
    required PublicKey publicKey,
    required Uint8List encryptedSecretKey,
    required Signature superSignature,
  }) {
    final sigBuf = BytesBuilder()
      ..add(recordKey.decode())
      ..add(publicKey.decode())
      ..add(encryptedSecretKey)
      ..add(superSignature.decode());
    return sigBuf.toBytes();
  }

  static Future<bool> validateIdentitySignature({
    required TypedKey recordKey,
    required PublicKey publicKey,
    required Uint8List encryptedSecretKey,
    required Signature superSignature,
    required PublicKey superPublicKey,
    required Signature signature,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(recordKey.kind);
    final identitySigBytes = IdentityInstance.signatureBytes(
        recordKey: recordKey,
        publicKey: publicKey,
        encryptedSecretKey: encryptedSecretKey,
        superSignature: superSignature);
    return cs.verify(superPublicKey, identitySigBytes, signature);
  }

  static Future<Signature> createIdentitySignature({
    required TypedKey recordKey,
    required PublicKey publicKey,
    required Uint8List encryptedSecretKey,
    required Signature superSignature,
    required PublicKey superPublicKey,
    required SecretKey superSecret,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(recordKey.kind);
    final identitySigBytes = IdentityInstance.signatureBytes(
        recordKey: recordKey,
        publicKey: publicKey,
        encryptedSecretKey: encryptedSecretKey,
        superSignature: superSignature);
    return cs.sign(superPublicKey, superSecret, identitySigBytes);
  }

  static Uint8List superSignatureBytes({
    required TypedKey superRecordKey,
    required PublicKey superPublicKey,
  }) {
    final superSigBuf = BytesBuilder()
      ..add(superRecordKey.decode())
      ..add(superPublicKey.decode());
    return superSigBuf.toBytes();
  }

  static Future<bool> validateSuperSignature({
    required TypedKey superRecordKey,
    required PublicKey superPublicKey,
    required PublicKey publicKey,
    required Signature superSignature,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(superRecordKey.kind);
    final superSigBytes = IdentityInstance.superSignatureBytes(
      superRecordKey: superRecordKey,
      superPublicKey: superPublicKey,
    );
    return cs.verify(publicKey, superSigBytes, superSignature);
  }

  static Future<Signature> createSuperSignature({
    required TypedKey superRecordKey,
    required PublicKey superPublicKey,
    required PublicKey publicKey,
    required SecretKey secretKey,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(superRecordKey.kind);
    final superSigBytes = IdentityInstance.superSignatureBytes(
      superRecordKey: superRecordKey,
      superPublicKey: superPublicKey,
    );
    return cs.sign(publicKey, secretKey, superSigBytes);
  }
}
