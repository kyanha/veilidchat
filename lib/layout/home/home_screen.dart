import 'dart:math';

import 'package:async_tools/async_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
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

  Widget _buildAccount(BuildContext context, TypedKey superIdentityRecordKey,
      PerAccountCollectionState perAccountCollectionState) {
    switch (perAccountCollectionState.accountInfo.status) {
      case AccountInfoStatus.accountInvalid:
        return const HomeAccountInvalid();
      case AccountInfoStatus.accountLocked:
        return const HomeAccountLocked();
      case AccountInfoStatus.accountUnlocked:
        // Are we ready to render?
        if (!perAccountCollectionState.isReady) {
          return waitingPage();
        }

        // Re-export all ready blocs to the account display subtree
        return perAccountCollectionState.provide(
            child: Builder(builder: _buildAccountReadyDeviceSpecific));
    }
  }

  Widget _buildAccountPageView(BuildContext context) {
    final localAccounts = context.watch<LocalAccountsCubit>().state;
    final activeLocalAccount = context.watch<ActiveLocalAccountCubit>().state;
    final perAccountCollectionBlocMapState =
        context.watch<PerAccountCollectionBlocMapCubit>().state;

    final activeIndex = localAccounts
        .indexWhere((x) => x.superIdentity.recordKey == activeLocalAccount);
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
            builder: (context) => PageView.builder(
                onPageChanged: (idx) {
                  singleFuture(this, () async {
                    await AccountRepository.instance.switchToAccount(
                        localAccounts[idx].superIdentity.recordKey);
                  });
                },
                controller: context
                    .read<ActiveAccountPageControllerWrapper>()
                    .pageController,
                itemCount: localAccounts.length,
                itemBuilder: (context, index) {
                  final superIdentityRecordKey =
                      localAccounts[index].superIdentity.recordKey;
                  final perAccountCollectionState =
                      perAccountCollectionBlocMapState
                          .get(superIdentityRecordKey);
                  if (perAccountCollectionState == null) {
                    return HomeAccountMissing(
                        key: ValueKey(superIdentityRecordKey));
                  }
                  return _buildAccount(context, superIdentityRecordKey,
                      perAccountCollectionState);
                })));
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
}
