import 'dart:async';
import 'dart:typed_data';
import '../../../veilid_support.dart';

abstract class VeilidCrypto {
  Future<Uint8List> encrypt(Uint8List data);
  Future<Uint8List> decrypt(Uint8List data);
}

////////////////////////////////////
/// Encrypted for a specific symmetric key
class VeilidCryptoPrivate implements VeilidCrypto {
  VeilidCryptoPrivate._(VeilidCryptoSystem cryptoSystem, SharedSecret secretKey)
      : _cryptoSystem = cryptoSystem,
        _secretKey = secretKey;
  final VeilidCryptoSystem _cryptoSystem;
  final SharedSecret _secretKey;

  static Future<VeilidCryptoPrivate> fromTypedKeyPair(
      TypedKeyPair typedKeyPair) async {
    final cryptoSystem =
        await Veilid.instance.getCryptoSystem(typedKeyPair.kind);
    final secretKey = typedKeyPair.secret;
    return VeilidCryptoPrivate._(cryptoSystem, secretKey);
  }

  static Future<VeilidCryptoPrivate> fromSecret(
      CryptoKind kind, SharedSecret secretKey) async {
    final cryptoSystem = await Veilid.instance.getCryptoSystem(kind);
    return VeilidCryptoPrivate._(cryptoSystem, secretKey);
  }

  @override
  Future<Uint8List> encrypt(Uint8List data) =>
      _cryptoSystem.encryptNoAuthWithNonce(data, _secretKey);

  @override
  Future<Uint8List> decrypt(Uint8List data) =>
      _cryptoSystem.decryptNoAuthWithNonce(data, _secretKey);
}

////////////////////////////////////
/// No encryption
class VeilidCryptoPublic implements VeilidCrypto {
  const VeilidCryptoPublic();

  @override
  Future<Uint8List> encrypt(Uint8List data) async => data;

  @override
  Future<Uint8List> decrypt(Uint8List data) async => data;
}
