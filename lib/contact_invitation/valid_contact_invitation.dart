//////////////////////////////////////////////////
///

class ValidContactInvitation {
  ValidContactInvitation._(
      {required ContactInvitationListManager contactInvitationManager,
      required proto.SignedContactInvitation signedContactInvitation,
      required proto.ContactInvitation contactInvitation,
      required TypedKey contactRequestInboxKey,
      required proto.ContactRequest contactRequest,
      required proto.ContactRequestPrivate contactRequestPrivate,
      required IdentityMaster contactIdentityMaster,
      required KeyPair writer})
      : _contactInvitationManager = contactInvitationManager,
        _signedContactInvitation = signedContactInvitation,
        _contactInvitation = contactInvitation,
        _contactRequestInboxKey = contactRequestInboxKey,
        _contactRequest = contactRequest,
        _contactRequestPrivate = contactRequestPrivate,
        _contactIdentityMaster = contactIdentityMaster,
        _writer = writer;

  Future<AcceptedContact?> accept() async {
    final pool = await DHTRecordPool.instance();
    final activeAccountInfo = _contactInvitationManager._activeAccountInfo;
    try {
      // Ensure we don't delete this if we're trying to chat to self
      final isSelf = _contactIdentityMaster.identityPublicKey ==
          activeAccountInfo.localAccount.identityMaster.identityPublicKey;
      final accountRecordKey =
          activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

      return (await pool.openWrite(_contactRequestInboxKey, _writer,
              parent: accountRecordKey))
          // ignore: prefer_expression_function_bodies
          .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
        // Create local conversation key for this
        // contact and send via contact response
        return createConversation(
            activeAccountInfo: activeAccountInfo,
            remoteIdentityPublicKey:
                _contactIdentityMaster.identityPublicTypedKey(),
            callback: (localConversation) async {
              final contactResponse = proto.ContactResponse()
                ..accept = true
                ..remoteConversationRecordKey = localConversation.key.toProto()
                ..identityMasterRecordKey = activeAccountInfo
                    .localAccount.identityMaster.masterRecordKey
                    .toProto();
              final contactResponseBytes = contactResponse.writeToBuffer();

              final cs = await pool.veilid
                  .getCryptoSystem(_contactRequestInboxKey.kind);

              final identitySignature = await cs.sign(
                  activeAccountInfo
                      .localAccount.identityMaster.identityPublicKey,
                  activeAccountInfo.userLogin.identitySecret.value,
                  contactResponseBytes);

              final signedContactResponse = proto.SignedContactResponse()
                ..contactResponse = contactResponseBytes
                ..identitySignature = identitySignature.toProto();

              // Write the acceptance to the inbox
              if (await contactRequestInbox.tryWriteProtobuf(
                      proto.SignedContactResponse.fromBuffer,
                      signedContactResponse,
                      subkey: 1) !=
                  null) {
                throw Exception('failed to accept contact invitation');
              }
              return AcceptedContact(
                profile: _contactRequestPrivate.profile,
                remoteIdentity: _contactIdentityMaster,
                remoteConversationRecordKey: proto.TypedKeyProto.fromProto(
                    _contactRequestPrivate.chatRecordKey),
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
    final pool = await DHTRecordPool.instance();
    final activeAccountInfo = _contactInvitationManager._activeAccountInfo;

    // Ensure we don't delete this if we're trying to chat to self
    final isSelf = _contactIdentityMaster.identityPublicKey ==
        activeAccountInfo.localAccount.identityMaster.identityPublicKey;
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    return (await pool.openWrite(_contactRequestInboxKey, _writer,
            parent: accountRecordKey))
        .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
      final cs =
          await pool.veilid.getCryptoSystem(_contactRequestInboxKey.kind);

      final contactResponse = proto.ContactResponse()
        ..accept = false
        ..identityMasterRecordKey = activeAccountInfo
            .localAccount.identityMaster.masterRecordKey
            .toProto();
      final contactResponseBytes = contactResponse.writeToBuffer();

      final identitySignature = await cs.sign(
          activeAccountInfo.localAccount.identityMaster.identityPublicKey,
          activeAccountInfo.userLogin.identitySecret.value,
          contactResponseBytes);

      final signedContactResponse = proto.SignedContactResponse()
        ..contactResponse = contactResponseBytes
        ..identitySignature = identitySignature.toProto();

      // Write the rejection to the inbox
      if (await contactRequestInbox.tryWriteProtobuf(
              proto.SignedContactResponse.fromBuffer, signedContactResponse,
              subkey: 1) !=
          null) {
        log.error('failed to reject contact invitation');
        return false;
      }
      return true;
    });
  }

  //
  ContactInvitationListManager _contactInvitationManager;
  proto.SignedContactInvitation _signedContactInvitation;
  proto.ContactInvitation _contactInvitation;
  TypedKey _contactRequestInboxKey;
  proto.ContactRequest _contactRequest;
  proto.ContactRequestPrivate _contactRequestPrivate;
  IdentityMaster _contactIdentityMaster;
  KeyPair _writer;
}
