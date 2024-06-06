import 'dart:convert';
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';
import 'package:veilid_support/veilid_support.dart';
import '../../../proto/proto.dart' as proto;

class MessageIntegrity {
  MessageIntegrity._({
    required TypedKey author,
    required VeilidCryptoSystem crypto,
  })  : _author = author,
        _crypto = crypto;
  static Future<MessageIntegrity> create({required TypedKey author}) async {
    final crypto = await Veilid.instance.getCryptoSystem(author.kind);
    return MessageIntegrity._(author: author, crypto: crypto);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public interface

  Future<Uint8List> generateMessageId(proto.Message? previous) async {
    if (previous == null) {
      // If there's no last sent message,
      // we start at a hash of the identity public key
      return _generateInitialId();
    } else {
      // If there is a last message, we generate the hash
      // of the last message's signature and use it as our next id
      return _hashSignature(previous.signature);
    }
  }

  Future<void> signMessage(
    proto.Message message,
    SecretKey authorSecret,
  ) async {
    // Ensure this message is not already signed
    assert(!message.hasSignature(), 'should not sign message twice');
    // Generate data to sign
    final data = Uint8List.fromList(utf8.encode(message.writeToJson()));

    // Sign with our identity
    final signature = await _crypto.sign(_author.value, authorSecret, data);

    // Add to the message
    message.signature = signature.toProto();
  }

  Future<bool> verifyMessage(proto.Message message) async {
    // Ensure the message is signed
    assert(message.hasSignature(), 'should not verify unsigned message');
    final signature = message.signature.toVeilid();

    // Generate data to sign
    final messageNoSig = message.deepCopy()..clearSignature();
    final data = Uint8List.fromList(utf8.encode(messageNoSig.writeToJson()));

    // Verify signature
    return _crypto.verify(_author.value, data, signature);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Private implementation

  Future<Uint8List> _generateInitialId() async =>
      (await _crypto.generateHash(_author.decode())).decode();

  Future<Uint8List> _hashSignature(proto.Signature signature) async =>
      (await _crypto.generateHash(signature.toVeilid().decode())).decode();
  ////////////////////////////////////////////////////////////////////////////
  final TypedKey _author;
  final VeilidCryptoSystem _crypto;
}
