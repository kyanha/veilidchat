// Local account identitySecretKey is potentially encrypted with a key
// using the following mechanisms
// * None : no key, bytes are unencrypted
// * Pin : Code is a numeric pin (4-256 numeric digits) hashed with Argon2
// * Password: Code is a UTF-8 string that is hashed with Argon2

import 'package:change_case/change_case.dart';

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
}
