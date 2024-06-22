import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../account_manager.dart';

enum AccountInfoStatus {
  accountInvalid,
  accountLocked,
  accountUnlocked,
}

@immutable
class AccountInfo extends Equatable {
  const AccountInfo({
    required this.status,
    required this.localAccount,
    required this.userLogin,
  });

  final AccountInfoStatus status;
  final LocalAccount localAccount;
  final UserLogin? userLogin;

  @override
  List<Object?> get props => [
        status,
        localAccount,
        userLogin,
      ];
}

extension AccountInfoExt on AccountInfo {
  TypedKey get superIdentityRecordKey => localAccount.superIdentity.recordKey;
  TypedKey get accountRecordKey =>
      userLogin!.accountRecordInfo.accountRecord.recordKey;
  TypedKey get identityTypedPublicKey =>
      localAccount.superIdentity.currentInstance.typedPublicKey;
  PublicKey get identityPublicKey =>
      localAccount.superIdentity.currentInstance.publicKey;
  SecretKey get identitySecretKey => userLogin!.identitySecret.value;
  KeyPair get identityWriter =>
      KeyPair(key: identityPublicKey, secret: identitySecretKey);
  Future<VeilidCryptoSystem> get identityCryptoSystem =>
      localAccount.superIdentity.currentInstance.cryptoSystem;

  Future<VeilidCrypto> makeConversationCrypto(
      TypedKey remoteIdentityPublicKey) async {
    final identitySecret = userLogin!.identitySecret;
    final cs = await Veilid.instance.getCryptoSystem(identitySecret.kind);
    final sharedSecret = await cs.generateSharedSecret(
        remoteIdentityPublicKey.value,
        identitySecret.value,
        utf8.encode('VeilidChat Conversation'));

    final messagesCrypto = await VeilidCryptoPrivate.fromSharedSecret(
        identitySecret.kind, sharedSecret);
    return messagesCrypto;
  }
}
