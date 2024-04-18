import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../chat_list.dart';

class ChatSingleContactListWidget extends StatelessWidget {
  const ChatSingleContactListWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final contactListV = context.watch<ContactListCubit>().state;

    return contactListV.builder((context, contactList) {
      final contactMap = IMap.fromIterable(contactList,
          keyMapper: (c) => c.value.remoteConversationRecordKey,
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
                            builder: (l, i, c) {
                              final contact =
                                  contactMap[c.remoteConversationRecordKey];
                              if (contact == null) {
                                return const Text('...');
                              }
                              return ChatSingleContactItemWidget(
                                      contact: contact,
                                      disabled: contactListV.busy)
                                  .paddingLTRB(0, 4, 0, 0);
                            },
                            filter: (value) {
                              final lowerValue = value.toLowerCase();
                              return chatList.map((x) => x.value).where((c) {
                                final contact =
                                    contactMap[c.remoteConversationRecordKey];
                                if (contact == null) {
                                  return false;
                                }
                                return contact.editedProfile.name
                                        .toLowerCase()
                                        .contains(lowerValue) ||
                                    contact.editedProfile.pronouns
                                        .toLowerCase()
                                        .contains(lowerValue);
                              }).toList();
                            },
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
