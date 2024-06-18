import 'dart:math';

import 'package:async_tools/async_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../chat_list/chat_list.dart';
import '../../contact_invitation/contact_invitation.dart';
import '../../contacts/contacts.dart';
import '../../conversation/conversation.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import 'active_account_page_controller_wrapper.dart';
import 'drawer_menu/drawer_menu.dart';
import 'home_account_invalid.dart';
import 'home_account_locked.dart';
import 'home_account_missing.dart';
import 'home_account_ready/home_account_ready.dart';
import 'home_no_active.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            profile: acceptedContact.remoteProfile,
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

  Widget _buildAccountReadyDeviceSpecific(BuildContext context) {
    final hasActiveChat = context.watch<ActiveChatCubit>().state != null;
    if (responsiveVisibility(
        context: context,
        tablet: false,
        tabletLandscape: false,
        desktop: false)) {
      if (hasActiveChat) {
        return const HomeAccountReadyChat();
      }
    }
    return const HomeAccountReadyMain();
  }

  Widget _buildUnlockedAccount(BuildContext context) {
    final accountRecordKey = context.select<AccountInfoCubit, TypedKey>(
        (c) => c.state.unlockedAccountInfo!.accountRecordKey);
    final contactListRecordPointer =
        context.select<AccountRecordCubit, OwnedDHTRecordPointer?>(
            (c) => c.state.asData?.value.contactList.toVeilid());
    final contactInvitationListRecordPointer =
        context.select<AccountRecordCubit, OwnedDHTRecordPointer?>(
            (c) => c.state.asData?.value.contactInvitationRecords.toVeilid());
    final chatListRecordPointer =
        context.select<AccountRecordCubit, OwnedDHTRecordPointer?>(
            (c) => c.state.asData?.value.chatList.toVeilid());

    if (contactListRecordPointer == null ||
        contactInvitationListRecordPointer == null ||
        chatListRecordPointer == null) {
      return waitingPage();
    }

    return MultiBlocProvider(
        providers: [
          // Contact Cubits
          BlocProvider(
              create: (context) => ContactInvitationListCubit(
                    locator: context.read,
                    accountRecordKey: accountRecordKey,
                    contactInvitationListRecordPointer:
                        contactInvitationListRecordPointer,
                  )),
          BlocProvider(
              create: (context) => ContactListCubit(
                  locator: context.read,
                  accountRecordKey: accountRecordKey,
                  contactListRecordPointer: contactListRecordPointer)),
          BlocProvider(
              create: (context) => WaitingInvitationsBlocMapCubit(
                    locator: context.read,
                  )),
          // Chat Cubits
          BlocProvider(
              create: (context) => ActiveChatCubit(
                    null,
                  )),
          BlocProvider(
              create: (context) => ChatListCubit(
                  locator: context.read,
                  accountRecordKey: accountRecordKey,
                  chatListRecordPointer: chatListRecordPointer)),
          // Conversation Cubits
          BlocProvider(
              create: (context) => ActiveConversationsBlocMapCubit(
                    locator: context.read,
                  )),
          BlocProvider(
              create: (context) => ActiveSingleContactChatBlocMapCubit(
                    locator: context.read,
                  )),
        ],
        child: MultiBlocListener(listeners: [
          BlocListener<WaitingInvitationsBlocMapCubit,
              WaitingInvitationsBlocMapState>(
            listener: _invitationStatusListener,
          )
        ], child: Builder(builder: _buildAccountReadyDeviceSpecific)));
  }

  Widget _buildAccount(BuildContext context, TypedKey superIdentityRecordKey) =>
      BlocProvider<AccountInfoCubit>(
          key: ValueKey(superIdentityRecordKey),
          create: (context) => AccountInfoCubit(
              AccountRepository.instance, superIdentityRecordKey),
          child: Builder(builder: (context) {
            // Get active account info status
            final accountInfoStatus =
                context.select<AccountInfoCubit, AccountInfoStatus>(
                    (c) => c.state.status);

            switch (accountInfoStatus) {
              case AccountInfoStatus.noAccount:
                return const HomeAccountMissing();
              case AccountInfoStatus.accountInvalid:
                return const HomeAccountInvalid();
              case AccountInfoStatus.accountLocked:
                return const HomeAccountLocked();
              case AccountInfoStatus.accountUnlocked:

                // Get the current active account record cubit
                final activeAccountRecordCubit = context
                    .select<AccountRecordsBlocMapCubit, AccountRecordCubit?>(
                        (c) => c.tryOperate(superIdentityRecordKey,
                            closure: (x) => x));
                if (activeAccountRecordCubit == null) {
                  return waitingPage();
                }

                return MultiBlocProvider(providers: [
                  BlocProvider<AccountRecordCubit>.value(
                      value: activeAccountRecordCubit),
                ], child: Builder(builder: _buildUnlockedAccount));
            }
          }));

  Widget _buildAccountPageView(BuildContext context) {
    final localAccounts = context.watch<LocalAccountsCubit>().state;
    final activeLocalAccountCubit = context.read<ActiveLocalAccountCubit>();

    final activeIndex = localAccounts.indexWhere(
        (x) => x.superIdentity.recordKey == activeLocalAccountCubit.state);
    if (activeIndex == -1) {
      return const HomeNoActive();
    }

    return Provider<ActiveAccountPageControllerWrapper>(
        lazy: false,
        create: (context) =>
            ActiveAccountPageControllerWrapper(context.read, activeIndex),
        dispose: (context, value) {
          value.dispose();
        },
        child: Builder(
            builder: (context) => PageView.custom(
                onPageChanged: (idx) {
                  singleFuture(this, () async {
                    await AccountRepository.instance.switchToAccount(
                        localAccounts[idx].superIdentity.recordKey);
                  });
                },
                controller: context
                    .read<ActiveAccountPageControllerWrapper>()
                    .pageController,
                childrenDelegate: SliverChildListDelegate(localAccounts
                    .map((la) =>
                        _buildAccount(context, la.superIdentity.recordKey))
                    .toList()))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          scale.tertiaryScale.subtleBackground,
          scale.tertiaryScale.appBackground,
        ]);

    return SafeArea(
        child: DecoratedBox(
            decoration: BoxDecoration(gradient: gradient),
            child: ZoomDrawer(
              controller: _zoomDrawerController,
              //menuBackgroundColor: Colors.transparent,
              menuScreen: const DrawerMenu(),
              mainScreen: DecoratedBox(
                  decoration: BoxDecoration(
                      color: scale.primaryScale.activeElementBackground),
                  child: Provider<ZoomDrawerController>.value(
                      value: _zoomDrawerController,
                      child: Builder(builder: _buildAccountPageView))),
              borderRadius: 24,
              showShadow: true,
              angle: 0,
              drawerShadowsBackgroundColor: theme.shadowColor,
              mainScreenOverlayColor: theme.shadowColor.withAlpha(0x3F),
              openCurve: Curves.fastEaseInToSlowEaseOut,
              // duration: const Duration(milliseconds: 250),
              // reverseDuration: const Duration(milliseconds: 250),
              menuScreenTapClose: true,
              mainScreenTapClose: true,
              mainScreenScale: .25,
              slideWidth: min(360, MediaQuery.of(context).size.width * 0.9),
            )));
  }

  final _zoomDrawerController = ZoomDrawerController();
  final _singleInvitationStatusProcessor =
      SingleStateProcessor<WaitingInvitationsBlocMapState>();
}
