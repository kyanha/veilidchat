import 'package:async_tools/async_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../account_manager/account_manager.dart';
import '../../../chat/chat.dart';
import '../../../chat_list/chat_list.dart';
import '../../../contact_invitation/contact_invitation.dart';
import '../../../contacts/contacts.dart';
import '../../../router/router.dart';
import '../../../theme/theme.dart';

class HomeAccountReadyShell extends StatefulWidget {
  factory HomeAccountReadyShell(
      {required BuildContext context, required Widget child, Key? key}) {
    // These must exist in order for the account to
    // be considered 'ready' for this widget subtree
    final activeLocalAccount = context.read<ActiveLocalAccountCubit>().state!;
    final activeAccountInfo = context.read<ActiveAccountInfo>();
    final routerCubit = context.read<RouterCubit>();

    return HomeAccountReadyShell._(
        activeLocalAccount: activeLocalAccount,
        activeAccountInfo: activeAccountInfo,
        routerCubit: routerCubit,
        key: key,
        child: child);
  }
  const HomeAccountReadyShell._(
      {required this.activeLocalAccount,
      required this.activeAccountInfo,
      required this.routerCubit,
      required this.child,
      super.key});

  @override
  HomeAccountReadyShellState createState() => HomeAccountReadyShellState();

  final Widget child;
  final TypedKey activeLocalAccount;
  final ActiveAccountInfo activeAccountInfo;
  final RouterCubit routerCubit;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TypedKey>(
          'activeLocalAccount', activeLocalAccount))
      ..add(DiagnosticsProperty<ActiveAccountInfo>(
          'activeAccountInfo', activeAccountInfo))
      ..add(DiagnosticsProperty<RouterCubit>('routerCubit', routerCubit));
  }
}

class HomeAccountReadyShellState extends State<HomeAccountReadyShell> {
  final SingleStateProcessor<WaitingInvitationsBlocMapState>
      _singleInvitationStatusProcessor = SingleStateProcessor();

  @override
  void initState() {
    super.initState();
  }

  // Process all accepted or rejected invitations
  void _invitationStatusListener(
      BuildContext context, WaitingInvitationsBlocMapState state) {
    _singleInvitationStatusProcessor.updateState(state, (newState) async {
      final contactListCubit = context.read<ContactListCubit>();
      final contactInvitationListCubit =
          context.read<ContactInvitationListCubit>();

      for (final entry in newState.entries) {
        final contactRequestInboxRecordKey = entry.key;
        final invStatus = entry.value.asData?.value;
        // Skip invitations that have not yet been accepted or rejected
        if (invStatus == null) {
          continue;
        }

        // Delete invitation and process the accepted or rejected contact
        final acceptedContact = invStatus.acceptedContact;
        if (acceptedContact != null) {
          await contactInvitationListCubit.deleteInvitation(
              accepted: true,
              contactRequestInboxRecordKey: contactRequestInboxRecordKey);

          // Accept
          await contactListCubit.createContact(
            remoteProfile: acceptedContact.remoteProfile,
            remoteIdentity: acceptedContact.remoteIdentity,
            remoteConversationRecordKey:
                acceptedContact.remoteConversationRecordKey,
            localConversationRecordKey:
                acceptedContact.localConversationRecordKey,
          );
        } else {
          // Reject
          await contactInvitationListCubit.deleteInvitation(
              accepted: false,
              contactRequestInboxRecordKey: contactRequestInboxRecordKey);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountRecordCubit>().state.asData?.value;
    if (account == null) {
      return waitingPage();
    }
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ContactInvitationListCubit(
                  activeAccountInfo: widget.activeAccountInfo,
                  account: account)),
          BlocProvider(
              create: (context) => ContactListCubit(
                  activeAccountInfo: widget.activeAccountInfo,
                  account: account)),
          BlocProvider(
              create: (context) => ActiveChatCubit(null)
                ..withStateListen((event) {
                  widget.routerCubit.setHasActiveChat(event != null);
                })),
          BlocProvider(
              create: (context) => ChatListCubit(
                  activeAccountInfo: widget.activeAccountInfo,
                  activeChatCubit: context.read<ActiveChatCubit>(),
                  account: account)),
          BlocProvider(
              create: (context) => ActiveConversationsBlocMapCubit(
                  activeAccountInfo: widget.activeAccountInfo,
                  contactListCubit: context.read<ContactListCubit>())
                ..follow(context.read<ChatListCubit>())),
          BlocProvider(
              create: (context) => ActiveSingleContactChatBlocMapCubit(
                  activeAccountInfo: widget.activeAccountInfo,
                  contactListCubit: context.read<ContactListCubit>(),
                  chatListCubit: context.read<ChatListCubit>())
                ..follow(context.read<ActiveConversationsBlocMapCubit>())),
          BlocProvider(
              create: (context) => WaitingInvitationsBlocMapCubit(
                  activeAccountInfo: widget.activeAccountInfo, account: account)
                ..follow(context.read<ContactInvitationListCubit>()))
        ],
        child: MultiBlocListener(listeners: [
          BlocListener<WaitingInvitationsBlocMapCubit,
              WaitingInvitationsBlocMapState>(
            listener: _invitationStatusListener,
          )
        ], child: widget.child));
  }
}
