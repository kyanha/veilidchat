import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../account_manager/account_manager.dart';
import '../../../chat/chat.dart';
import '../../../chat_list/chat_list.dart';
import '../../../contact_invitation/contact_invitation.dart';
import '../../../contacts/contacts.dart';
import '../../../tools/tools.dart';

class HomeAccountReadyShell extends StatefulWidget {
  const HomeAccountReadyShell({required this.child, super.key});

  @override
  HomeAccountReadyShellState createState() => HomeAccountReadyShellState();

  final Widget child;
}

class HomeAccountReadyShellState extends State<HomeAccountReadyShell>
    with TickerProviderStateMixin {
  //
  @override
  void initState() {
    super.initState();
  }

  // xxx figure out how to do this switch

  // Widget buildWithLogin(BuildContext context) {
  //   final activeUserLogin = context.watch<ActiveUserLoginCubit>().state;

  //   if (activeUserLogin == null) {
  //     // If no logged in user is active, show the loading panel
  //     return const HomeNoActive();
  //   }

  //   final accountInfo = AccountRepository.instance
  //       .getAccountInfo(accountMasterRecordKey: activeUserLogin)!;

  //   switch (accountInfo.status) {
  //     case AccountInfoStatus.noAccount:
  //       return const HomeAccountMissing();
  //     case AccountInfoStatus.accountInvalid:
  //       return const HomeAccountInvalid();
  //     case AccountInfoStatus.accountLocked:
  //       return const HomeAccountLocked();
  //     case AccountInfoStatus.accountReady:
  //       return Provider<ActiveAccountInfo>.value(
  //           value: accountInfo.activeAccountInfo!,
  //           child: BlocProvider(
  //               create: (context) => AccountRecordCubit(
  //                   record: accountInfo.activeAccountInfo!.accountRecord),
  //               child: const HomeAccountReady()));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // These must be valid already before making this widget,
    // per the ShellRoute above it
    final activeUserLogin = context.read<ActiveUserLoginCubit>().state!;
    final accountInfo = AccountRepository.instance
        .getAccountInfo(accountMasterRecordKey: activeUserLogin)!;
    final activeAccountInfo = accountInfo.activeAccountInfo!;

    return Provider<ActiveAccountInfo>.value(
        value: activeAccountInfo,
        child: BlocProvider(
            create: (context) => AccountRecordCubit(
                record: accountInfo.activeAccountInfo!.accountRecord),
            child: Builder(builder: (context) {
              final account =
                  context.watch<AccountRecordCubit>().state.data?.value;
              if (account == null) {
                return waitingPage();
              }
              return MultiBlocProvider(providers: [
                BlocProvider(
                    create: (context) => ContactInvitationListCubit(
                        activeAccountInfo: activeAccountInfo,
                        account: account)),
                BlocProvider(
                    create: (context) => ContactListCubit(
                        activeAccountInfo: activeAccountInfo,
                        account: account)),
                BlocProvider(
                    create: (context) => ChatListCubit(
                        activeAccountInfo: activeAccountInfo,
                        account: account)),
                BlocProvider(
                    create: (context) => ActiveConversationsCubit(
                        activeAccountInfo: activeAccountInfo)),
                BlocProvider(create: (context) => ActiveChatCubit(null))
              ], child: widget.child);
            })));
  }
}
