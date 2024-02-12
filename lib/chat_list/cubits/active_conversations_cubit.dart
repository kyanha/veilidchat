import 'package:async_tools/async_tools.dart';
import 'package:equatable/equatable.dart';
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
class ActiveConversationsCubit extends BlocMapCubit<TypedKey,
    AsyncValue<ActiveConversationState>, ActiveConversationCubit> {
  ActiveConversationsCubit({required ActiveAccountInfo activeAccountInfo})
      : _activeAccountInfo = activeAccountInfo;

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

  final ActiveAccountInfo _activeAccountInfo;
}
