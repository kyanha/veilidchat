import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:transitioned_indexed_stack/transitioned_indexed_stack.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../settings/settings.dart';
import '../../theme/theme.dart';
import 'drawer_menu/drawer_menu.dart';
import 'home_account_invalid.dart';
import 'home_account_locked.dart';
import 'home_account_missing.dart';
import 'home_account_ready.dart';
import 'home_no_active.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();

  static HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<HomeScreenState>();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final localAccounts = context.read<LocalAccountsCubit>().state;
      final activeLocalAccount = context.read<ActiveLocalAccountCubit>().state;
      final activeIndex = localAccounts
          .indexWhere((x) => x.superIdentity.recordKey == activeLocalAccount);
      final canClose = activeIndex != -1;

      final displayBetaWarning = context
              .read<PreferencesCubit>()
              .state
              .asData
              ?.value
              .notificationsPreference
              .displayBetaWarning ??
          true;
      if (displayBetaWarning) {
        await _doBetaDialog(context);
      }

      if (!canClose) {
        await _zoomDrawerController.open!();
      }
    });
    super.initState();
  }

  Future<void> _doBetaDialog(BuildContext context) async {
    var displayBetaWarning = true;
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    await showWarningWidgetModal(
      context: context,
      title: translate('splash.beta_title'),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: translate('splash.beta_text'),
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: scale.primaryScale.appText),
              ),
              TextSpan(
                text: 'https://veilid.com/chat/knownissues',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: scaleConfig.useVisualIndicators
                      ? scale.secondaryScale.primaryText
                      : scale.secondaryScale.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      launchUrlString('https://veilid.com/chat/knownissues'),
              ),
            ],
          ),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          StatefulBuilder(
              builder: (context, setState) => Checkbox.adaptive(
                    value: displayBetaWarning,
                    onChanged: (value) {
                      setState(() {
                        displayBetaWarning = value ?? true;
                      });
                    },
                  )),
          Text(
            translate('settings_page.display_beta_warning'),
            style: theme.textTheme.bodyMedium!
                .copyWith(color: scale.primaryScale.appText),
          ),
        ]),
      ]),
    );

    final preferencesInstance = PreferencesRepository.instance;
    await preferencesInstance.set(preferencesInstance.value.copyWith(
        notificationsPreference: preferencesInstance
            .value.notificationsPreference
            .copyWith(displayBetaWarning: displayBetaWarning)));
  }

  Widget _buildAccountPage(
      BuildContext context,
      TypedKey superIdentityRecordKey,
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
            child: Navigator(
                onPopPage: (route, result) {
                  if (!route.didPop(result)) {
                    return false;
                  }
                  return true;
                },
                pages: const [MaterialPage(child: HomeAccountReady())]));
    }
  }

  Widget _applyPageBorder(Widget child) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return ValueListenableBuilder(
        valueListenable: _zoomDrawerController.stateNotifier!,
        child: child,
        builder: (context, drawerState, staticChild) => clipBorder(
            clipEnabled: drawerState != DrawerState.closed,
            borderEnabled:
                scaleConfig.preferBorders && scaleConfig.useVisualIndicators,
            borderRadius: 16 * scaleConfig.borderRadiusScale,
            borderColor: scale.primaryScale.border,
            child: staticChild!));
  }

  Widget _buildAccountPageView(BuildContext context) {
    final localAccounts = context.watch<LocalAccountsCubit>().state;
    final activeLocalAccount = context.watch<ActiveLocalAccountCubit>().state;
    final perAccountCollectionBlocMapState =
        context.watch<PerAccountCollectionBlocMapCubit>().state;

    final activeIndex = localAccounts
        .indexWhere((x) => x.superIdentity.recordKey == activeLocalAccount);
    if (activeIndex == -1) {
      return _applyPageBorder(const HomeNoActive());
    }

    final accountPages = <Widget>[];

    for (var i = 0; i < localAccounts.length; i++) {
      final superIdentityRecordKey = localAccounts[i].superIdentity.recordKey;
      final perAccountCollectionState =
          perAccountCollectionBlocMapState.get(superIdentityRecordKey);
      if (perAccountCollectionState == null) {
        return HomeAccountMissing(key: ValueKey(superIdentityRecordKey));
      }
      final accountPage = _buildAccountPage(
          context, superIdentityRecordKey, perAccountCollectionState);
      accountPages.add(_applyPageBorder(accountPage));
    }

    return SlideIndexedStack(
      index: activeIndex,
      beginSlideOffset: const Offset(1, 0),
      children: accountPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final localAccounts = context.watch<LocalAccountsCubit>().state;
    final activeLocalAccount = context.watch<ActiveLocalAccountCubit>().state;
    final activeIndex = localAccounts
        .indexWhere((x) => x.superIdentity.recordKey == activeLocalAccount);
    final canClose = activeIndex != -1;

    return SafeArea(
        child: DefaultTextStyle(
            style: theme.textTheme.bodySmall!,
            child: ZoomDrawer(
              controller: _zoomDrawerController,
              //menuBackgroundColor: Colors.transparent,
              menuScreen: Builder(builder: (context) {
                final zoomDrawer = ZoomDrawer.of(context);
                zoomDrawer!.stateNotifier.addListener(() {
                  if (zoomDrawer.isOpen()) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                });
                return const DrawerMenu();
              }),
              mainScreen: Provider<ZoomDrawerController>.value(
                  value: _zoomDrawerController,
                  child: Builder(builder: _buildAccountPageView)),
              borderRadius: 0,
              angle: 0,
              mainScreenOverlayColor: theme.shadowColor.withAlpha(0x2F),
              openCurve: Curves.fastEaseInToSlowEaseOut,
              // duration: const Duration(milliseconds: 250),
              // reverseDuration: const Duration(milliseconds: 250),
              menuScreenTapClose: canClose,
              mainScreenTapClose: canClose,
              disableDragGesture: !canClose,
              mainScreenScale: .25,
              slideWidth: min(360, MediaQuery.of(context).size.width * 0.9),
            )));
  }

  ////////////////////////////////////////////////////////////////////////////

  final _zoomDrawerController = ZoomDrawerController();
}
