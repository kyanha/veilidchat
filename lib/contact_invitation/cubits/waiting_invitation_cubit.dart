import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../conversation/conversation.dart';
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
  WaitingInvitationCubit(
    ContactRequestInboxCubit super.input, {
    required AccountInfo accountInfo,
    required AccountRecordCubit accountRecordCubit,
    required proto.ContactInvitationRecord contactInvitationRecord,
  }) : super(
            transform: (signedContactResponse) => _transform(
                signedContactResponse,
                accountInfo: accountInfo,
                accountRecordCubit: accountRecordCubit,
                contactInvitationRecord: contactInvitationRecord));

  static Future<AsyncValue<InvitationStatus>> _transform(
      proto.SignedContactResponse? signedContactResponse,
      {required AccountInfo accountInfo,
      required AccountRecordCubit accountRecordCubit,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    if (signedContactResponse == null) {
      return const AsyncValue.loading();
    }

    final contactResponseBytes =
        Uint8List.fromList(signedContactResponse.contactResponse);
    final contactResponse =
        proto.ContactResponse.fromBuffer(contactResponseBytes);
    final contactIdentityMasterRecordKey =
        contactResponse.superIdentityRecordKey.toVeilid();

    // Fetch the remote contact's account master
    final contactSuperIdentity = await SuperIdentity.open(
        superRecordKey: contactIdentityMasterRecordKey);

    // Verify
    final idcs = await contactSuperIdentity.currentInstance.cryptoSystem;
    final signature = signedContactResponse.identitySignature.toVeilid();
    if (!await idcs.verify(contactSuperIdentity.currentInstance.publicKey,
        contactResponseBytes, signature)) {
      // Could not verify signature of contact response
      return AsyncValue.error('Invalid signature on contact response.');
    }

    // Check for rejection
    if (!contactResponse.accept) {
      // Rejection
      return const AsyncValue.data(InvitationStatus(acceptedContact: null));
    }

    // Pull profile from remote conversation key
    final remoteConversationRecordKey =
        contactResponse.remoteConversationRecordKey.toVeilid();

    final conversation = ConversationCubit(
        accountInfo: accountInfo,
        remoteIdentityPublicKey:
            contactSuperIdentity.currentInstance.typedPublicKey,
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
        profile: accountRecordCubit.state.asData!.value.profile,
        existingConversationRecordKey: localConversationRecordKey,
        callback: (localConversation) async => AsyncValue.data(InvitationStatus(
            acceptedContact: AcceptedContact(
                remoteProfile: remoteProfile,
                remoteIdentity: contactSuperIdentity,
                remoteConversationRecordKey: remoteConversationRecordKey,
                localConversationRecordKey: localConversationRecordKey))));
  }
}
