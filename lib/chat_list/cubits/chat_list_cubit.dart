import 'dart:async';

import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';

//////////////////////////////////////////////////

//////////////////////////////////////////////////
// Mutable state for per-account chat list

class ChatListCubit extends DHTShortArrayCubit<proto.Chat> {
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
        parent: accountRecordKey);

    return dhtRecord;
  }

  /// Create a new chat (singleton for single contact chats)
  Future<void> getOrCreateChatSingleContact({
    required TypedKey remoteConversationRecordKey,
  }) async {
    // Add Chat to account's list
    // if this fails, don't keep retrying, user can try again later
    await operate((shortArray) async {
      final remoteConversationRecordKeyProto =
          remoteConversationRecordKey.toProto();

      // See if we have added this chat already
      for (var i = 0; i < shortArray.length; i++) {
        final cbuf = await shortArray.getItem(i);
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
      final reconciledChatRecord =
          await (await DHTShortArray.create(parent: accountRecordKey))
              .scope((r) async => r.recordPointer);

      // Create conversation type Chat
      final chat = proto.Chat()
        ..type = proto.ChatType.SINGLE_CONTACT
        ..remoteConversationRecordKey = remoteConversationRecordKeyProto
        ..reconciledChatRecord = reconciledChatRecord.toProto();

      // Add chat
      final added = await shortArray.tryAddItem(chat.writeToBuffer());
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
    final deletedItem = await operate((shortArray) async {
      if (activeChatCubit.state == remoteConversationRecordKey) {
        activeChatCubit.setActiveChat(null);
      }
      for (var i = 0; i < shortArray.length; i++) {
        final cbuf = await shortArray.getItem(i);
        if (cbuf == null) {
          throw Exception('Failed to get chat');
        }
        final c = proto.Chat.fromBuffer(cbuf);
        if (c.remoteConversationRecordKey == remoteConversationKey) {
          // Found the right chat
          if (await shortArray.tryRemoveItem(i) != null) {
            return c;
          }
          return null;
        }
      }
      return null;
    });
    if (deletedItem != null) {
      try {
        await DHTRecordPool.instance
            .delete(deletedItem.reconciledChatRecord.toVeilid().recordKey);
      } on Exception catch (e) {
        log.debug('error removing reconciled chat record: $e', e);
      }
    }
  }

  final ActiveChatCubit activeChatCubit;
  final ActiveAccountInfo _activeAccountInfo;
}
