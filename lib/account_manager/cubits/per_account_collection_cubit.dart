import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../chat/chat.dart';
import '../../chat_list/chat_list.dart';
import '../../contact_invitation/contact_invitation.dart';
import '../../contacts/contacts.dart';
import '../../conversation/conversation.dart';
import '../../proto/proto.dart' as proto;
import '../account_manager.dart';

class PerAccountCollectionCubit extends Cubit<PerAccountCollectionState> {
  PerAccountCollectionCubit({
    required Locator locator,
    required this.accountInfoCubit,
  })  : _locator = locator,
        super(_initialState(accountInfoCubit)) {
    // Async Init
    _initWait.add(_init);
  }

  @override
  Future<void> close() async {
    await _processor.close();
    await accountInfoCubit.close();
    await _accountRecordSubscription?.cancel();
    await accountRecordCubit?.close();

    await activeSingleContactChatBlocMapCubitUpdater.close();
    await activeConversationsBlocMapCubitUpdater.close();
    await activeChatCubitUpdater.close();
    await waitingInvitationsBlocMapCubitUpdater.close();
    await chatListCubitUpdater.close();
    await contactListCubitUpdater.close();
    await contactInvitationListCubitUpdater.close();

    await super.close();
  }

  Future<void> _init() async {
    await _initWait();

    // subscribe to accountInfo changes
    _processor.follow(accountInfoCubit.stream, accountInfoCubit.state,
        _followAccountInfoState);
  }

  static PerAccountCollectionState _initialState(
          AccountInfoCubit accountInfoCubit) =>
      PerAccountCollectionState(
          accountInfo: accountInfoCubit.state,
          avAccountRecordState: const AsyncValue.loading(),
          contactInvitationListCubit: null);

  Future<void> _followAccountInfoState(AccountInfo accountInfo) async {
    var nextState = state.copyWith(accountInfo: accountInfo);

    if (accountInfo.userLogin == null) {
      /////////////// Not logged in /////////////////

      // Unsubscribe AccountRecordCubit
      await _accountRecordSubscription?.cancel();
      _accountRecordSubscription = null;

      // Update state
      nextState =
          _updateAccountRecordState(nextState, const AsyncValue.loading());
      emit(nextState);

      // Close AccountRecordCubit
      await accountRecordCubit?.close();
      accountRecordCubit = null;
    } else {
      ///////////////// Logged in ///////////////////

      // AccountRecordCubit
      accountRecordCubit ??= AccountRecordCubit(
          localAccount: accountInfo.localAccount,
          userLogin: accountInfo.userLogin!);

      // Update State
      nextState =
          _updateAccountRecordState(nextState, accountRecordCubit!.state);
      emit(nextState);

      // Subscribe AccountRecordCubit
      _accountRecordSubscription ??=
          accountRecordCubit!.stream.listen((avAccountRecordState) {
        emit(_updateAccountRecordState(state, avAccountRecordState));
      });
    }
  }

  PerAccountCollectionState _updateAccountRecordState(
      PerAccountCollectionState prevState,
      AsyncValue<AccountRecordState> avAccountRecordState) {
    // Get next state
    final nextState =
        state.copyWith(avAccountRecordState: accountRecordCubit!.state);

    // Get bloc parameters
    final accountInfo = nextState.accountInfo;

    // ContactInvitationListCubit
    final contactInvitationListRecordPointer = nextState
        .avAccountRecordState.asData?.value.contactInvitationRecords
        .toVeilid();

    final contactInvitationListCubit = contactInvitationListCubitUpdater.update(
        contactInvitationListRecordPointer == null
            ? null
            : (accountInfo, contactInvitationListRecordPointer));

    // ContactListCubit
    final contactListRecordPointer =
        nextState.avAccountRecordState.asData?.value.contactList.toVeilid();

    final contactListCubit = contactListCubitUpdater.update(
        contactListRecordPointer == null
            ? null
            : (accountInfo, contactListRecordPointer));

    // WaitingInvitationsBlocMapCubit
    waitingInvitationsBlocMapCubitUpdater.update(
        contactInvitationListCubit == null
            ? null
            : (accountInfo, accountRecordCubit!, contactInvitationListCubit));

    // ActiveChatCubit
    final activeChatCubit = activeChatCubitUpdater
        .update(nextState.avAccountRecordState.isData ? true : null);

    // ChatListCubit
    final chatListRecordPointer =
        nextState.avAccountRecordState.asData?.value.chatList.toVeilid();

    final chatListCubit = chatListCubitUpdater.update(
        chatListRecordPointer == null || activeChatCubit == null
            ? null
            : (accountInfo, chatListRecordPointer, activeChatCubit));

    // ActiveConversationsBlocMapCubit
    final activeConversationsBlocMapCubit =
        activeConversationsBlocMapCubitUpdater.update(
            accountRecordCubit == null ||
                    chatListCubit == null ||
                    contactListCubit == null
                ? null
                : (
                    accountInfo,
                    accountRecordCubit!,
                    chatListCubit,
                    contactListCubit
                  ));

    // ActiveSingleContactChatBlocMapCubit
    activeSingleContactChatBlocMapCubitUpdater.update(
        activeConversationsBlocMapCubit == null ||
                chatListCubit == null ||
                contactListCubit == null
            ? null
            : (
                accountInfo,
                activeConversationsBlocMapCubit,
                chatListCubit,
                contactListCubit
              ));

    return nextState;
  }

  T collectionLocator<T>() {
    if (T is AccountInfoCubit) {
      return accountInfoCubit as T;
    }
    if (T is AccountRecordCubit) {
      return accountRecordCubit! as T;
    }
    if (T is ContactInvitationListCubit) {
      return contactInvitationListCubitUpdater.bloc! as T;
    }
    if (T is ContactListCubit) {
      return contactListCubitUpdater.bloc! as T;
    }
    if (T is WaitingInvitationsBlocMapCubit) {
      return waitingInvitationsBlocMapCubitUpdater.bloc! as T;
    }
    if (T is ActiveChatCubit) {
      return activeChatCubitUpdater.bloc! as T;
    }
    if (T is ChatListCubit) {
      return chatListCubitUpdater.bloc! as T;
    }
    if (T is ActiveConversationsBlocMapCubit) {
      return activeConversationsBlocMapCubitUpdater.bloc! as T;
    }
    if (T is ActiveSingleContactChatBlocMapCubit) {
      return activeSingleContactChatBlocMapCubitUpdater.bloc! as T;
    }
    return _locator<T>();
  }

  final Locator _locator;
  final _processor = SingleStateProcessor<AccountInfo>();
  final _initWait = WaitSet<void>();

  // Per-account cubits regardless of login state
  final AccountInfoCubit accountInfoCubit;

  // Per logged-in account cubits
  AccountRecordCubit? accountRecordCubit;
  StreamSubscription<AsyncValue<AccountRecordState>>?
      _accountRecordSubscription;
  final contactInvitationListCubitUpdater = BlocUpdater<
          ContactInvitationListCubit, (AccountInfo, OwnedDHTRecordPointer)>(
      create: (params) => ContactInvitationListCubit(
            accountInfo: params.$1,
            contactInvitationListRecordPointer: params.$2,
          ));
  final contactListCubitUpdater =
      BlocUpdater<ContactListCubit, (AccountInfo, OwnedDHTRecordPointer)>(
          create: (params) => ContactListCubit(
                accountInfo: params.$1,
                contactListRecordPointer: params.$2,
              ));
  final waitingInvitationsBlocMapCubitUpdater = BlocUpdater<
          WaitingInvitationsBlocMapCubit,
          (AccountInfo, AccountRecordCubit, ContactInvitationListCubit)>(
      create: (params) => WaitingInvitationsBlocMapCubit(
          accountInfo: params.$1,
          accountRecordCubit: params.$2,
          contactInvitationListCubit: params.$3));
  final activeChatCubitUpdater =
      BlocUpdater<ActiveChatCubit, bool>(create: (_) => ActiveChatCubit(null));
  final chatListCubitUpdater = BlocUpdater<ChatListCubit,
          (AccountInfo, OwnedDHTRecordPointer, ActiveChatCubit)>(
      create: (params) => ChatListCubit(
          accountInfo: params.$1,
          chatListRecordPointer: params.$2,
          activeChatCubit: params.$3));
  final activeConversationsBlocMapCubitUpdater = BlocUpdater<
          ActiveConversationsBlocMapCubit,
          (AccountInfo, AccountRecordCubit, ChatListCubit, ContactListCubit)>(
      create: (params) => ActiveConversationsBlocMapCubit(
          accountInfo: params.$1,
          accountRecordCubit: params.$2,
          chatListCubit: params.$3,
          contactListCubit: params.$4));
  final activeSingleContactChatBlocMapCubitUpdater = BlocUpdater<
          ActiveSingleContactChatBlocMapCubit,
          (
            AccountInfo,
            ActiveConversationsBlocMapCubit,
            ChatListCubit,
            ContactListCubit
          )>(
      create: (params) => ActiveSingleContactChatBlocMapCubit(
            accountInfo: params.$1,
            activeConversationsBlocMapCubit: params.$2,
            chatListCubit: params.$3,
            contactListCubit: params.$4,
          ));
}
