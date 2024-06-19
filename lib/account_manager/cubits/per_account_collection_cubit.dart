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
    await _initWait();

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
    // subscribe to accountInfo changes
    _processor.follow(accountInfoCubit.stream, accountInfoCubit.state,
        _followAccountInfoState);
  }

  static PerAccountCollectionState _initialState(
          AccountInfoCubit accountInfoCubit) =>
      PerAccountCollectionState(
          accountInfo: accountInfoCubit.state,
          avAccountRecordState: const AsyncValue.loading(),
          contactInvitationListCubit: null,
          accountInfoCubit: null,
          accountRecordCubit: null,
          contactListCubit: null,
          waitingInvitationsBlocMapCubit: null,
          activeChatCubit: null,
          chatListCubit: null,
          activeConversationsBlocMapCubit: null,
          activeSingleContactChatBlocMapCubit: null);

  Future<void> _followAccountInfoState(AccountInfo accountInfo) async {
    // Get the next state
    var nextState = state.copyWith(accountInfo: accountInfo);

    //  Update AccountRecordCubit
    if (accountInfo.userLogin == null) {
      /////////////// Not logged in /////////////////

      // Unsubscribe AccountRecordCubit
      await _accountRecordSubscription?.cancel();
      _accountRecordSubscription = null;

      // Update state to 'loading'
      nextState = _updateAccountRecordState(nextState, null);
      emit(nextState);

      // Close AccountRecordCubit
      await accountRecordCubit?.close();
      accountRecordCubit = null;
    } else {
      ///////////////// Logged in ///////////////////

      // Create AccountRecordCubit
      accountRecordCubit ??= AccountRecordCubit(
          localAccount: accountInfo.localAccount,
          userLogin: accountInfo.userLogin!);

      // Update state to value
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
      AsyncValue<AccountRecordState>? avAccountRecordState) {
    // Get next state
    final nextState =
        prevState.copyWith(avAccountRecordState: avAccountRecordState);

    // Get bloc parameters
    final accountInfo = nextState.accountInfo;

    // ContactInvitationListCubit
    final contactInvitationListRecordPointer = nextState
        .avAccountRecordState?.asData?.value.contactInvitationRecords
        .toVeilid();

    final contactInvitationListCubit = contactInvitationListCubitUpdater.update(
        accountInfo.userLogin == null ||
                contactInvitationListRecordPointer == null
            ? null
            : (accountInfo, contactInvitationListRecordPointer));

    // ContactListCubit
    final contactListRecordPointer =
        nextState.avAccountRecordState?.asData?.value.contactList.toVeilid();

    final contactListCubit = contactListCubitUpdater.update(
        accountInfo.userLogin == null || contactListRecordPointer == null
            ? null
            : (accountInfo, contactListRecordPointer));

    // WaitingInvitationsBlocMapCubit
    final waitingInvitationsBlocMapCubit =
        waitingInvitationsBlocMapCubitUpdater.update(
            accountInfo.userLogin == null || contactInvitationListCubit == null
                ? null
                : (
                    accountInfo,
                    accountRecordCubit!,
                    contactInvitationListCubit
                  ));

    // ActiveChatCubit
    final activeChatCubit = activeChatCubitUpdater
        .update((accountInfo.userLogin == null) ? null : true);

    // ChatListCubit
    final chatListRecordPointer =
        nextState.avAccountRecordState?.asData?.value.chatList.toVeilid();

    final chatListCubit = chatListCubitUpdater.update(
        accountInfo.userLogin == null ||
                chatListRecordPointer == null ||
                activeChatCubit == null
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
    final activeSingleContactChatBlocMapCubit =
        activeSingleContactChatBlocMapCubitUpdater.update(
            accountInfo.userLogin == null ||
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

    // Update available blocs in our state
    return nextState.copyWith(
        contactInvitationListCubit: contactInvitationListCubit,
        accountInfoCubit: accountInfoCubit,
        accountRecordCubit: accountRecordCubit,
        contactListCubit: contactListCubit,
        waitingInvitationsBlocMapCubit: waitingInvitationsBlocMapCubit,
        activeChatCubit: activeChatCubit,
        chatListCubit: chatListCubit,
        activeConversationsBlocMapCubit: activeConversationsBlocMapCubit,
        activeSingleContactChatBlocMapCubit:
            activeSingleContactChatBlocMapCubit);
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
