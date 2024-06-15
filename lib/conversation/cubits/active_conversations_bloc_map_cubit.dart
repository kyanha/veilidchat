import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat_list/cubits/cubits.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../conversation.dart';

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
    AsyncValue<ActiveConversationState>,
    AsyncValue<ConversationState>,
    ConversationCubit>;

typedef ActiveConversationsBlocMapState
    = BlocMapState<TypedKey, AsyncValue<ActiveConversationState>>;

// Map of localConversationRecordKey to ActiveConversationCubit
// Wraps a conversation cubit to only expose completely built conversations
// Automatically follows the state of a ChatListCubit.
// Even though 'conversations' are per-contact and not per-chat
// We currently only build the cubits for the chats that are active, not
// archived chats or contacts that are not actively in a chat.
class ActiveConversationsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<ActiveConversationState>, ActiveConversationCubit>
    with StateMapFollower<ChatListCubitState, TypedKey, proto.Chat> {
  ActiveConversationsBlocMapCubit({
    required UnlockedAccountInfo unlockedAccountInfo,
    required ContactListCubit contactListCubit,
    required AccountRecordCubit accountRecordCubit,
  })  : _activeAccountInfo = unlockedAccountInfo,
        _contactListCubit = contactListCubit,
        _accountRecordCubit = accountRecordCubit;

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  ////////////////////////////////////////////////////////////////////////////
  // Private Implementation

  // Add an active conversation to be tracked for changes
  Future<void> _addConversation({required proto.Contact contact}) async =>
      add(() {
        final remoteIdentityPublicKey = contact.identityPublicKey.toVeilid();
        final localConversationRecordKey =
            contact.localConversationRecordKey.toVeilid();
        final remoteConversationRecordKey =
            contact.remoteConversationRecordKey.toVeilid();

        // Conversation cubit the tracks the state between the local
        // and remote halves of a contact's relationship with this account
        final conversationCubit = ConversationCubit(
          activeAccountInfo: _activeAccountInfo,
          remoteIdentityPublicKey: remoteIdentityPublicKey,
          localConversationRecordKey: localConversationRecordKey,
          remoteConversationRecordKey: remoteConversationRecordKey,
        )..watchAccountChanges(
            _accountRecordCubit.stream, _accountRecordCubit.state);
        _contactListCubit.followContactProfileChanges(
            localConversationRecordKey,
            conversationCubit.stream.map((x) => x.map(
                data: (d) => d.value.remoteConversation?.profile,
                loading: (_) => null,
                error: (_) => null)),
            conversationCubit.state.asData?.value.remoteConversation?.profile);

        // Transformer that only passes through completed/active conversations
        // along with the contact that corresponds to the completed
        // conversation
        final transformedCubit = TransformerCubit<
                AsyncValue<ActiveConversationState>,
                AsyncValue<ConversationState>,
                ConversationCubit>(conversationCubit,
            transform: (avstate) => avstate.when(
                data: (data) => (data.localConversation == null ||
                        data.remoteConversation == null)
                    ? const AsyncValue.loading()
                    : AsyncValue.data(ActiveConversationState(
                        contact: contact,
                        localConversation: data.localConversation!,
                        remoteConversation: data.remoteConversation!)),
                loading: AsyncValue.loading,
                error: AsyncValue.error));

        return MapEntry(
            contact.localConversationRecordKey.toVeilid(), transformedCubit);
      });

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
        (c) => c.value.localConversationRecordKey.toVeilid() == key);
    if (contactIndex == -1) {
      await addState(key, AsyncValue.error('Contact not found'));
      return;
    }
    final contact = contactList[contactIndex];
    await _addConversation(contact: contact.value);
  }

  ////

  final UnlockedAccountInfo _activeAccountInfo;
  final ContactListCubit _contactListCubit;
  final AccountRecordCubit _accountRecordCubit;
}
