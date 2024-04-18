import 'dart:async';

import 'package:bloc_tools/bloc_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';

//////////////////////////////////////////////////

//////////////////////////////////////////////////
// Mutable state for per-account chat list
typedef ChatListCubitState = DHTShortArrayBusyState<proto.Chat>;

class ChatListCubit extends DHTShortArrayCubit<proto.Chat>
    with StateMapFollowable<ChatListCubitState, TypedKey, proto.Chat> {
  ChatListCubit({
    required ActiveAccountInfo activeAccountInfo,
    required proto.Account account,
    required this.activeChatCubit,
  })  : _activeAccountInfo = activeAccountInfo,
        super(
            open: () => _open(activeAccountInfo, account),
            decodeElement: proto.Chat.fromBuffer);

  static Future<DHTShortArray> _open(
      ActiveAccountInfo activeAccountInfo, proto.Account account) async {
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final chatListRecordKey = account.chatList.toVeilid();

    final dhtRecord = await DHTShortArray.openOwned(chatListRecordKey,
        debugName: 'ChatListCubit::_open::ChatList', parent: accountRecordKey);

    return dhtRecord;
  }

  /// Create a new chat (singleton for single contact chats)
  Future<void> getOrCreateChatSingleContact({
    required TypedKey remoteConversationRecordKey,
  }) async {
    // Add Chat to account's list
    // if this fails, don't keep retrying, user can try again later
    await operateWrite((writer) async {
      final remoteConversationRecordKeyProto =
          remoteConversationRecordKey.toProto();

      // See if we have added this chat already
      for (var i = 0; i < writer.length; i++) {
        final cbuf = await writer.getItem(i);
        if (cbuf == null) {
          throw Exception('Failed to get chat');
        }
        final c = proto.Chat.fromBuffer(cbuf);
        if (c.remoteConversationRecordKey == remoteConversationRecordKeyProto) {
          // Nothing to do here
          return;
        }
      }
      final accountRecordKey = _activeAccountInfo
          .userLogin.accountRecordInfo.accountRecord.recordKey;

      // Make a record that can store the reconciled version of the chat
      final reconciledChatRecord = await (await DHTShortArray.create(
              debugName:
                  'ChatListCubit::getOrCreateChatSingleContact::ReconciledChat',
              parent: accountRecordKey))
          .scope((r) async => r.recordPointer);

      // Create conversation type Chat
      final chat = proto.Chat()
        ..type = proto.ChatType.SINGLE_CONTACT
        ..remoteConversationRecordKey = remoteConversationRecordKeyProto
        ..reconciledChatRecord = reconciledChatRecord.toProto();

      // Add chat
      final added = await writer.tryAddItem(chat.writeToBuffer());
      if (!added) {
        throw Exception('Failed to add chat');
      }
    });
  }

  /// Delete a chat
  Future<void> deleteChat(
      {required TypedKey remoteConversationRecordKey}) async {
    final remoteConversationKey = remoteConversationRecordKey.toProto();

    // Remove Chat from account's list
    // if this fails, don't keep retrying, user can try again later
    final (deletedItem, success) =
        // Ensure followers get their changes before we return
        await syncFollowers(() => operateWrite((writer) async {
              if (activeChatCubit.state == remoteConversationRecordKey) {
                activeChatCubit.setActiveChat(null);
              }
              for (var i = 0; i < writer.length; i++) {
                final cbuf = await writer.getItem(i);
                if (cbuf == null) {
                  throw Exception('Failed to get chat');
                }
                final c = proto.Chat.fromBuffer(cbuf);
                if (c.remoteConversationRecordKey == remoteConversationKey) {
                  // Found the right chat
                  if (await writer.tryRemoveItem(i) != null) {
                    return c;
                  }
                  return null;
                }
              }
              return null;
            }));
    // Since followers are synced, we can safetly remove the reconciled
    // chat record now
    if (success && deletedItem != null) {
      try {
        await DHTRecordPool.instance.deleteRecord(
            deletedItem.reconciledChatRecord.toVeilid().recordKey);
      } on Exception catch (e) {
        log.debug('error removing reconciled chat record: $e', e);
      }
    }
  }

  /// StateMapFollowable /////////////////////////
  @override
  IMap<TypedKey, proto.Chat> getStateMap(ChatListCubitState state) {
    final stateValue = state.state.asData?.value;
    if (stateValue == null) {
      return IMap();
    }
    return IMap.fromIterable(stateValue,
        keyMapper: (e) => e.value.remoteConversationRecordKey.toVeilid(),
        valueMapper: (e) => e.value);
  }

  final ActiveChatCubit activeChatCubit;
  final ActiveAccountInfo _activeAccountInfo;
}
