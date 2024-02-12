import 'dart:async';

import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

//////////////////////////////////////////////////

//////////////////////////////////////////////////
// Mutable state for per-account chat list

class ChatListCubit extends DHTShortArrayCubit<proto.Chat> {
  ChatListCubit({
    required ActiveAccountInfo activeAccountInfo,
    required proto.Account account,
  }) : super(
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
    // Create conversation type Chat
    final chat = proto.Chat()
      ..type = proto.ChatType.SINGLE_CONTACT
      ..remoteConversationKey = remoteConversationRecordKey.toProto();

    // Add Chat to account's list
    // if this fails, don't keep retrying, user can try again later
    if (await shortArray.tryAddItem(chat.writeToBuffer()) == false) {
      throw Exception('Failed to add chat');
    }
  }

  /// Delete a chat
  Future<void> deleteChat(
      {required TypedKey remoteConversationRecordKey}) async {
    // Create conversation type Chat
    final remoteConversationKey = remoteConversationRecordKey.toProto();

    // Remove Chat from account's list
    // if this fails, don't keep retrying, user can try again later

    for (var i = 0; i < shortArray.length; i++) {
      final cbuf = await shortArray.getItem(i);
      if (cbuf == null) {
        throw Exception('Failed to get chat');
      }
      final c = proto.Chat.fromBuffer(cbuf);
      if (c.remoteConversationKey == remoteConversationKey) {
        await shortArray.tryRemoveItem(i);
        return;
      }
    }
  }
}
