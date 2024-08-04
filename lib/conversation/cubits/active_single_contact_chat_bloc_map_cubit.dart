import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../proto/proto.dart' as proto;
import '../conversation.dart';
import 'active_conversations_bloc_map_cubit.dart';

@immutable
class _SingleContactChatState extends Equatable {
  const _SingleContactChatState(
      {required this.remoteIdentityPublicKey,
      required this.localConversationRecordKey,
      required this.remoteConversationRecordKey,
      required this.localMessagesRecordKey,
      required this.remoteMessagesRecordKey});

  final TypedKey remoteIdentityPublicKey;
  final TypedKey localConversationRecordKey;
  final TypedKey remoteConversationRecordKey;
  final TypedKey localMessagesRecordKey;
  final TypedKey? remoteMessagesRecordKey;

  @override
  List<Object?> get props => [
        remoteIdentityPublicKey,
        localConversationRecordKey,
        remoteConversationRecordKey,
        localMessagesRecordKey,
        remoteMessagesRecordKey
      ];
}

// Map of localConversationRecordKey to SingleContactMessagesCubit
// Wraps a SingleContactMessagesCubit to stream the latest messages to the state
// Automatically follows the state of a ActiveConversationsBlocMapCubit.
class ActiveSingleContactChatBlocMapCubit extends BlocMapCubit<TypedKey,
        SingleContactMessagesState, SingleContactMessagesCubit>
    with
        StateMapFollower<ActiveConversationsBlocMapState, TypedKey,
            AsyncValue<ActiveConversationState>> {
  ActiveSingleContactChatBlocMapCubit({
    required AccountInfo accountInfo,
    required ActiveConversationsBlocMapCubit activeConversationsBlocMapCubit,
  }) : _accountInfo = accountInfo {
    // Follow the active conversations bloc map cubit
    follow(activeConversationsBlocMapCubit);
  }

  Future<void> _addConversationMessages(_SingleContactChatState state) async {
    // xxx could use atomic update() function

    final cubit = await tryOperateAsync<SingleContactMessagesCubit>(
        state.localConversationRecordKey, closure: (cubit) async {
      await cubit.updateRemoteMessagesRecordKey(state.remoteMessagesRecordKey);
      return cubit;
    });
    if (cubit == null) {
      await add(() => MapEntry(
          state.localConversationRecordKey,
          SingleContactMessagesCubit(
            accountInfo: _accountInfo,
            remoteIdentityPublicKey: state.remoteIdentityPublicKey,
            localConversationRecordKey: state.localConversationRecordKey,
            remoteConversationRecordKey: state.remoteConversationRecordKey,
            localMessagesRecordKey: state.localMessagesRecordKey,
            remoteMessagesRecordKey: state.remoteMessagesRecordKey,
          )));
    }
  }

  _SingleContactChatState? _mapStateValue(
      AsyncValue<ActiveConversationState> avInputState) {
    final inputState = avInputState.asData?.value;
    if (inputState == null) {
      return null;
    }
    return _SingleContactChatState(
        remoteIdentityPublicKey: inputState.remoteIdentityPublicKey,
        localConversationRecordKey: inputState.localConversationRecordKey,
        remoteConversationRecordKey: inputState.remoteConversationRecordKey,
        localMessagesRecordKey:
            inputState.localConversation.messages.toVeilid(),
        remoteMessagesRecordKey:
            inputState.remoteConversation?.messages.toVeilid());
  }

  /// StateFollower /////////////////////////

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(
      TypedKey key,
      AsyncValue<ActiveConversationState>? oldValue,
      AsyncValue<ActiveConversationState> newValue) async {
    final newState = _mapStateValue(newValue);
    if (oldValue != null) {
      final oldState = _mapStateValue(oldValue);
      if (oldState == newState) {
        return;
      }
    }
    if (newState != null) {
      await _addConversationMessages(newState);
    } else if (newValue.isLoading) {
      await addState(key, const AsyncValue.loading());
    } else {
      final (error, stackTrace) =
          (newValue.asError!.error, newValue.asError!.stackTrace);
      addError(error, stackTrace);
      await addState(key, AsyncValue.error(error, stackTrace));
    }
  }

  ////
  final AccountInfo _accountInfo;
}
