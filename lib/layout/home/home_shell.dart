import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

import '../../account_manager/account_manager.dart';
import '../../theme/theme.dart';
import 'drawer_menu/drawer_menu.dart';
import 'home_account_invalid.dart';
import 'home_account_locked.dart';
import 'home_account_missing.dart';
import 'home_no_active.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({required this.accountReadyBuilder, super.key});

  @override
  HomeShellState createState() => HomeShellState();

  final Builder accountReadyBuilder;
}

class HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildWithLogin(BuildContext context) {
    final accountInfo = context.watch<ActiveAccountInfoCubit>().state;
    final accountRecordsCubit = context.watch<AccountRecordsBlocMapCubit>();
    if (!accountInfo.active) {
      // If no logged in user is active, show the loading panel
      return const HomeNoActive();
    }

    final superIdentityRecordKey =
        accountInfo.unlockedAccountInfo?.superIdentityRecordKey;
    final activeCubit = superIdentityRecordKey == null
        ? null
        : accountRecordsCubit.tryOperate(superIdentityRecordKey,
            closure: (c) => c);
    if (activeCubit == null) {
      return waitingPage();
    }

    switch (accountInfo.status) {
      case AccountInfoStatus.noAccount:
        return const HomeAccountMissing();
      case AccountInfoStatus.accountInvalid:
        return const HomeAccountInvalid();
      case AccountInfoStatus.accountLocked:
        return const HomeAccountLocked();
      case AccountInfoStatus.accountReady:
        return MultiProvider(providers: [
          Provider<UnlockedAccountInfo>.value(
            value: accountInfo.unlockedAccountInfo!,
          ),
          Provider<AccountRecordCubit>.value(value: activeCubit),
          Provider<ZoomDrawerController>.value(value: _zoomDrawerController),
        ], child: widget.accountReadyBuilder);
    }
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
                  child: buildWithLogin(context)),
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

  final ZoomDrawerController _zoomDrawerController = ZoomDrawerController();
}
