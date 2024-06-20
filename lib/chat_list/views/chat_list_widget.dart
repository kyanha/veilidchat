import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../proto/proto.dart';
import '../../theme/theme.dart';
import '../chat_list.dart';

class ChatListWidget extends StatelessWidget {
  const ChatListWidget({super.key});

  Widget _itemBuilderDirect(proto.DirectChat direct,
      IMap<proto.TypedKey, proto.Contact> contactMap, bool busy) {
    final contact = contactMap[direct.localConversationRecordKey];
    if (contact == null) {
      return const Text('...');
    }
    return ChatSingleContactItemWidget(contact: contact, disabled: busy)
        .paddingLTRB(0, 4, 0, 0);
  }

  List<proto.Chat> _itemFilter(IMap<proto.TypedKey, proto.Contact> contactMap,
      IList<DHTShortArrayElementState<Chat>> chatList, String filter) {
    final lowerValue = filter.toLowerCase();
    return chatList.map((x) => x.value).where((c) {
      switch (c.whichKind()) {
        case proto.Chat_Kind.direct:
          final contact = contactMap[c.direct.localConversationRecordKey];
          if (contact == null) {
            return false;
          }
          return contact.nickname.toLowerCase().contains(lowerValue) ||
              contact.profile.name.toLowerCase().contains(lowerValue) ||
              contact.profile.pronouns.toLowerCase().contains(lowerValue);
        case proto.Chat_Kind.group:
          // xxx: how to filter group chats
          return true;
        case proto.Chat_Kind.notSet:
          throw StateError('unknown chat kind');
      }
    }).toList();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final contactListV = context.watch<ContactListCubit>().state;

    return contactListV.builder((context, contactList) {
      final contactMap = IMap.fromIterable(contactList,
          keyMapper: (c) => c.value.localConversationRecordKey,
          valueMapper: (c) => c.value);

      final chatListV = context.watch<ChatListCubit>().state;
      return chatListV
          .builder((context, chatList) => SizedBox.expand(
              child: styledTitleContainer(
                  context: context,
                  title: translate('chat_list.chats'),
                  child: SizedBox.expand(
                    child: (chatList.isEmpty)
                        ? const EmptyChatListWidget()
                        : SearchableList<proto.Chat>(
                            initialList: chatList.map((x) => x.value).toList(),
                            itemBuilder: (c) {
                              switch (c.whichKind()) {
                                case proto.Chat_Kind.direct:
                                  return _itemBuilderDirect(
                                      c.direct,
                                      contactMap,
                                      contactListV.busy || chatListV.busy);
                                case proto.Chat_Kind.group:
                                  return const Text(
                                      'group chats not yet supported!');
                                case proto.Chat_Kind.notSet:
                                  throw StateError('unknown chat kind');
                              }
                            },
                            filter: (value) =>
                                _itemFilter(contactMap, chatList, value),
                            spaceBetweenSearchAndList: 4,
                            inputDecoration: InputDecoration(
                              labelText: translate('chat_list.search'),
                            ),
                          ),
                  ).paddingAll(8))))
          .paddingLTRB(8, 0, 8, 8);
    });
  }
}
