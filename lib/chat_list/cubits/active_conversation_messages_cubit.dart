import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import 'active_conversations_cubit.dart';

class ActiveConversationMessagesCubit extends BlocMapCubit<TypedKey,
    AsyncValue<IList<proto.Message>>, MessagesCubit> {
  ActiveConversationMessagesCubit({
    required ActiveAccountInfo activeAccountInfo,
    required Stream<ActiveConversationsBlocMapState> stream,
  }) : _activeAccountInfo = activeAccountInfo {
    //
    _subscription = stream.listen(updateMessageCubits);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }

  // Determine which conversations have been added, deleted, or changed
  // and update this cubit's state appropriately
  void updateMessageCubits(ActiveConversationsBlocMapState newInputState) {
    // Use a singlefuture here to ensure we get dont lose any updates
    // If the ActiveConversations stream gives us an update while we are
    // still processing the last update, the most recent input state will
    // be saved and processed eventually.
    singleFuture(this, () async {
      var newActiveConversationsState = newInputState;
      var done = false;
      while (!done) {
        // Build lists of changes to conversations
        final deleted = _lastActiveConversationsState.keys
            .where((k) => !newActiveConversationsState.containsKey(k));
        final added = newActiveConversationsState.keys
            .where((k) => !_lastActiveConversationsState.containsKey(k));
        final changed = _lastActiveConversationsState.where((k, v) {
          final nv = newActiveConversationsState[k];
          if (nv == null) {
            return false;
          }
          return nv != v;
        }).keys;

        // Process all deleted conversations
        for (final d in deleted) {
          await remove(d);
        }

        // Process all added and changed conversations
        for (final a in [...added, ...changed]) {
          final av = newActiveConversationsState[a]!;
          await av.when(
              data: (state) => _addConversationMessages(
                  contact: state.contact,
                  localConversation: state.localConversation,
                  remoteConversation: state.remoteConversation),
              loading: () => addState(a, const AsyncValue.loading()),
              error: (error, stackTrace) =>
                  addState(a, AsyncValue.error(error, stackTrace)));
        }

        // Keep this state for the next time
        _lastActiveConversationsState = newActiveConversationsState;

        // See if there's another state change to process
        final next = _nextActiveConversationsState;
        _nextActiveConversationsState = null;
        if (next != null) {
          newActiveConversationsState = next;
        } else {
          done = true;
        }
      }
    }, onBusy: () {
      // Keep this state until we process again
      _nextActiveConversationsState = newInputState;
    });
  }

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

  ////

  final ActiveAccountInfo _activeAccountInfo;
  ActiveConversationsBlocMapState _lastActiveConversationsState =
      ActiveConversationsBlocMapState();
  ActiveConversationsBlocMapState? _nextActiveConversationsState;
  late final StreamSubscription<ActiveConversationsBlocMapState> _subscription;
}
