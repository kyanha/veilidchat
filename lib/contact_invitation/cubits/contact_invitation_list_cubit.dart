import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import '../models/models.dart';

//////////////////////////////////////////////////

class ContactInviteInvalidKeyException implements Exception {
  const ContactInviteInvalidKeyException(this.type) : super();
  final EncryptionKeyType type;
}

typedef GetEncryptionKeyCallback = Future<SecretKey?> Function(
    VeilidCryptoSystem cs,
    EncryptionKeyType encryptionKeyType,
    Uint8List encryptedSecret);

@immutable
class InvitationStatus {
  const InvitationStatus({required this.acceptedContact});
  final AcceptedContact? acceptedContact;
}

//////////////////////////////////////////////////

//////////////////////////////////////////////////
// Mutable state for per-account contact invitations

class ContactInvitationListCubit
    extends DHTShortArrayCubit<proto.ContactInvitationRecord> {
  ContactInvitationListCubit({
    required ActiveAccountInfo activeAccountInfo,
    required proto.Account account,
  })  : _activeAccountInfo = activeAccountInfo,
        _account = account,
        super(
            open: () => _open(activeAccountInfo, account),
            decodeElement: proto.ContactInvitationRecord.fromBuffer);

  static Future<DHTShortArray> _open(
      ActiveAccountInfo activeAccountInfo, proto.Account account) async {
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final contactInvitationListRecordKey =
        account.contactInvitationRecords.toVeilid();

    final dhtRecord = await DHTShortArray.openOwned(
        contactInvitationListRecordKey,
        parent: accountRecordKey);

    return dhtRecord;
  }

  Future<Uint8List> createInvitation(
      {required EncryptionKeyType encryptionKeyType,
      required String encryptionKey,
      required String message,
      required Timestamp? expiration}) async {
    final pool = DHTRecordPool.instance;

    // Generate writer keypair to share with new contact
    final cs = await pool.veilid.bestCryptoSystem();
    final contactRequestWriter = await cs.generateKeyPair();
    final conversationWriter = _activeAccountInfo.conversationWriter;

    // Encrypt the writer secret with the encryption key
    final encryptedSecret = await encryptionKeyType.encryptSecretToBytes(
      secret: contactRequestWriter.secret,
      cryptoKind: cs.kind(),
      encryptionKey: encryptionKey,
    );

    // Create local conversation DHT record with the account record key as its
    // parent.
    // Do not set the encryption of this key yet as it will not yet be written
    // to and it will be eventually encrypted with the DH of the contact's
    // identity key
    late final Uint8List signedContactInvitationBytes;
    await (await pool.create(
            parent: _activeAccountInfo.accountRecordKey,
            schema: DHTSchema.smpl(oCnt: 0, members: [
              DHTSchemaMember(mKey: conversationWriter.key, mCnt: 1)
            ])))
        .deleteScope((localConversation) async {
      // dont bother reopening localConversation with writer
      // Make ContactRequestPrivate and encrypt with the writer secret
      final crpriv = proto.ContactRequestPrivate()
        ..writerKey = contactRequestWriter.key.toProto()
        ..profile = _account.profile
        ..identityMasterRecordKey =
            _activeAccountInfo.userLogin.accountMasterRecordKey.toProto()
        ..chatRecordKey = localConversation.key.toProto()
        ..expiration = expiration?.toInt64() ?? Int64.ZERO;
      final crprivbytes = crpriv.writeToBuffer();
      final encryptedContactRequestPrivate = await cs.encryptAeadWithNonce(
          crprivbytes, contactRequestWriter.secret);

      // Create ContactRequest and embed contactrequestprivate
      final creq = proto.ContactRequest()
        ..encryptionKeyType = encryptionKeyType.toProto()
        ..private = encryptedContactRequestPrivate;

      // Create DHT unicast inbox for ContactRequest
      await (await pool.create(
              parent: _activeAccountInfo.accountRecordKey,
              schema: DHTSchema.smpl(oCnt: 1, members: [
                DHTSchemaMember(mCnt: 1, mKey: contactRequestWriter.key)
              ]),
              crypto: const DHTRecordCryptoPublic()))
          .deleteScope((contactRequestInbox) async {
        // Store ContactRequest in owner subkey
        await contactRequestInbox.eventualWriteProtobuf(creq);

        // Create ContactInvitation and SignedContactInvitation
        final cinv = proto.ContactInvitation()
          ..contactRequestInboxKey = contactRequestInbox.key.toProto()
          ..writerSecret = encryptedSecret;
        final cinvbytes = cinv.writeToBuffer();
        final scinv = proto.SignedContactInvitation()
          ..contactInvitation = cinvbytes
          ..identitySignature = (await cs.sign(
                  conversationWriter.key, conversationWriter.secret, cinvbytes))
              .toProto();
        signedContactInvitationBytes = scinv.writeToBuffer();

        // Create ContactInvitationRecord
        final cinvrec = proto.ContactInvitationRecord()
          ..contactRequestInbox =
              contactRequestInbox.ownedDHTRecordPointer.toProto()
          ..writerKey = contactRequestWriter.key.toProto()
          ..writerSecret = contactRequestWriter.secret.toProto()
          ..localConversationRecordKey = localConversation.key.toProto()
          ..expiration = expiration?.toInt64() ?? Int64.ZERO
          ..invitation = signedContactInvitationBytes
          ..message = message;

        // Add ContactInvitationRecord to account's list
        // if this fails, don't keep retrying, user can try again later
        if (await shortArray.tryAddItem(cinvrec.writeToBuffer()) == false) {
          throw Exception('Failed to add contact invitation record');
        }
      });
    });

    return signedContactInvitationBytes;
  }

  Future<void> deleteInvitation(
      {required bool accepted,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    final pool = DHTRecordPool.instance;
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    // Remove ContactInvitationRecord from account's list
    for (var i = 0; i < shortArray.length; i++) {
      final item = await shortArray.getItemProtobuf(
          proto.ContactInvitationRecord.fromBuffer, i);
      if (item == null) {
        throw Exception('Failed to get contact invitation record');
      }
      if (item.contactRequestInbox.recordKey ==
          contactInvitationRecord.contactRequestInbox.recordKey) {
        await shortArray.tryRemoveItem(i);
        break;
      }
    }
    await (await pool.openOwned(
            contactInvitationRecord.contactRequestInbox.toVeilid(),
            parent: accountRecordKey))
        .scope((contactRequestInbox) async {
      // Wipe out old invitation so it shows up as invalid
      await contactRequestInbox.tryWriteBytes(Uint8List(0));
      await contactRequestInbox.delete();
    });
    if (!accepted) {
      await (await pool.openRead(
              contactInvitationRecord.localConversationRecordKey.toVeilid(),
              parent: accountRecordKey))
          .delete();
    }
  }

  Future<ValidContactInvitation?> validateInvitation(
      {required Uint8List inviteData,
      required GetEncryptionKeyCallback getEncryptionKeyCallback}) async {
    final pool = DHTRecordPool.instance;

    // Get contact request inbox from invitation
    final signedContactInvitation =
        proto.SignedContactInvitation.fromBuffer(inviteData);
    final contactInvitationBytes =
        Uint8List.fromList(signedContactInvitation.contactInvitation);
    final contactInvitation =
        proto.ContactInvitation.fromBuffer(contactInvitationBytes);
    final contactRequestInboxKey =
        contactInvitation.contactRequestInboxKey.toVeilid();

    ValidContactInvitation? out;

    final cs = await pool.veilid.getCryptoSystem(contactRequestInboxKey.kind);

    // Compare the invitation's contact request
    // inbox with our list of extant invitations
    // If we're chatting to ourselves,
    // we are validating an invitation we have created
    final isSelf = state.data!.value.indexWhere((cir) =>
            cir.contactRequestInbox.recordKey.toVeilid() ==
            contactRequestInboxKey) !=
        -1;

    await (await pool.openRead(contactRequestInboxKey,
            parent: _activeAccountInfo.accountRecordKey))
        .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
      //
      final contactRequest = await contactRequestInbox
          .getProtobuf(proto.ContactRequest.fromBuffer);

      // Decrypt contact request private
      final encryptionKeyType =
          EncryptionKeyType.fromProto(contactRequest!.encryptionKeyType);
      late final SharedSecret? writerSecret;
      try {
        writerSecret = await getEncryptionKeyCallback(cs, encryptionKeyType,
            Uint8List.fromList(contactInvitation.writerSecret));
      } on Exception catch (_) {
        throw ContactInviteInvalidKeyException(encryptionKeyType);
      }
      if (writerSecret == null) {
        return null;
      }

      final contactRequestPrivateBytes = await cs.decryptAeadWithNonce(
          Uint8List.fromList(contactRequest.private), writerSecret);

      final contactRequestPrivate =
          proto.ContactRequestPrivate.fromBuffer(contactRequestPrivateBytes);
      final contactIdentityMasterRecordKey =
          contactRequestPrivate.identityMasterRecordKey.toVeilid();

      // Fetch the account master
      final contactIdentityMaster = await openIdentityMaster(
          identityMasterRecordKey: contactIdentityMasterRecordKey);

      // Verify
      final signature = signedContactInvitation.identitySignature.toVeilid();
      await cs.verify(contactIdentityMaster.identityPublicKey,
          contactInvitationBytes, signature);

      final writer = KeyPair(
          key: contactRequestPrivate.writerKey.toVeilid(),
          secret: writerSecret);

      out = ValidContactInvitation(
          activeAccountInfo: _activeAccountInfo,
          account: _account,
          contactRequestInboxKey: contactRequestInboxKey,
          contactRequestPrivate: contactRequestPrivate,
          contactIdentityMaster: contactIdentityMaster,
          writer: writer);
    });

    return out;
  }

  Future<InvitationStatus?> checkInvitationStatus(
      {required proto.ContactInvitationRecord contactInvitationRecord}) async {
    // Open the contact request inbox
    try {
      final pool = DHTRecordPool.instance;
      final accountRecordKey = _activeAccountInfo
          .userLogin.accountRecordInfo.accountRecord.recordKey;
      final writerKey = contactInvitationRecord.writerKey.toVeilid();
      final writerSecret = contactInvitationRecord.writerSecret.toVeilid();
      final recordKey =
          contactInvitationRecord.contactRequestInbox.recordKey.toVeilid();
      final writer = TypedKeyPair(
          kind: recordKey.kind, key: writerKey, secret: writerSecret);
      final acceptReject = await (await pool.openRead(recordKey,
              crypto: await DHTRecordCryptoPrivate.fromTypedKeyPair(writer),
              parent: accountRecordKey,
              defaultSubkey: 1))
          .scope((contactRequestInbox) async {
        //
        final signedContactResponse = await contactRequestInbox.getProtobuf(
            proto.SignedContactResponse.fromBuffer,
            forceRefresh: true);
        if (signedContactResponse == null) {
          return null;
        }

        final contactResponseBytes =
            Uint8List.fromList(signedContactResponse.contactResponse);
        final contactResponse =
            proto.ContactResponse.fromBuffer(contactResponseBytes);
        final contactIdentityMasterRecordKey =
            contactResponse.identityMasterRecordKey.toVeilid();
        final cs = await pool.veilid.getCryptoSystem(recordKey.kind);

        // Fetch the remote contact's account master
        final contactIdentityMaster = await openIdentityMaster(
            identityMasterRecordKey: contactIdentityMasterRecordKey);

        // Verify
        final signature = signedContactResponse.identitySignature.toVeilid();
        await cs.verify(contactIdentityMaster.identityPublicKey,
            contactResponseBytes, signature);

        // Check for rejection
        if (!contactResponse.accept) {
          return const InvitationStatus(acceptedContact: null);
        }

        // Pull profile from remote conversation key
        final remoteConversationRecordKey =
            contactResponse.remoteConversationRecordKey.toVeilid();

        final conversation = ConversationCubit(
            activeAccountInfo: _activeAccountInfo,
            remoteIdentityPublicKey:
                contactIdentityMaster.identityPublicTypedKey(),
            remoteConversationRecordKey: remoteConversationRecordKey);
        await conversation.refresh();

        final remoteConversation =
            conversation.state.data?.value.remoteConversation;
        if (remoteConversation == null) {
          log.info('Remote conversation could not be read. Waiting...');
          return null;
        }

        // Complete the local conversation now that we have the remote profile
        final localConversationRecordKey =
            contactInvitationRecord.localConversationRecordKey.toVeilid();
        return conversation.initLocalConversation(
            existingConversationRecordKey: localConversationRecordKey,
            profile: _account.profile,
            // ignore: prefer_expression_function_bodies
            callback: (localConversation) async {
              return InvitationStatus(
                  acceptedContact: AcceptedContact(
                      remoteProfile: remoteConversation.profile,
                      remoteIdentity: contactIdentityMaster,
                      remoteConversationRecordKey: remoteConversationRecordKey,
                      localConversationRecordKey: localConversationRecordKey));
            });
      });

      if (acceptReject == null) {
        return null;
      }

      // Delete invitation and return the accepted or rejected contact
      await deleteInvitation(
          accepted: acceptReject.acceptedContact != null,
          contactInvitationRecord: contactInvitationRecord);

      return acceptReject;
    } on Exception catch (e) {
      log.error('Exception in checkAcceptRejectContact: $e', e);

      // Attempt to clean up. All this needs better lifetime management
      await deleteInvitation(
          accepted: false, contactInvitationRecord: contactInvitationRecord);

      rethrow;
    }
  }

  //
  final ActiveAccountInfo _activeAccountInfo;
  final proto.Account _account;
}
