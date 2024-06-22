import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../conversation/conversation.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import 'models.dart';

//////////////////////////////////////////////////
///

class ValidContactInvitation {
  @internal
  ValidContactInvitation(
      {required AccountInfo accountInfo,
      required TypedKey contactRequestInboxKey,
      required proto.ContactRequestPrivate contactRequestPrivate,
      required SuperIdentity contactSuperIdentity,
      required KeyPair writer})
      : _accountInfo = accountInfo,
        _contactRequestInboxKey = contactRequestInboxKey,
        _contactRequestPrivate = contactRequestPrivate,
        _contactSuperIdentity = contactSuperIdentity,
        _writer = writer;

  proto.Profile get remoteProfile => _contactRequestPrivate.profile;

  Future<AcceptedContact?> accept(proto.Profile profile) async {
    final pool = DHTRecordPool.instance;
    try {
      // Ensure we don't delete this if we're trying to chat to self
      // The initiating side will delete the records in deleteInvitation()
      final isSelf = _contactSuperIdentity.currentInstance.publicKey ==
          _accountInfo.identityPublicKey;

      return (await pool.openRecordWrite(_contactRequestInboxKey, _writer,
              debugName: 'ValidContactInvitation::accept::'
                  'ContactRequestInbox',
              parent: pool.getParentRecordKey(_contactRequestInboxKey) ??
                  _accountInfo.accountRecordKey))
          // ignore: prefer_expression_function_bodies
          .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
        // Create local conversation key for this
        // contact and send via contact response
        final conversation = ConversationCubit(
            accountInfo: _accountInfo,
            remoteIdentityPublicKey:
                _contactSuperIdentity.currentInstance.typedPublicKey);
        return conversation.initLocalConversation(
            profile: profile,
            callback: (localConversation) async {
              final contactResponse = proto.ContactResponse()
                ..accept = true
                ..remoteConversationRecordKey = localConversation.key.toProto()
                ..superIdentityRecordKey =
                    _accountInfo.superIdentityRecordKey.toProto();
              final contactResponseBytes = contactResponse.writeToBuffer();

              final cs = await _accountInfo.identityCryptoSystem;
              final identitySignature = await cs.signWithKeyPair(
                  _accountInfo.identityWriter, contactResponseBytes);

              final signedContactResponse = proto.SignedContactResponse()
                ..contactResponse = contactResponseBytes
                ..identitySignature = identitySignature.toProto();

              // Write the acceptance to the inbox
              await contactRequestInbox
                  .eventualWriteProtobuf(signedContactResponse, subkey: 1);

              return AcceptedContact(
                remoteProfile: _contactRequestPrivate.profile,
                remoteIdentity: _contactSuperIdentity,
                remoteConversationRecordKey:
                    _contactRequestPrivate.chatRecordKey.toVeilid(),
                localConversationRecordKey: localConversation.key,
              );
            });
      });
    } on Exception catch (e) {
      log.debug('exception: $e', e);
      return null;
    }
  }

  Future<bool> reject() async {
    final pool = DHTRecordPool.instance;

    // Ensure we don't delete this if we're trying to chat to self
    final isSelf = _contactSuperIdentity.currentInstance.publicKey ==
        _accountInfo.identityPublicKey;

    return (await pool.openRecordWrite(_contactRequestInboxKey, _writer,
            debugName: 'ValidContactInvitation::reject::'
                'ContactRequestInbox',
            parent: _accountInfo.accountRecordKey))
        .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
      final contactResponse = proto.ContactResponse()
        ..accept = false
        ..superIdentityRecordKey =
            _accountInfo.superIdentityRecordKey.toProto();
      final contactResponseBytes = contactResponse.writeToBuffer();

      final cs = await _accountInfo.identityCryptoSystem;
      final identitySignature = await cs.signWithKeyPair(
          _accountInfo.identityWriter, contactResponseBytes);

      final signedContactResponse = proto.SignedContactResponse()
        ..contactResponse = contactResponseBytes
        ..identitySignature = identitySignature.toProto();

      // Write the rejection to the inbox
      await contactRequestInbox.eventualWriteProtobuf(signedContactResponse,
          subkey: 1);
      return true;
    });
  }

  //
  final AccountInfo _accountInfo;
  final TypedKey _contactRequestInboxKey;
  final SuperIdentity _contactSuperIdentity;
  final KeyPair _writer;
  final proto.ContactRequestPrivate _contactRequestPrivate;
}
