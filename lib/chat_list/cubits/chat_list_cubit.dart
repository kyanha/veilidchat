import 'dart:async';

import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../proto/proto.dart' as proto;

//////////////////////////////////////////////////

//////////////////////////////////////////////////
// Mutable state for per-account chat list
typedef ChatListCubitState = DHTShortArrayBusyState<proto.Chat>;

class ChatListCubit extends DHTShortArrayCubit<proto.Chat>
    with StateMapFollowable<ChatListCubitState, TypedKey, proto.Chat> {
  ChatListCubit({
    required AccountInfo accountInfo,
    required OwnedDHTRecordPointer chatListRecordPointer,
    required ActiveChatCubit activeChatCubit,
  })  : _activeChatCubit = activeChatCubit,
        super(
            open: () => _open(accountInfo, chatListRecordPointer),
            decodeElement: proto.Chat.fromBuffer);

  static Future<DHTShortArray> _open(AccountInfo accountInfo,
      OwnedDHTRecordPointer chatListRecordPointer) async {
    final dhtRecord = await DHTShortArray.openOwned(chatListRecordPointer,
        debugName: 'ChatListCubit::_open::ChatList',
        parent: accountInfo.accountRecordKey);

    return dhtRecord;
  }

  Future<proto.ChatSettings> getDefaultChatSettings(
      proto.Contact contact) async {
    final pronouns = contact.profile.pronouns.isEmpty
        ? ''
        : ' [${contact.profile.pronouns}])';
    return proto.ChatSettings()
      ..title = '${contact.displayName}$pronouns'
      ..description = ''
      ..defaultExpiration = Int64.ZERO;
  }

  /// Create a new chat (singleton for single contact chats)
  Future<void> getOrCreateChatSingleContact({
    required proto.Contact contact,
  }) async {
    // Make local copy so we don't share the buffer
    final localConversationRecordKey =
        contact.localConversationRecordKey.toVeilid();
    final remoteIdentityPublicKey = contact.identityPublicKey.toVeilid();
    final remoteConversationRecordKey =
        contact.remoteConversationRecordKey.toVeilid();

    // Create 1:1 conversation type Chat
    final chatMember = proto.ChatMember()
      ..remoteIdentityPublicKey = remoteIdentityPublicKey.toProto()
      ..remoteConversationRecordKey = remoteConversationRecordKey.toProto();

    final directChat = proto.DirectChat()
      ..settings = await getDefaultChatSettings(contact)
      ..localConversationRecordKey = localConversationRecordKey.toProto()
      ..remoteMember = chatMember;

    final chat = proto.Chat()..direct = directChat;

    // Add Chat to account's list
    await operateWriteEventual((writer) async {
      // See if we have added this chat already
      for (var i = 0; i < writer.length; i++) {
        final cbuf = await writer.get(i);
        if (cbuf == null) {
          throw Exception('Failed to get chat');
        }
        final c = proto.Chat.fromBuffer(cbuf);

        switch (c.whichKind()) {
          case proto.Chat_Kind.direct:
            if (c.direct.localConversationRecordKey ==
                contact.localConversationRecordKey) {
              // Nothing to do here
              return;
            }
            break;
          case proto.Chat_Kind.group:
            if (c.group.localConversationRecordKey ==
                contact.localConversationRecordKey) {
              throw StateError('direct conversation record key should'
                  ' not be used for group chats!');
            }
            break;
          case proto.Chat_Kind.notSet:
            throw StateError('unknown chat kind');
        }
      }

      // Add chat
      await writer.add(chat.writeToBuffer());
    });
  }

  /// Delete a chat
  Future<void> deleteChat(
      {required TypedKey localConversationRecordKey}) async {
    // Remove Chat from account's list
    await operateWriteEventual((writer) async {
      if (_activeChatCubit.state == localConversationRecordKey) {
        _activeChatCubit.setActiveChat(null);
      }
      for (var i = 0; i < writer.length; i++) {
        final c = await writer.getProtobuf(proto.Chat.fromBuffer, i);
        if (c == null) {
          throw Exception('Failed to get chat');
        }

        if (c.localConversationRecordKey == localConversationRecordKey) {
          await writer.remove(i);
          return;
        }
      }
    });
  }

  /// StateMapFollowable /////////////////////////
  @override
  IMap<TypedKey, proto.Chat> getStateMap(ChatListCubitState state) {
    final stateValue = state.state.asData?.value;
    if (stateValue == null) {
      return IMap();
    }
    return IMap.fromIterable(stateValue,
        keyMapper: (e) => e.value.localConversationRecordKey,
        valueMapper: (e) => e.value);
  }

  ////////////////////////////////////////////////////////////////////////////

  final ActiveChatCubit _activeChatCubit;
}
