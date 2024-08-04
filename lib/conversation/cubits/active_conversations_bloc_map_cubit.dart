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
    required this.remoteIdentityPublicKey,
    required this.localConversationRecordKey,
    required this.remoteConversationRecordKey,
    required this.localConversation,
    required this.remoteConversation,
  });

  final TypedKey remoteIdentityPublicKey;
  final TypedKey localConversationRecordKey;
  final TypedKey remoteConversationRecordKey;
  final proto.Conversation localConversation;
  final proto.Conversation? remoteConversation;

  @override
  List<Object?> get props => [
        remoteIdentityPublicKey,
        localConversationRecordKey,
        remoteConversationRecordKey,
        localConversation,
        remoteConversation
      ];
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
// We currently only build the cubits for the chats that are active, not
// archived chats or contacts that are not actively in a chat.
//
// TODO: Polling contacts for new inactive chats is yet to be done
//
class ActiveConversationsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<ActiveConversationState>, ActiveConversationCubit>
    with StateMapFollower<ChatListCubitState, TypedKey, proto.Chat> {
  ActiveConversationsBlocMapCubit({
    required AccountInfo accountInfo,
    required AccountRecordCubit accountRecordCubit,
    required ChatListCubit chatListCubit,
    required ContactListCubit contactListCubit,
  })  : _accountInfo = accountInfo,
        _accountRecordCubit = accountRecordCubit,
        _contactListCubit = contactListCubit {
    // Follow the chat list cubit
    follow(chatListCubit);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  ////////////////////////////////////////////////////////////////////////////
  // Private Implementation

  // Add an active conversation to be tracked for changes
  Future<void> _addDirectConversation(
          {required TypedKey remoteIdentityPublicKey,
          required TypedKey localConversationRecordKey,
          required TypedKey remoteConversationRecordKey}) async =>
      add(() {
        // Conversation cubit the tracks the state between the local
        // and remote halves of a contact's relationship with this account
        final conversationCubit = ConversationCubit(
          accountInfo: _accountInfo,
          remoteIdentityPublicKey: remoteIdentityPublicKey,
          localConversationRecordKey: localConversationRecordKey,
          remoteConversationRecordKey: remoteConversationRecordKey,
        );

        // When remote conversation changes its profile,
        // update our local contact
        _contactListCubit.followContactProfileChanges(
            localConversationRecordKey,
            conversationCubit.stream.map((x) => x.map(
                data: (d) => d.value.remoteConversation?.profile,
                loading: (_) => null,
                error: (_) => null)),
            conversationCubit.state.asData?.value.remoteConversation?.profile);

        // When our local account profile changes, send it to the conversation
        conversationCubit.watchAccountChanges(
            _accountRecordCubit.stream, _accountRecordCubit.state);

        // Transformer that only passes through conversations where the local
        // portion is not loading
        // along with the contact that corresponds to the completed
        // conversation
        final transformedCubit = TransformerCubit<
                AsyncValue<ActiveConversationState>,
                AsyncValue<ConversationState>,
                ConversationCubit>(conversationCubit,
            transform: (avstate) => avstate.when(
                data: (data) => (data.localConversation == null)
                    ? const AsyncValue.loading()
                    : AsyncValue.data(ActiveConversationState(
                        localConversation: data.localConversation!,
                        remoteConversation: data.remoteConversation,
                        remoteIdentityPublicKey: remoteIdentityPublicKey,
                        localConversationRecordKey: localConversationRecordKey,
                        remoteConversationRecordKey:
                            remoteConversationRecordKey)),
                loading: AsyncValue.loading,
                error: AsyncValue.error));

        return MapEntry(localConversationRecordKey, transformedCubit);
      });

  /// StateFollower /////////////////////////

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(
      TypedKey key, proto.Chat? oldValue, proto.Chat newValue) async {
    switch (newValue.whichKind()) {
      case proto.Chat_Kind.notSet:
        throw StateError('unknown chat kind');
      case proto.Chat_Kind.direct:
        final localConversationRecordKey =
            newValue.direct.localConversationRecordKey.toVeilid();
        final remoteIdentityPublicKey =
            newValue.direct.remoteMember.remoteIdentityPublicKey.toVeilid();
        final remoteConversationRecordKey =
            newValue.direct.remoteMember.remoteConversationRecordKey.toVeilid();

        if (oldValue != null) {
          final oldLocalConversationRecordKey =
              oldValue.direct.localConversationRecordKey.toVeilid();
          final oldRemoteIdentityPublicKey =
              oldValue.direct.remoteMember.remoteIdentityPublicKey.toVeilid();
          final oldRemoteConversationRecordKey = oldValue
              .direct.remoteMember.remoteConversationRecordKey
              .toVeilid();

          if (oldLocalConversationRecordKey == localConversationRecordKey &&
              oldRemoteIdentityPublicKey == remoteIdentityPublicKey &&
              oldRemoteConversationRecordKey == remoteConversationRecordKey) {
            return;
          }
        }

        await _addDirectConversation(
            remoteIdentityPublicKey: remoteIdentityPublicKey,
            localConversationRecordKey: localConversationRecordKey,
            remoteConversationRecordKey: remoteConversationRecordKey);

        break;
      case proto.Chat_Kind.group:
        break;
    }
  }

  ////

  final AccountInfo _accountInfo;
  final AccountRecordCubit _accountRecordCubit;
  final ContactListCubit _contactListCubit;
}
