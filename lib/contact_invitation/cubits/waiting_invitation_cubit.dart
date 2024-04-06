import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import '../models/accepted_contact.dart';
import 'contact_request_inbox_cubit.dart';

@immutable
class InvitationStatus extends Equatable {
  const InvitationStatus({required this.acceptedContact});
  final AcceptedContact? acceptedContact;

  @override
  List<Object?> get props => [acceptedContact];
}

class WaitingInvitationCubit extends AsyncTransformerCubit<InvitationStatus,
    proto.SignedContactResponse?> {
  WaitingInvitationCubit(ContactRequestInboxCubit super.input,
      {required ActiveAccountInfo activeAccountInfo,
      required proto.Account account,
      required proto.ContactInvitationRecord contactInvitationRecord})
      : super(
            transform: (signedContactResponse) => _transform(
                signedContactResponse,
                activeAccountInfo: activeAccountInfo,
                account: account,
                contactInvitationRecord: contactInvitationRecord));

  static Future<AsyncValue<InvitationStatus>> _transform(
      proto.SignedContactResponse? signedContactResponse,
      {required ActiveAccountInfo activeAccountInfo,
      required proto.Account account,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    if (signedContactResponse == null) {
      return const AsyncValue.loading();
    }
    final pool = DHTRecordPool.instance;
    final contactResponseBytes =
        Uint8List.fromList(signedContactResponse.contactResponse);
    final contactResponse =
        proto.ContactResponse.fromBuffer(contactResponseBytes);
    final contactIdentityMasterRecordKey =
        contactResponse.identityMasterRecordKey.toVeilid();
    final cs =
        await pool.veilid.getCryptoSystem(contactIdentityMasterRecordKey.kind);

    // Fetch the remote contact's account master
    final contactIdentityMaster = await openIdentityMaster(
        identityMasterRecordKey: contactIdentityMasterRecordKey);

    // Verify
    final signature = signedContactResponse.identitySignature.toVeilid();
    await cs.verify(contactIdentityMaster.identityPublicKey,
        contactResponseBytes, signature);

    // Check for rejection
    if (!contactResponse.accept) {
      // Rejection
      return const AsyncValue.data(InvitationStatus(acceptedContact: null));
    }

    // Pull profile from remote conversation key
    final remoteConversationRecordKey =
        contactResponse.remoteConversationRecordKey.toVeilid();

    final conversation = ConversationCubit(
        activeAccountInfo: activeAccountInfo,
        remoteIdentityPublicKey: contactIdentityMaster.identityPublicTypedKey(),
        remoteConversationRecordKey: remoteConversationRecordKey);

    // wait for remote conversation for up to 20 seconds
    proto.Conversation? remoteConversation;
    var retryCount = 20;
    do {
      await conversation.refresh();
      remoteConversation = conversation.state.asData?.value.remoteConversation;
      if (remoteConversation != null) {
        break;
      }
      log.info('Remote conversation could not be read. Waiting...');
      await Future<void>.delayed(const Duration(seconds: 1));
      retryCount--;
    } while (retryCount > 0);
    if (remoteConversation == null) {
      return AsyncValue.error('Invitation accept timed out.');
    }

    // Complete the local conversation now that we have the remote profile
    final remoteProfile = remoteConversation.profile;
    final localConversationRecordKey =
        contactInvitationRecord.localConversationRecordKey.toVeilid();
    return conversation.initLocalConversation(
        existingConversationRecordKey: localConversationRecordKey,
        profile: account.profile,
        // ignore: prefer_expression_function_bodies
        callback: (localConversation) async {
          return AsyncValue.data(InvitationStatus(
              acceptedContact: AcceptedContact(
                  remoteProfile: remoteProfile,
                  remoteIdentity: contactIdentityMaster,
                  remoteConversationRecordKey: remoteConversationRecordKey,
                  localConversationRecordKey: localConversationRecordKey)));
        });
  }
}
