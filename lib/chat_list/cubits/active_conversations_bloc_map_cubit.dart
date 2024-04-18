import 'package:async_tools/async_tools.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import 'cubits.dart';

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
// Even though 'conversations' are per-contact and not per-chat
// We currently only build the cubits for the chats that are active, not
// archived chats or contacts that are not actively in a chat.
class ActiveConversationsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<ActiveConversationState>, ActiveConversationCubit>
    with StateMapFollower<ChatListCubitState, TypedKey, proto.Chat> {
  ActiveConversationsBlocMapCubit(
      {required ActiveAccountInfo activeAccountInfo,
      required ContactListCubit contactListCubit})
      : _activeAccountInfo = activeAccountInfo,
        _contactListCubit = contactListCubit;

  // Add an active conversation to be tracked for changes
  Future<void> _addConversation({required proto.Contact contact}) async =>
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
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(TypedKey key, proto.Chat value) async {
    final contactList = _contactListCubit.state.state.asData?.value;
    if (contactList == null) {
      await addState(key, const AsyncValue.loading());
      return;
    }
    final contactIndex = contactList.indexWhere(
        (c) => c.value.remoteConversationRecordKey.toVeilid() == key);
    if (contactIndex == -1) {
      await addState(key, AsyncValue.error('Contact not found'));
      return;
    }
    final contact = contactList[contactIndex];
    await _addConversation(contact: contact.value);
  }

  ////

  final ActiveAccountInfo _activeAccountInfo;
  final ContactListCubit _contactListCubit;
}
