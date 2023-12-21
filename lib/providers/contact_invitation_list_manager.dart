import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mutex/mutex.dart';

import '../entities/entities.dart';
import '../proto/proto.dart' as proto;
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'account.dart';

part 'contact_invitation_list_manager.g.dart';

//////////////////////////////////////////////////

class ContactInviteInvalidKeyException implements Exception {
  const ContactInviteInvalidKeyException(this.type) : super();
  final EncryptionKeyType type;
}

typedef GetEncryptionKeyCallback = Future<SecretKey?> Function(
    VeilidCryptoSystem cs,
    EncryptionKeyType encryptionKeyType,
    Uint8List encryptedSecret);

//////////////////////////////////////////////////
@immutable
class AcceptedContact {
  const AcceptedContact({
    required this.profile,
    required this.remoteIdentity,
    required this.remoteConversationRecordKey,
    required this.localConversationRecordKey,
  });

  final proto.Profile profile;
  final IdentityMaster remoteIdentity;
  final TypedKey remoteConversationRecordKey;
  final TypedKey localConversationRecordKey;
}

@immutable
class InvitationStatus {
  const InvitationStatus({required this.acceptedContact});
  final AcceptedContact? acceptedContact;
}

//////////////////////////////////////////////////

//////////////////////////////////////////////////
// Mutable state for per-account contact invitations
@riverpod
class ContactInvitationListManager extends _$ContactInvitationListManager {
  ContactInvitationListManager._({
    required ActiveAccountInfo activeAccountInfo,
    required DHTShortArray dhtRecord,
  })  : _activeAccountInfo = activeAccountInfo,
        _dhtRecord = dhtRecord,
        _records = IList();

  @override
  FutureOr<IList<proto.ContactInvitationRecord>> build(
      ActiveAccountInfo activeAccountInfo) async {
    // Load initial todo list from the remote repository
    ref.onDispose  xxxx call close and pass dhtrecord through... could use a context object 
    and a DHTValueChangeProvider that we watch in build that updates when dht records change
    return _open(activeAccountInfo);
  }

  static Future<ContactInvitationListManager> _open(
      ActiveAccountInfo activeAccountInfo) async {
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final dhtRecord = await DHTShortArray.openOwned(
        proto.OwnedDHTRecordPointerProto.fromProto(
            activeAccountInfo.account.contactInvitationRecords),
        parent: accountRecordKey);

    return ContactInvitationListManager._(
        activeAccountInfo: activeAccountInfo, dhtRecord: dhtRecord);
  }

  Future<void> close() async {
    state = "";
    await _dhtRecord.close();
  }

  Future<void> refresh() async {
    for (var i = 0; i < _dhtRecord.length; i++) {
      final cir = await _dhtRecord.getItem(i);
      if (cir == null) {
        throw Exception('Failed to get contact invitation record');
      }
      _records = _records.add(proto.ContactInvitationRecord.fromBuffer(cir));
    }
  }

  Future<Uint8List> createInvitation(
      {required EncryptionKeyType encryptionKeyType,
      required String encryptionKey,
      required String message,
      required Timestamp? expiration}) async {
    final pool = await DHTRecordPool.instance();
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
    final identityKey =
        _activeAccountInfo.localAccount.identityMaster.identityPublicKey;
    final identitySecret = _activeAccountInfo.userLogin.identitySecret.value;

    // Generate writer keypair to share with new contact
    final cs = await pool.veilid.bestCryptoSystem();
    final contactRequestWriter = await cs.generateKeyPair();
    final conversationWriter = _activeAccountInfo.getConversationWriter();

    // Encrypt the writer secret with the encryption key
    final encryptedSecret = await encryptSecretToBytes(
        secret: contactRequestWriter.secret,
        cryptoKind: cs.kind(),
        encryptionKey: encryptionKey,
        encryptionKeyType: encryptionKeyType);

    // Create local chat DHT record with the account record key as its parent
    // Do not set the encryption of this key yet as it will not yet be written
    // to and it will be eventually encrypted with the DH of the contact's
    // identity key
    late final Uint8List signedContactInvitationBytes;
    await (await pool.create(
            parent: accountRecordKey,
            schema: DHTSchema.smpl(oCnt: 0, members: [
              DHTSchemaMember(mKey: conversationWriter.key, mCnt: 1)
            ])))
        .deleteScope((localConversation) async {
      // dont bother reopening localConversation with writer
      // Make ContactRequestPrivate and encrypt with the writer secret
      final crpriv = proto.ContactRequestPrivate()
        ..writerKey = contactRequestWriter.key.toProto()
        ..profile = _activeAccountInfo.account.profile
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
              parent: accountRecordKey,
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
          ..identitySignature =
              (await cs.sign(identityKey, identitySecret, cinvbytes)).toProto();
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
        await (await DHTShortArray.openOwned(
                proto.OwnedDHTRecordPointerProto.fromProto(
                    _activeAccountInfo.account.contactInvitationRecords),
                parent: accountRecordKey))
            .scope((cirList) async {
          if (await cirList.tryAddItem(cinvrec.writeToBuffer()) == false) {
            throw Exception('Failed to add contact invitation record');
          }
        });
      });
    });

    return signedContactInvitationBytes;
  }

  Future<void> deleteInvitation(
      {required bool accepted,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    final pool = await DHTRecordPool.instance();
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    // Remove ContactInvitationRecord from account's list
    await (await DHTShortArray.openOwned(
            proto.OwnedDHTRecordPointerProto.fromProto(
                _activeAccountInfo.account.contactInvitationRecords),
            parent: accountRecordKey))
        .scope((cirList) async {
      for (var i = 0; i < cirList.length; i++) {
        final item = await cirList.getItemProtobuf(
            proto.ContactInvitationRecord.fromBuffer, i);
        if (item == null) {
          throw Exception('Failed to get contact invitation record');
        }
        if (item.contactRequestInbox.recordKey ==
            contactInvitationRecord.contactRequestInbox.recordKey) {
          await cirList.tryRemoveItem(i);
          break;
        }
      }
      await (await pool.openOwned(
              proto.OwnedDHTRecordPointerProto.fromProto(
                  contactInvitationRecord.contactRequestInbox),
              parent: accountRecordKey))
          .scope((contactRequestInbox) async {
        // Wipe out old invitation so it shows up as invalid
        await contactRequestInbox.tryWriteBytes(Uint8List(0));
        await contactRequestInbox.delete();
      });
      if (!accepted) {
        await (await pool.openRead(
                proto.TypedKeyProto.fromProto(
                    contactInvitationRecord.localConversationRecordKey),
                parent: accountRecordKey))
            .delete();
      }
    });
  }

  Future<ValidContactInvitation?> validateInvitation(
      {required Uint8List inviteData,
      required GetEncryptionKeyCallback getEncryptionKeyCallback}) async {
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final signedContactInvitation =
        proto.SignedContactInvitation.fromBuffer(inviteData);

    final contactInvitationBytes =
        Uint8List.fromList(signedContactInvitation.contactInvitation);
    final contactInvitation =
        proto.ContactInvitation.fromBuffer(contactInvitationBytes);

    final contactRequestInboxKey =
        proto.TypedKeyProto.fromProto(contactInvitation.contactRequestInboxKey);

    ValidContactInvitation? out;

    final pool = await DHTRecordPool.instance();
    final cs = await pool.veilid.getCryptoSystem(contactRequestInboxKey.kind);

    // See if we're chatting to ourselves, if so, don't delete it here
    final isSelf = _records.indexWhere((cir) =>
            proto.TypedKeyProto.fromProto(cir.contactRequestInbox.recordKey) ==
            contactRequestInboxKey) !=
        -1;

    await (await pool.openRead(contactRequestInboxKey,
            parent: accountRecordKey))
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
      final contactIdentityMasterRecordKey = proto.TypedKeyProto.fromProto(
          contactRequestPrivate.identityMasterRecordKey);

      // Fetch the account master
      final contactIdentityMaster = await openIdentityMaster(
          identityMasterRecordKey: contactIdentityMasterRecordKey);

      // Verify
      final signature = proto.SignatureProto.fromProto(
          signedContactInvitation.identitySignature);
      await cs.verify(contactIdentityMaster.identityPublicKey,
          contactInvitationBytes, signature);

      final writer = KeyPair(
          key: proto.CryptoKeyProto.fromProto(contactRequestPrivate.writerKey),
          secret: writerSecret);

      out = ValidContactInvitation._(
          contactInvitationManager: this,
          signedContactInvitation: signedContactInvitation,
          contactInvitation: contactInvitation,
          contactRequestInboxKey: contactRequestInboxKey,
          contactRequest: contactRequest,
          contactRequestPrivate: contactRequestPrivate,
          contactIdentityMaster: contactIdentityMaster,
          writer: writer);
    });

    return out;
  }

  Future<InvitationStatus?> checkInvitationStatus(
      {required ActiveAccountInfo activeAccountInfo,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    // Open the contact request inbox
    try {
      final pool = await DHTRecordPool.instance();
      final accountRecordKey =
          activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
      final writerKey =
          proto.CryptoKeyProto.fromProto(contactInvitationRecord.writerKey);
      final writerSecret =
          proto.CryptoKeyProto.fromProto(contactInvitationRecord.writerSecret);
      final recordKey = proto.TypedKeyProto.fromProto(
          contactInvitationRecord.contactRequestInbox.recordKey);
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
        final contactIdentityMasterRecordKey = proto.TypedKeyProto.fromProto(
            contactResponse.identityMasterRecordKey);
        final cs = await pool.veilid.getCryptoSystem(recordKey.kind);

        // Fetch the remote contact's account master
        final contactIdentityMaster = await openIdentityMaster(
            identityMasterRecordKey: contactIdentityMasterRecordKey);

        // Verify
        final signature = proto.SignatureProto.fromProto(
            signedContactResponse.identitySignature);
        await cs.verify(contactIdentityMaster.identityPublicKey,
            contactResponseBytes, signature);

        // Check for rejection
        if (!contactResponse.accept) {
          return const InvitationStatus(acceptedContact: null);
        }

        // Pull profile from remote conversation key
        final remoteConversationRecordKey = proto.TypedKeyProto.fromProto(
            contactResponse.remoteConversationRecordKey);
        final remoteConversation = await readRemoteConversation(
            activeAccountInfo: activeAccountInfo,
            remoteIdentityPublicKey:
                contactIdentityMaster.identityPublicTypedKey(),
            remoteConversationRecordKey: remoteConversationRecordKey);
        if (remoteConversation == null) {
          log.info('Remote conversation could not be read. Waiting...');
          return null;
        }
        // Complete the local conversation now that we have the remote profile
        final localConversationRecordKey = proto.TypedKeyProto.fromProto(
            contactInvitationRecord.localConversationRecordKey);
        return createConversation(
            activeAccountInfo: activeAccountInfo,
            remoteIdentityPublicKey:
                contactIdentityMaster.identityPublicTypedKey(),
            existingConversationRecordKey: localConversationRecordKey,
            // ignore: prefer_expression_function_bodies
            callback: (localConversation) async {
              return InvitationStatus(
                  acceptedContact: AcceptedContact(
                      profile: remoteConversation.profile,
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
  final DHTShortArray _dhtRecord;
  IList<proto.ContactInvitationRecord> _records;
}

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
