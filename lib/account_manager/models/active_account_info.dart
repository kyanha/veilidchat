import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import 'local_account/local_account.dart';
import 'user_login/user_login.dart';

@immutable
class ActiveAccountInfo {
  const ActiveAccountInfo({
    required this.localAccount,
    required this.userLogin,
    //required this.accountRecord,
  });
  //

  TypedKey get accountRecordKey =>
      userLogin.accountRecordInfo.accountRecord.recordKey;

  KeyPair get conversationWriter {
    final identityKey = localAccount.identityMaster.identityPublicKey;
    final identitySecret = userLogin.identitySecret;
    return KeyPair(key: identityKey, secret: identitySecret.value);
  }

  Future<DHTRecordCrypto> makeConversationCrypto(
      TypedKey remoteIdentityPublicKey) async {
    final identitySecret = userLogin.identitySecret;
    final cs = await Veilid.instance.getCryptoSystem(identitySecret.kind);
    final sharedSecret = await cs.generateSharedSecret(
        remoteIdentityPublicKey.value,
        identitySecret.value,
        utf8.encode('VeilidChat Conversation'));

    final messagesCrypto = await DHTRecordCryptoPrivate.fromSecret(
        identitySecret.kind, sharedSecret);
    return messagesCrypto;
  }

  //
  final LocalAccount localAccount;
  final UserLogin userLogin;
  //final DHTRecord accountRecord;
}
