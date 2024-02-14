import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../account_manager/account_manager.dart';
import '../../../chat/chat.dart';
import '../../../chat_list/chat_list.dart';
import '../../../contact_invitation/contact_invitation.dart';
import '../../../contacts/contacts.dart';
import '../../../router/router.dart';
import '../../../tools/tools.dart';

class HomeAccountReadyShell extends StatefulWidget {
  const HomeAccountReadyShell({required this.child, super.key});

  @override
  HomeAccountReadyShellState createState() => HomeAccountReadyShellState();

  final Widget child;
}

class HomeAccountReadyShellState extends State<HomeAccountReadyShell> {
  //
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // These must be valid already before making this widget,
    // per the ShellRoute above it
    final activeLocalAccount = context.read<ActiveLocalAccountCubit>().state!;
    final accountInfo =
        AccountRepository.instance.getAccountInfo(activeLocalAccount);
    final activeAccountInfo = accountInfo.activeAccountInfo!;
    final routerCubit = context.read<RouterCubit>();

    return Provider<ActiveAccountInfo>.value(
        value: activeAccountInfo,
        child: BlocProvider(
            create: (context) =>
                AccountRecordCubit(record: activeAccountInfo.accountRecord),
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
                BlocProvider(
                    create: (context) =>
                        ActiveChatCubit(null, routerCubit.setHasActiveChat))
              ], child: widget.child);
            })));
  }
}
