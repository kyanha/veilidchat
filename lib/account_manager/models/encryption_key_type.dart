// Local account identitySecretKey is potentially encrypted with a key
// using the following mechanisms
// * None : no key, bytes are unencrypted
// * Pin : Code is a numeric pin (4-256 numeric digits) hashed with Argon2
// * Password: Code is a UTF-8 string that is hashed with Argon2

import 'dart:typed_data';

import 'package:change_case/change_case.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../proto/proto.dart' as proto;

enum EncryptionKeyType {
  none,
  pin,
  password;

  factory EncryptionKeyType.fromJson(dynamic j) =>
      EncryptionKeyType.values.byName((j as String).toCamelCase());

  factory EncryptionKeyType.fromProto(proto.EncryptionKeyType p) {
    // ignore: exhaustive_cases
    switch (p) {
      case proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_NONE:
        return EncryptionKeyType.none;
      case proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PIN:
        return EncryptionKeyType.pin;
      case proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PASSWORD:
        return EncryptionKeyType.password;
    }
    throw StateError('unknown EncryptionKeyType enum value');
  }
  String toJson() => name.toPascalCase();
  proto.EncryptionKeyType toProto() => switch (this) {
        EncryptionKeyType.none =>
          proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_NONE,
        EncryptionKeyType.pin =>
          proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PIN,
        EncryptionKeyType.password =>
          proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PASSWORD,
      };

  Future<Uint8List> encryptSecretToBytes(
      {required SecretKey secret,
      required CryptoKind cryptoKind,
      String encryptionKey = ''}) async {
    late final Uint8List secretBytes;
    switch (this) {
      case EncryptionKeyType.none:
        secretBytes = secret.decode();
      case EncryptionKeyType.pin:
      case EncryptionKeyType.password:
        final cs = await Veilid.instance.getCryptoSystem(cryptoKind);

        secretBytes =
            await cs.encryptAeadWithPassword(secret.decode(), encryptionKey);
    }
    return secretBytes;
  }

  Future<SecretKey> decryptSecretFromBytes(
      {required Uint8List secretBytes,
      required CryptoKind cryptoKind,
      String encryptionKey = ''}) async {
    late final SecretKey secret;
    switch (this) {
      case EncryptionKeyType.none:
        secret = SecretKey.fromBytes(secretBytes);
      case EncryptionKeyType.pin:
      case EncryptionKeyType.password:
        final cs = await Veilid.instance.getCryptoSystem(cryptoKind);

        secret = SecretKey.fromBytes(
            await cs.decryptAeadWithPassword(secretBytes, encryptionKey));
    }
    return secret;
  }
}
