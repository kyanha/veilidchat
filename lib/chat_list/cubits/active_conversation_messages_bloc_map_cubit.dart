import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import 'active_conversations_bloc_map_cubit.dart';

// Map of remoteConversationRecordKey to MessagesCubit
// Wraps a MessagesCubit to stream the latest messages to the state
// Automatically follows the state of a ActiveConversationsBlocMapCubit.
class ActiveConversationMessagesBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<IList<proto.Message>>, MessagesCubit>
    with
        StateFollower<ActiveConversationsBlocMapState, TypedKey,
            AsyncValue<ActiveConversationState>> {
  ActiveConversationMessagesBlocMapCubit({
    required ActiveAccountInfo activeAccountInfo,
  }) : _activeAccountInfo = activeAccountInfo;

  Future<void> _addConversationMessages(
          {required proto.Contact contact,
          required proto.Conversation localConversation,
          required proto.Conversation remoteConversation}) async =>
      add(() => MapEntry(
          contact.remoteConversationRecordKey.toVeilid(),
          MessagesCubit(
              activeAccountInfo: _activeAccountInfo,
              remoteIdentityPublicKey: contact.identityPublicKey.toVeilid(),
              localConversationRecordKey:
                  contact.localConversationRecordKey.toVeilid(),
              remoteConversationRecordKey:
                  contact.remoteConversationRecordKey.toVeilid(),
              localMessagesRecordKey: localConversation.messages.toVeilid(),
              remoteMessagesRecordKey:
                  remoteConversation.messages.toVeilid())));

  /// StateFollower /////////////////////////

  @override
  IMap<TypedKey, AsyncValue<ActiveConversationState>> getStateMap(
          ActiveConversationsBlocMapState state) =>
      state;

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(
      TypedKey key, AsyncValue<ActiveConversationState> value) async {
    await value.when(
        data: (state) => _addConversationMessages(
            contact: state.contact,
            localConversation: state.localConversation,
            remoteConversation: state.remoteConversation),
        loading: () => addState(key, const AsyncValue.loading()),
        error: (error, stackTrace) =>
            addState(key, AsyncValue.error(error, stackTrace)));
  }

  ////

  final ActiveAccountInfo _activeAccountInfo;
}
