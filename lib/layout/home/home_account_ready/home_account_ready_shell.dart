import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
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
                    create: (context) => ActiveConversationsBlocMapCubit(
                        activeAccountInfo: activeAccountInfo,
                        contactListCubit: context.read<ContactListCubit>())
                      ..follow(
                          initialInputState: const AsyncValue.loading(),
                          stream: context.read<ChatListCubit>().stream)),
                BlocProvider(
                    create: (context) => ActiveConversationMessagesBlocMapCubit(
                          activeAccountInfo: activeAccountInfo,
                        )..follow(
                            initialInputState: IMap(),
                            stream: context
                                .read<ActiveConversationsBlocMapCubit>()
                                .stream)),
                BlocProvider(
                    create: (context) => ActiveChatCubit(null)
                      ..withStateListen((event) {
                        routerCubit.setHasActiveChat(event != null);
                      })),
                BlocProvider(
                    create: (context) => WaitingInvitationsBlocMapCubit(
                        activeAccountInfo: activeAccountInfo, account: account)
                      ..follow(
                          initialInputState: const AsyncValue.loading(),
                          stream: context
                              .read<ContactInvitationListCubit>()
                              .stream))
              ], child: widget.child);
            })));
  }
}
