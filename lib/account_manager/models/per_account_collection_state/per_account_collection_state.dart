import 'package:async_tools/async_tools.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../chat/chat.dart';
import '../../../chat_list/chat_list.dart';
import '../../../contact_invitation/contact_invitation.dart';
import '../../../contacts/contacts.dart';
import '../../../conversation/conversation.dart';
import '../../../proto/proto.dart' show Account;
import '../../account_manager.dart';

part 'per_account_collection_state.freezed.dart';

@freezed
class PerAccountCollectionState with _$PerAccountCollectionState {
  const factory PerAccountCollectionState({
    required AccountInfo accountInfo,
    required AsyncValue<AccountRecordState>? avAccountRecordState,
    required AccountInfoCubit? accountInfoCubit,
    required AccountRecordCubit? accountRecordCubit,
    required ContactInvitationListCubit? contactInvitationListCubit,
    required ContactListCubit? contactListCubit,
    required WaitingInvitationsBlocMapCubit? waitingInvitationsBlocMapCubit,
    required ActiveChatCubit? activeChatCubit,
    required ChatListCubit? chatListCubit,
    required ActiveConversationsBlocMapCubit? activeConversationsBlocMapCubit,
    required ActiveSingleContactChatBlocMapCubit?
        activeSingleContactChatBlocMapCubit,
  }) = _PerAccountCollectionState;
}

extension PerAccountCollectionStateExt on PerAccountCollectionState {
  bool get isReady =>
      avAccountRecordState != null &&
      avAccountRecordState!.isData &&
      accountInfoCubit != null &&
      accountRecordCubit != null &&
      contactInvitationListCubit != null &&
      contactListCubit != null &&
      waitingInvitationsBlocMapCubit != null &&
      activeChatCubit != null &&
      chatListCubit != null &&
      activeConversationsBlocMapCubit != null &&
      activeSingleContactChatBlocMapCubit != null;

  Widget provide({required Widget child}) => MultiBlocProvider(providers: [
        BlocProvider.value(value: accountInfoCubit!),
        BlocProvider.value(value: accountRecordCubit!),
        BlocProvider.value(value: contactInvitationListCubit!),
        BlocProvider.value(value: contactListCubit!),
        BlocProvider.value(value: waitingInvitationsBlocMapCubit!),
        BlocProvider.value(value: activeChatCubit!),
        BlocProvider.value(value: chatListCubit!),
        BlocProvider.value(value: activeConversationsBlocMapCubit!),
        BlocProvider.value(value: activeSingleContactChatBlocMapCubit!),
      ], child: child);
}
