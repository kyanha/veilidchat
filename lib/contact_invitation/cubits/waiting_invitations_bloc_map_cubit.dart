import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../notifications/notifications.dart';
import '../../proto/proto.dart' as proto;
import 'cubits.dart';

typedef WaitingInvitationsBlocMapState
    = BlocMapState<TypedKey, AsyncValue<InvitationStatus>>;

// Map of contactRequestInboxRecordKey to WaitingInvitationCubit
// Wraps a contact invitation cubit to watch for accept/reject
// Automatically follows the state of a ContactInvitationListCubit.
class WaitingInvitationsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<InvitationStatus>, WaitingInvitationCubit>
    with
        StateMapFollower<DHTShortArrayBusyState<proto.ContactInvitationRecord>,
            TypedKey, proto.ContactInvitationRecord> {
  WaitingInvitationsBlocMapCubit(
      {required AccountInfo accountInfo,
      required AccountRecordCubit accountRecordCubit,
      required ContactInvitationListCubit contactInvitationListCubit,
      required ContactListCubit contactListCubit,
      required NotificationsCubit notificationsCubit})
      : _accountInfo = accountInfo,
        _accountRecordCubit = accountRecordCubit,
        _contactInvitationListCubit = contactInvitationListCubit,
        _contactListCubit = contactListCubit,
        _notificationsCubit = notificationsCubit {
    // React to invitation status changes
    _singleInvitationStatusProcessor.follow(
        stream, state, _invitationStatusListener);

    // Follow the contact invitation list cubit
    follow(contactInvitationListCubit);
  }

  @override
  Future<void> close() async {
    await _singleInvitationStatusProcessor.close();
    await super.close();
  }

  Future<void> _addWaitingInvitation(
          {required proto.ContactInvitationRecord
              contactInvitationRecord}) async =>
      add(
          contactInvitationRecord.contactRequestInbox.recordKey.toVeilid(),
          () async => WaitingInvitationCubit(
              ContactRequestInboxCubit(
                  accountInfo: _accountInfo,
                  contactInvitationRecord: contactInvitationRecord),
              accountInfo: _accountInfo,
              accountRecordCubit: _accountRecordCubit,
              contactInvitationRecord: contactInvitationRecord));

  // Process all accepted or rejected invitations
  Future<void> _invitationStatusListener(
      WaitingInvitationsBlocMapState newState) async {
    for (final entry in newState.entries) {
      final contactRequestInboxRecordKey = entry.key;
      final invStatus = entry.value.asData?.value;
      // Skip invitations that have not yet been accepted or rejected
      if (invStatus == null) {
        continue;
      }

      // Delete invitation and process the accepted or rejected contact
      final acceptedContact = invStatus.acceptedContact;
      if (acceptedContact != null) {
        await _contactInvitationListCubit.deleteInvitation(
            accepted: true,
            contactRequestInboxRecordKey: contactRequestInboxRecordKey);

        // Accept
        await _contactListCubit.createContact(
          profile: acceptedContact.remoteProfile,
          remoteSuperIdentity: acceptedContact.remoteIdentity,
          remoteConversationRecordKey:
              acceptedContact.remoteConversationRecordKey,
          localConversationRecordKey:
              acceptedContact.localConversationRecordKey,
        );

        // Notify about acceptance
        _notificationsCubit.info(
            text: translate('waiting_invitation.accepted',
                args: {'name': acceptedContact.remoteProfile.name}));
      } else {
        // Reject
        await _contactInvitationListCubit.deleteInvitation(
            accepted: false,
            contactRequestInboxRecordKey: contactRequestInboxRecordKey);

        // Notify about rejection
        _notificationsCubit.info(
            text: translate(
          'waiting_invitation.rejected',
        ));
      }
    }
  }

  /// StateFollower /////////////////////////

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(
      TypedKey key,
      proto.ContactInvitationRecord? oldValue,
      proto.ContactInvitationRecord newValue) async {
    await _addWaitingInvitation(contactInvitationRecord: newValue);
  }

  ////
  final AccountInfo _accountInfo;
  final AccountRecordCubit _accountRecordCubit;
  final ContactInvitationListCubit _contactInvitationListCubit;
  final ContactListCubit _contactListCubit;
  final NotificationsCubit _notificationsCubit;
  final _singleInvitationStatusProcessor =
      SingleStateProcessor<WaitingInvitationsBlocMapState>();
}
