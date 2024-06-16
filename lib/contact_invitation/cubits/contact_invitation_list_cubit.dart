import 'dart:async';

import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
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

//////////////////////////////////////////////////

typedef ContactInvitiationListState
    = DHTShortArrayBusyState<proto.ContactInvitationRecord>;
//////////////////////////////////////////////////
// Mutable state for per-account contact invitations

class ContactInvitationListCubit
    extends DHTShortArrayCubit<proto.ContactInvitationRecord>
    with
        StateMapFollowable<ContactInvitiationListState, TypedKey,
            proto.ContactInvitationRecord> {
  ContactInvitationListCubit({
    required Locator locator,
    required TypedKey accountRecordKey,
    required OwnedDHTRecordPointer contactInvitationListRecordPointer,
  })  : _locator = locator,
        _accountRecordKey = accountRecordKey,
        super(
            open: () =>
                _open(accountRecordKey, contactInvitationListRecordPointer),
            decodeElement: proto.ContactInvitationRecord.fromBuffer);

  static Future<DHTShortArray> _open(TypedKey accountRecordKey,
      OwnedDHTRecordPointer contactInvitationListRecordPointer) async {
    final dhtRecord = await DHTShortArray.openOwned(
        contactInvitationListRecordPointer,
        debugName: 'ContactInvitationListCubit::_open::ContactInvitationList',
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
    final crcs = await pool.veilid.bestCryptoSystem();
    final contactRequestWriter = await crcs.generateKeyPair();

    final activeAccountInfo =
        _locator<ActiveAccountInfoCubit>().state.unlockedAccountInfo!;
    final profile = _locator<AccountRecordCubit>().state.asData!.value.profile;

    final idcs = await activeAccountInfo.identityCryptoSystem;
    final identityWriter = activeAccountInfo.identityWriter;

    // Encrypt the writer secret with the encryption key
    final encryptedSecret = await encryptionKeyType.encryptSecretToBytes(
      secret: contactRequestWriter.secret,
      cryptoKind: crcs.kind(),
      encryptionKey: encryptionKey,
    );

    // Create local conversation DHT record with the account record key as its
    // parent.
    // Do not set the encryption of this key yet as it will not yet be written
    // to and it will be eventually encrypted with the DH of the contact's
    // identity key
    late final Uint8List signedContactInvitationBytes;
    await (await pool.createRecord(
            debugName: 'ContactInvitationListCubit::createInvitation::'
                'LocalConversation',
            parent: _accountRecordKey,
            schema: DHTSchema.smpl(
                oCnt: 0,
                members: [DHTSchemaMember(mKey: identityWriter.key, mCnt: 1)])))
        .deleteScope((localConversation) async {
      // dont bother reopening localConversation with writer
      // Make ContactRequestPrivate and encrypt with the writer secret
      final crpriv = proto.ContactRequestPrivate()
        ..writerKey = contactRequestWriter.key.toProto()
        ..profile = profile
        ..superIdentityRecordKey =
            activeAccountInfo.userLogin.superIdentityRecordKey.toProto()
        ..chatRecordKey = localConversation.key.toProto()
        ..expiration = expiration?.toInt64() ?? Int64.ZERO;
      final crprivbytes = crpriv.writeToBuffer();
      final encryptedContactRequestPrivate = await crcs.encryptAeadWithNonce(
          crprivbytes, contactRequestWriter.secret);

      // Create ContactRequest and embed contactrequestprivate
      final creq = proto.ContactRequest()
        ..encryptionKeyType = encryptionKeyType.toProto()
        ..private = encryptedContactRequestPrivate;

      // Create DHT unicast inbox for ContactRequest
      // Subkey 0 is the ContactRequest from the initiator
      // Subkey 1 will contain the invitation response accept/reject eventually
      await (await pool.createRecord(
              debugName: 'ContactInvitationListCubit::createInvitation::'
                  'ContactRequestInbox',
              parent: _accountRecordKey,
              schema: DHTSchema.smpl(oCnt: 1, members: [
                DHTSchemaMember(mCnt: 1, mKey: contactRequestWriter.key)
              ]),
              crypto: const VeilidCryptoPublic()))
          .deleteScope((contactRequestInbox) async {
        // Store ContactRequest in owner subkey
        await contactRequestInbox.eventualWriteProtobuf(creq);
        // Store an empty invitation response
        await contactRequestInbox.eventualWriteBytes(Uint8List(0),
            subkey: 1,
            writer: contactRequestWriter,
            crypto: await DHTRecordPool.privateCryptoFromTypedSecret(TypedKey(
                kind: contactRequestInbox.key.kind,
                value: contactRequestWriter.secret)));

        // Create ContactInvitation and SignedContactInvitation
        final cinv = proto.ContactInvitation()
          ..contactRequestInboxKey = contactRequestInbox.key.toProto()
          ..writerSecret = encryptedSecret;
        final cinvbytes = cinv.writeToBuffer();
        final scinv = proto.SignedContactInvitation()
          ..contactInvitation = cinvbytes
          ..identitySignature =
              (await idcs.signWithKeyPair(identityWriter, cinvbytes)).toProto();
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
        await operateWrite((writer) async {
          await writer.add(cinvrec.writeToBuffer());
        });
      });
    });

    return signedContactInvitationBytes;
  }

  Future<void> deleteInvitation(
      {required bool accepted,
      required TypedKey contactRequestInboxRecordKey}) async {
    final pool = DHTRecordPool.instance;

    // Remove ContactInvitationRecord from account's list
    final deletedItem = await operateWrite((writer) async {
      for (var i = 0; i < writer.length; i++) {
        final item = await writer.getProtobuf(
            proto.ContactInvitationRecord.fromBuffer, i);
        if (item == null) {
          throw Exception('Failed to get contact invitation record');
        }
        if (item.contactRequestInbox.recordKey.toVeilid() ==
            contactRequestInboxRecordKey) {
          await writer.remove(i);
          return item;
        }
      }
      return null;
    });

    if (deletedItem != null) {
      // Delete the contact request inbox
      final contactRequestInbox = deletedItem.contactRequestInbox.toVeilid();
      await (await pool.openRecordOwned(contactRequestInbox,
              debugName: 'ContactInvitationListCubit::deleteInvitation::'
                  'ContactRequestInbox',
              parent: _accountRecordKey))
          .scope((contactRequestInbox) async {
        // Wipe out old invitation so it shows up as invalid
        await contactRequestInbox.tryWriteBytes(Uint8List(0));
      });
      try {
        await pool.deleteRecord(contactRequestInbox.recordKey);
      } on Exception catch (e) {
        log.debug('error removing contact request inbox: $e', e);
      }
      if (!accepted) {
        try {
          await pool
              .deleteRecord(deletedItem.localConversationRecordKey.toVeilid());
        } on Exception catch (e) {
          log.debug('error removing local conversation record: $e', e);
        }
      }
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

    // Compare the invitation's contact request
    // inbox with our list of extant invitations
    // If we're chatting to ourselves,
    // we are validating an invitation we have created
    final isSelf = state.state.asData!.value.indexWhere((cir) =>
            cir.value.contactRequestInbox.recordKey.toVeilid() ==
            contactRequestInboxKey) !=
        -1;

    await (await pool.openRecordRead(contactRequestInboxKey,
            debugName: 'ContactInvitationListCubit::validateInvitation::'
                'ContactRequestInbox',
            parent: _accountRecordKey))
        .maybeDeleteScope(!isSelf, (contactRequestInbox) async {
      //
      final contactRequest = await contactRequestInbox
          .getProtobuf(proto.ContactRequest.fromBuffer);

      final cs = await pool.veilid.getCryptoSystem(contactRequestInboxKey.kind);

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
      final contactSuperIdentityRecordKey =
          contactRequestPrivate.superIdentityRecordKey.toVeilid();

      // Fetch the account master
      final contactSuperIdentity = await SuperIdentity.open(
          superRecordKey: contactSuperIdentityRecordKey);

      // Verify
      final idcs = await contactSuperIdentity.currentInstance.cryptoSystem;
      final signature = signedContactInvitation.identitySignature.toVeilid();
      await idcs.verify(contactSuperIdentity.currentInstance.publicKey,
          contactInvitationBytes, signature);

      final writer = KeyPair(
          key: contactRequestPrivate.writerKey.toVeilid(),
          secret: writerSecret);

      out = ValidContactInvitation(
          locator: _locator,
          contactRequestInboxKey: contactRequestInboxKey,
          contactRequestPrivate: contactRequestPrivate,
          contactSuperIdentity: contactSuperIdentity,
          writer: writer);
    });

    return out;
  }

  /// StateMapFollowable /////////////////////////
  @override
  IMap<TypedKey, proto.ContactInvitationRecord> getStateMap(
      ContactInvitiationListState state) {
    final stateValue = state.state.asData?.value;
    if (stateValue == null) {
      return IMap();
    }
    return IMap.fromIterable(stateValue,
        keyMapper: (e) => e.value.contactRequestInbox.recordKey.toVeilid(),
        valueMapper: (e) => e.value);
  }

  //
  final Locator _locator;
  final TypedKey _accountRecordKey;
}
