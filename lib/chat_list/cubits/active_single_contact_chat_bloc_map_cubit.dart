import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import 'active_conversations_bloc_map_cubit.dart';
import 'chat_list_cubit.dart';

// Map of remoteConversationRecordKey to MessagesCubit
// Wraps a MessagesCubit to stream the latest messages to the state
// Automatically follows the state of a ActiveConversationsBlocMapCubit.
class ActiveSingleContactChatBlocMapCubit extends BlocMapCubit<TypedKey,
        SingleContactMessagesState, SingleContactMessagesCubit>
    with
        StateMapFollower<ActiveConversationsBlocMapState, TypedKey,
            AsyncValue<ActiveConversationState>> {
  ActiveSingleContactChatBlocMapCubit(
      {required ActiveAccountInfo activeAccountInfo,
      required ContactListCubit contactListCubit,
      required ChatListCubit chatListCubit})
      : _activeAccountInfo = activeAccountInfo,
        _contactListCubit = contactListCubit,
        _chatListCubit = chatListCubit;

  Future<void> _addConversationMessages(
          {required proto.Contact contact,
          required proto.Chat chat,
          required proto.Conversation localConversation,
          required proto.Conversation remoteConversation}) async =>
      add(() => MapEntry(
          contact.remoteConversationRecordKey.toVeilid(),
          SingleContactMessagesCubit(
            activeAccountInfo: _activeAccountInfo,
            remoteIdentityPublicKey: contact.identityPublicKey.toVeilid(),
            localConversationRecordKey:
                contact.localConversationRecordKey.toVeilid(),
            remoteConversationRecordKey:
                contact.remoteConversationRecordKey.toVeilid(),
            localMessagesRecordKey: localConversation.messages.toVeilid(),
            remoteMessagesRecordKey: remoteConversation.messages.toVeilid(),
            reconciledChatRecord: chat.reconciledChatRecord.toVeilid(),
          )));

  /// StateFollower /////////////////////////

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(
      TypedKey key, AsyncValue<ActiveConversationState> value) async {
    // Get the contact object for this single contact chat
    final contactList = _contactListCubit.state.state.asData?.value;
    if (contactList == null) {
      await addState(key, const AsyncValue.loading());
      return;
    }
    final contactIndex = contactList.indexWhere(
        (c) => c.value.remoteConversationRecordKey.toVeilid() == key);
    if (contactIndex == -1) {
      await addState(
          key, AsyncValue.error('Contact not found for conversation'));
      return;
    }
    final contact = contactList[contactIndex].value;

    // Get the chat object for this single contact chat
    final chatList = _chatListCubit.state.state.asData?.value;
    if (chatList == null) {
      await addState(key, const AsyncValue.loading());
      return;
    }
    final chatIndex = chatList.indexWhere(
        (c) => c.value.remoteConversationRecordKey.toVeilid() == key);
    if (contactIndex == -1) {
      await addState(key, AsyncValue.error('Chat not found for conversation'));
      return;
    }
    final chat = chatList[chatIndex].value;

    await value.when(
        data: (state) => _addConversationMessages(
            contact: contact,
            chat: chat,
            localConversation: state.localConversation,
            remoteConversation: state.remoteConversation),
        loading: () => addState(key, const AsyncValue.loading()),
        error: (error, stackTrace) =>
            addState(key, AsyncValue.error(error, stackTrace)));
  }

  ////

  final ActiveAccountInfo _activeAccountInfo;
  final ContactListCubit _contactListCubit;
  final ChatListCubit _chatListCubit;
}
