import 'package:async_tools/async_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';

@immutable
class ActiveConversationState extends Equatable {
  const ActiveConversationState({
    required this.contact,
    required this.localConversation,
    required this.remoteConversation,
  });

  final proto.Contact contact;
  final proto.Conversation localConversation;
  final proto.Conversation remoteConversation;

  @override
  List<Object?> get props => [contact, localConversation, remoteConversation];
}

typedef ActiveConversationCubit = TransformerCubit<
    AsyncValue<ActiveConversationState>, AsyncValue<ConversationState>>;

typedef ActiveConversationsBlocMapState
    = BlocMapState<TypedKey, AsyncValue<ActiveConversationState>>;

// Map of remoteConversationRecordKey to ActiveConversationCubit
// Wraps a conversation cubit to only expose completely built conversations
// Automatically follows the state of a ChatListCubit.
class ActiveConversationsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<ActiveConversationState>, ActiveConversationCubit>
    with StateFollower<AsyncValue<IList<proto.Chat>>, TypedKey, proto.Chat> {
  ActiveConversationsBlocMapCubit(
      {required ActiveAccountInfo activeAccountInfo,
      required ContactListCubit contactListCubit})
      : _activeAccountInfo = activeAccountInfo,
        _contactListCubit = contactListCubit;

  // Add an active conversation to be tracked for changes
  Future<void> addConversation({required proto.Contact contact}) async =>
      add(() => MapEntry(
          contact.remoteConversationRecordKey.toVeilid(),
          TransformerCubit(
              ConversationCubit(
                activeAccountInfo: _activeAccountInfo,
                remoteIdentityPublicKey: contact.identityPublicKey.toVeilid(),
                localConversationRecordKey:
                    contact.localConversationRecordKey.toVeilid(),
                remoteConversationRecordKey:
                    contact.remoteConversationRecordKey.toVeilid(),
              ),
              // Transformer that only passes through completed conversations
              // along with the contact that corresponds to the completed
              // conversation
              transform: (avstate) => avstate.when(
                  data: (data) => (data.localConversation == null ||
                          data.remoteConversation == null)
                      ? const AsyncValue.loading()
                      : AsyncValue.data(ActiveConversationState(
                          contact: contact,
                          localConversation: data.localConversation!,
                          remoteConversation: data.remoteConversation!)),
                  loading: AsyncValue.loading,
                  error: AsyncValue.error))));

  /// StateFollower /////////////////////////

  @override
  IMap<TypedKey, proto.Chat> getStateMap(AsyncValue<IList<proto.Chat>> state) {
    final stateValue = state.data?.value;
    if (stateValue == null) {
      return IMap();
    }
    return IMap.fromIterable(stateValue,
        keyMapper: (e) => e.remoteConversationKey.toVeilid(),
        valueMapper: (e) => e);
  }

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(TypedKey key, proto.Chat value) async {
    final contactList = _contactListCubit.state.data?.value;
    if (contactList == null) {
      await addState(key, const AsyncValue.loading());
      return;
    }
    final contactIndex = contactList
        .indexWhere((c) => c.remoteConversationRecordKey.toVeilid() == key);
    if (contactIndex == -1) {
      await addState(key, AsyncValue.error('Contact not found for chat'));
      return;
    }
    final contact = contactList[contactIndex];
    await addConversation(contact: contact);
  }

  ////

  final ActiveAccountInfo _activeAccountInfo;
  final ContactListCubit _contactListCubit;
}
