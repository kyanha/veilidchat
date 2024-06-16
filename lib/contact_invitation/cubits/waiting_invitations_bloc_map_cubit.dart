import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

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
  WaitingInvitationsBlocMapCubit({
    required Locator locator,
  }) : _locator = locator {
    // Follow the contact invitation list cubit
    follow(locator<ContactInvitationListCubit>());
  }

  Future<void> _addWaitingInvitation(
          {required proto.ContactInvitationRecord
              contactInvitationRecord}) async =>
      add(() => MapEntry(
          contactInvitationRecord.contactRequestInbox.recordKey.toVeilid(),
          WaitingInvitationCubit(
              ContactRequestInboxCubit(
                  locator: _locator,
                  contactInvitationRecord: contactInvitationRecord),
              locator: _locator,
              contactInvitationRecord: contactInvitationRecord)));

  /// StateFollower /////////////////////////

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(TypedKey key, proto.ContactInvitationRecord value) =>
      _addWaitingInvitation(contactInvitationRecord: value);

  ////
  final Locator _locator;
}
