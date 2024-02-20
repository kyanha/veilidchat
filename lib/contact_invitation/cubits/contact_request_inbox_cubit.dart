import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

class ContactRequestInboxCubit
    extends DefaultDHTRecordCubit<proto.SignedContactResponse> {
  ContactRequestInboxCubit(
      {required this.activeAccountInfo, required this.contactInvitationRecord})
      : super(
            open: () => _open(
                activeAccountInfo: activeAccountInfo,
                contactInvitationRecord: contactInvitationRecord),
            decodeState: proto.SignedContactResponse.fromBuffer);

  ContactRequestInboxCubit.value(
      {required super.record,
      required this.activeAccountInfo,
      required this.contactInvitationRecord})
      : super.value(decodeState: proto.SignedContactResponse.fromBuffer);

  static Future<DHTRecord> _open(
      {required ActiveAccountInfo activeAccountInfo,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    final pool = DHTRecordPool.instance;
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
    final writerKey = contactInvitationRecord.writerKey.toVeilid();
    final writerSecret = contactInvitationRecord.writerSecret.toVeilid();
    final recordKey =
        contactInvitationRecord.contactRequestInbox.recordKey.toVeilid();
    final writer = TypedKeyPair(
        kind: recordKey.kind, key: writerKey, secret: writerSecret);
    return pool.openRead(recordKey,
        crypto: await DHTRecordCryptoPrivate.fromTypedKeyPair(writer),
        parent: accountRecordKey,
        defaultSubkey: 1);
  }

  final ActiveAccountInfo activeAccountInfo;
  final proto.ContactInvitationRecord contactInvitationRecord;
}
  // Future<InvitationStatus?> checkInvitationStatus(
  //     {}) async {
  //   // Open the contact request inbox
  //   try {
  //     final pool = DHTRecordPool.instance;
  //     final accountRecordKey = _activeAccountInfo
  //         .userLogin.accountRecordInfo.accountRecord.recordKey;
  //     final writerKey = contactInvitationRecord.writerKey.toVeilid();
  //     final writerSecret = contactInvitationRecord.writerSecret.toVeilid();
  //     final recordKey =
  //         contactInvitationRecord.contactRequestInbox.recordKey.toVeilid();
  //     final writer = TypedKeyPair(
  //         kind: recordKey.kind, key: writerKey, secret: writerSecret);
  //     final acceptReject = await (await pool.openRead(recordKey,
  //             crypto: await DHTRecordCryptoPrivate.fromTypedKeyPair(writer),
  //             parent: accountRecordKey,
  //             defaultSubkey: 1))
  //         .scope((contactRequestInbox) async {
  //       //
  //       final signedContactResponse = await contactRequestInbox.getProtobuf(
  //           proto.SignedContactResponse.fromBuffer,
  //           forceRefresh: true);
  //       if (signedContactResponse == null) {
  //         return null;
  //       }

  //       final contactResponseBytes =
  //           Uint8List.fromList(signedContactResponse.contactResponse);
  //       final contactResponse =
  //           proto.ContactResponse.fromBuffer(contactResponseBytes);
  //       final contactIdentityMasterRecordKey =
  //           contactResponse.identityMasterRecordKey.toVeilid();
  //       final cs = await pool.veilid.getCryptoSystem(recordKey.kind);

  //       // Fetch the remote contact's account master
  //       final contactIdentityMaster = await openIdentityMaster(
  //           identityMasterRecordKey: contactIdentityMasterRecordKey);

  //       // Verify
  //       final signature = signedContactResponse.identitySignature.toVeilid();
  //       await cs.verify(contactIdentityMaster.identityPublicKey,
  //           contactResponseBytes, signature);

  //       // Check for rejection
  //       if (!contactResponse.accept) {
  //         return const InvitationStatus(acceptedContact: null);
  //       }

  //       // Pull profile from remote conversation key
  //       final remoteConversationRecordKey =
  //           contactResponse.remoteConversationRecordKey.toVeilid();

  //       final conversation = ConversationCubit(
  //           activeAccountInfo: _activeAccountInfo,
  //           remoteIdentityPublicKey:
  //               contactIdentityMaster.identityPublicTypedKey(),
  //           remoteConversationRecordKey: remoteConversationRecordKey);
  //       await conversation.refresh();

  //       final remoteConversation =
  //           conversation.state.data?.value.remoteConversation;
  //       if (remoteConversation == null) {
  //         log.info('Remote conversation could not be read. Waiting...');
  //         return null;
  //       }

  //       // Complete the local conversation now that we have the remote profile
  //       final localConversationRecordKey =
  //           contactInvitationRecord.localConversationRecordKey.toVeilid();
  //       return conversation.initLocalConversation(
  //           existingConversationRecordKey: localConversationRecordKey,
  //           profile: _account.profile,
  //           // ignore: prefer_expression_function_bodies
  //           callback: (localConversation) async {
  //             return InvitationStatus(
  //                 acceptedContact: AcceptedContact(
  //                     remoteProfile: remoteConversation.profile,
  //                     remoteIdentity: contactIdentityMaster,
  //                     remoteConversationRecordKey: remoteConversationRecordKey,
  //                     localConversationRecordKey: localConversationRecordKey));
  //           });
  //     });

  //     if (acceptReject == null) {
  //       return null;
  //     }

  //     // Delete invitation and return the accepted or rejected contact
  //     await deleteInvitation(
  //         accepted: acceptReject.acceptedContact != null,
  //         contactInvitationRecord: contactInvitationRecord);

  //     return acceptReject;
  //   } on Exception catch (e) {
  //     log.error('Exception in checkInvitationStatus: $e', e);

  //     // Attempt to clean up. All this needs better lifetime management
  //     await deleteInvitation(
  //         accepted: false, contactInvitationRecord: contactInvitationRecord);

  //     rethrow;
  //   }







