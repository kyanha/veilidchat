import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import 'cubits.dart';

typedef WaitingInvitationsBlocMapState
    = BlocMapState<TypedKey, AsyncValue<InvitationStatus>>;

// Map of contactInvitationListRecordKey to WaitingInvitationCubit
// Wraps a contact invitation cubit to watch for accept/reject
// Automatically follows the state of a ContactInvitiationListCubit.
class WaitingInvitationsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<InvitationStatus>, WaitingInvitationCubit>
    with
        StateFollower<AsyncValue<IList<proto.ContactInvitationRecord>>,
            TypedKey, proto.ContactInvitationRecord> {
  WaitingInvitationsBlocMapCubit(
      {required this.activeAccountInfo, required this.account});
  Future<void> addWaitingInvitation(
          {required proto.ContactInvitationRecord
              contactInvitationRecord}) async =>
      add(() => MapEntry(
          contactInvitationRecord.contactRequestInbox.recordKey.toVeilid(),
          WaitingInvitationCubit(
              ContactRequestInboxCubit(
                  activeAccountInfo: activeAccountInfo,
                  contactInvitationRecord: contactInvitationRecord),
              activeAccountInfo: activeAccountInfo,
              account: account,
              contactInvitationRecord: contactInvitationRecord)));

  final ActiveAccountInfo activeAccountInfo;
  final proto.Account account;

  /// StateFollower /////////////////////////
  @override
  IMap<TypedKey, proto.ContactInvitationRecord> getStateMap(
      AsyncValue<IList<proto.ContactInvitationRecord>> avstate) {
    final state = avstate.data?.value;
    if (state == null) {
      return IMap();
    }
    return IMap.fromIterable(state,
        keyMapper: (e) => e.contactRequestInbox.recordKey.toVeilid(),
        valueMapper: (e) => e);
  }

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(TypedKey key, proto.ContactInvitationRecord value) =>
      addWaitingInvitation(contactInvitationRecord: value);
}
