import 'package:async_tools/async_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../account_manager/account_manager.dart';
import '../../../chat/chat.dart';
import '../../../chat_list/chat_list.dart';
import '../../../contact_invitation/contact_invitation.dart';
import '../../../contacts/contacts.dart';
import '../../../conversation/conversation.dart';
import '../../../router/router.dart';
import '../../../theme/theme.dart';

class HomeAccountReadyShell extends StatefulWidget {
  factory HomeAccountReadyShell(
      {required BuildContext context, required Widget child, Key? key}) {
    // These must exist in order for the account to
    // be considered 'ready' for this widget subtree
    final unlockedAccountInfo = context.watch<UnlockedAccountInfo>();
    final routerCubit = context.read<RouterCubit>();

    return HomeAccountReadyShell._(
        unlockedAccountInfo: unlockedAccountInfo,
        routerCubit: routerCubit,
        key: key,
        child: child);
  }
  const HomeAccountReadyShell._(
      {required this.unlockedAccountInfo,
      required this.routerCubit,
      required this.child,
      super.key});

  @override
  HomeAccountReadyShellState createState() => HomeAccountReadyShellState();

  final Widget child;
  final UnlockedAccountInfo unlockedAccountInfo;
  final RouterCubit routerCubit;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<UnlockedAccountInfo>(
          'unlockedAccountInfo', unlockedAccountInfo))
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
            remoteSuperIdentity: acceptedContact.remoteIdentity,
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
    // XXX: Should probably eliminate this in favor
    // of streaming changes into other cubits. Too much rebuilding!
    // should not need to 'watch' all these cubits
    final account = context.watch<AccountRecordCubit>().state.asData?.value;
    if (account == null) {
      return waitingPage();
    }
    return MultiBlocProvider(
        providers: [
          // Contact Cubits
          BlocProvider(
              create: (context) => ContactInvitationListCubit(
                  unlockedAccountInfo: widget.unlockedAccountInfo,
                  account: account)),
          BlocProvider(
              create: (context) => ContactListCubit(
                  unlockedAccountInfo: widget.unlockedAccountInfo,
                  account: account)),
          BlocProvider(
              create: (context) => WaitingInvitationsBlocMapCubit(
                  unlockedAccountInfo: widget.unlockedAccountInfo,
                  account: account)
                ..follow(context.read<ContactInvitationListCubit>())),
          // Chat Cubits
          BlocProvider(
              create: (context) => ActiveChatCubit(null,
                  routerCubit: context.read<RouterCubit>())),
          BlocProvider(
              create: (context) => ChatListCubit(
                  unlockedAccountInfo: widget.unlockedAccountInfo,
                  activeChatCubit: context.read<ActiveChatCubit>(),
                  account: account)),
          // Conversation Cubits
          BlocProvider(
              create: (context) => ActiveConversationsBlocMapCubit(
                  unlockedAccountInfo: widget.unlockedAccountInfo,
                  contactListCubit: context.read<ContactListCubit>(),
                  accountRecordCubit: context.read<AccountRecordCubit>())
                ..follow(context.read<ChatListCubit>())),
          BlocProvider(
              create: (context) => ActiveSingleContactChatBlocMapCubit(
                  unlockedAccountInfo: widget.unlockedAccountInfo,
                  contactListCubit: context.read<ContactListCubit>(),
                  chatListCubit: context.read<ChatListCubit>())
                ..follow(context.read<ActiveConversationsBlocMapCubit>())),
        ],
        child: MultiBlocListener(listeners: [
          BlocListener<WaitingInvitationsBlocMapCubit,
              WaitingInvitationsBlocMapState>(
            listener: _invitationStatusListener,
          )
        ], child: widget.child));
  }
}
