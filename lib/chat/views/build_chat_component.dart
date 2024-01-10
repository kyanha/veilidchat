import 'package:flutter/material.dart';

import '../../tools/tools.dart';

Widget buildChatComponent() {
  //   final contactList = ref.watch(fetchContactListProvider).asData?.value ??
  //       const IListConst([]);

  //   final activeChat = ref.watch(activeChatStateProvider);
  //   if (activeChat == null) {
  //     return const EmptyChatWidget();
  //   }

  //   final activeAccountInfo =
  //       ref.watch(fetchActiveAccountProvider).asData?.value;
  //   if (activeAccountInfo == null) {
  //     return const EmptyChatWidget();
  //   }

  //   final activeChatContactIdx = contactList.indexWhere(
  //     (c) =>
  //         proto.TypedKeyProto.fromProto(c.remoteConversationRecordKey) ==
  //         activeChat,
  //   );
  //   if (activeChatContactIdx == -1) {
  //     ref.read(activeChatStateProvider.notifier).state = null;
  //     return const EmptyChatWidget();
  //   }
  //   final activeChatContact = contactList[activeChatContactIdx];

  //   return ChatComponent(
  //       activeAccountInfo: activeAccountInfo,
  //       activeChat: activeChat,
  //       activeChatContact: activeChatContact);
  // }
  return Builder(builder: waitingPage);
}
