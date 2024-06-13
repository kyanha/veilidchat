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
      {required UnlockedAccountInfo activeAccountInfo,
      required proto.Account account,
      required TypedKey contactRequestInboxKey,
      required proto.ContactRequestPrivate contactRequestPrivate,
      required SuperIdentity contactSuperIdentity,
      required KeyPair writer})
      : _activeAccountInfo = activeAccountInfo,
        _account = account,
        _contactRequestInboxKey = contactRequestInboxKey,
        _contactRequestPrivate = contactRequestPrivate,
        _contactSuperIdentity = contactSuperIdentity,
        _writer = writer;

  proto.Profile get remoteProfile => _contactRequestPrivate.profile;

  Future<AcceptedContact?> accept() async {
    final pool = DHTRecordPool.instance;
    try {
      // Ensure we don't delete this if we're trying to chat to self
      // The initiating side will delete the records in deleteInvitation()
      final isSelf = _contactSuperIdentity.currentInstance.publicKey ==
          _activeAccountInfo.identityPublicKey;
      final accountRecordKey = _activeAccountInfo.accountRecordKey;

      return (await pool.openRecordWrite(_contactRequestInboxKey, _writer,
              debugName: 'ValidContactInvitation::accept::'
                  'ContactRequestInbox',
              parent: accountRecordKey))
          // ignore: prefer_expression_function_bodies
          .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
        // Create local conversation key for this
        // contact and send via contact response
        final conversation = ConversationCubit(
            activeAccountInfo: _activeAccountInfo,
            remoteIdentityPublicKey:
                _contactSuperIdentity.currentInstance.typedPublicKey);
        return conversation.initLocalConversation(
            profile: _account.profile,
            callback: (localConversation) async {
              final contactResponse = proto.ContactResponse()
                ..accept = true
                ..remoteConversationRecordKey = localConversation.key.toProto()
                ..superIdentityRecordKey =
                    _activeAccountInfo.superIdentityRecordKey.toProto();
              final contactResponseBytes = contactResponse.writeToBuffer();

              final cs = await pool.veilid
                  .getCryptoSystem(_contactRequestInboxKey.kind);

              final identitySignature = await cs.sign(
                  _activeAccountInfo.identityWriter.key,
                  _activeAccountInfo.identityWriter.secret,
                  contactResponseBytes);

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
        _activeAccountInfo.identityPublicKey;
    final accountRecordKey = _activeAccountInfo.accountRecordKey;

    return (await pool.openRecordWrite(_contactRequestInboxKey, _writer,
            debugName: 'ValidContactInvitation::reject::'
                'ContactRequestInbox',
            parent: accountRecordKey))
        .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
      final cs =
          await pool.veilid.getCryptoSystem(_contactRequestInboxKey.kind);

      final contactResponse = proto.ContactResponse()
        ..accept = false
        ..superIdentityRecordKey =
            _activeAccountInfo.superIdentityRecordKey.toProto();
      final contactResponseBytes = contactResponse.writeToBuffer();

      final identitySignature = await cs.sign(
          _activeAccountInfo.identityWriter.key,
          _activeAccountInfo.identityWriter.secret,
          contactResponseBytes);

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
  final UnlockedAccountInfo _activeAccountInfo;
  final proto.Account _account;
  final TypedKey _contactRequestInboxKey;
  final SuperIdentity _contactSuperIdentity;
  final KeyPair _writer;
  final proto.ContactRequestPrivate _contactRequestPrivate;
}
