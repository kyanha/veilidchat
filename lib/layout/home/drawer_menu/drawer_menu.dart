import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../account_manager/account_manager.dart';
import '../../../proto/proto.dart' as proto;
import '../../../theme/theme.dart';
import '../../../tools/tools.dart';
import '../../../veilid_processor/veilid_processor.dart';
import 'menu_item_widget.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _doSwitchClick(TypedKey superIdentityRecordKey) {
    singleFuture(this, () async {
      await AccountRepository.instance.switchToAccount(superIdentityRecordKey);
    });
  }

  void _doEditClick(TypedKey superIdentityRecordKey,
      proto.Profile existingProfile, OwnedDHTRecordPointer accountRecord) {
    singleFuture(this, () async {
      await GoRouterHelper(context).push('/edit_account',
          extra: [superIdentityRecordKey, existingProfile, accountRecord]);
    });
  }

  Widget _wrapInBox(
          {required Widget child,
          required Color color,
          required double borderRadius}) =>
      DecoratedBox(
          decoration: ShapeDecoration(
              color: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius))),
          child: child);

  Widget _makeAccountWidget(
      {required String name,
      required bool selected,
      required ScaleColor scale,
      required ScaleConfig scaleConfig,
      required bool loggedIn,
      required void Function()? callback,
      required void Function()? footerCallback}) {
    final theme = Theme.of(context);
    final abbrev = name.split(' ').map((s) => s.isEmpty ? '' : s[0]).join();
    late final String shortname;
    if (abbrev.length >= 3) {
      shortname = abbrev[0] + abbrev[1] + abbrev[abbrev.length - 1];
    } else {
      shortname = abbrev;
    }

    late final Color background;
    late final Color hoverBackground;
    late final Color activeBackground;
    late final Color border;
    late final Color hoverBorder;
    late final Color activeBorder;
    if (scaleConfig.useVisualIndicators && !scaleConfig.preferBorders) {
      background = loggedIn ? scale.border : scale.subtleBorder;
      hoverBackground = background;
      activeBackground = background;
      border =
          selected ? scale.activeElementBackground : scale.elementBackground;
      hoverBorder = border;
      activeBorder = border;
    } else {
      background =
          selected ? scale.activeElementBackground : scale.elementBackground;
      hoverBackground = scale.hoverElementBackground;
      activeBackground = scale.activeElementBackground;
      border = loggedIn ? scale.border : scale.subtleBorder;
      hoverBorder = scale.hoverBorder;
      activeBorder = scale.primary;
    }

    final avatar = Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: scaleConfig.preferBorders
              ? Border.all(
                  color: border,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside)
              : null,
          color: Colors.blue,
        ),
        child: AvatarImage(
            //size: 32,
            backgroundColor: loggedIn ? scale.primary : scale.elementBackground,
            foregroundColor: loggedIn ? scale.primaryText : scale.subtleText,
            child: Text(shortname, style: theme.textTheme.titleLarge)));

    return AnimatedPadding(
        padding: EdgeInsets.fromLTRB(selected ? 0 : 8, selected ? 0 : 2,
            selected ? 0 : 8, selected ? 0 : 2),
        duration: const Duration(milliseconds: 50),
        child: MenuItemWidget(
          title: name,
          headerWidget: avatar,
          titleStyle: theme.textTheme.titleSmall!
              .copyWith(color: scaleConfig.useVisualIndicators ? border : null),
          foregroundColor: scale.primary,
          backgroundColor: background,
          backgroundHoverColor: hoverBackground,
          backgroundFocusColor: activeBackground,
          borderColor:
              (scaleConfig.preferBorders || scaleConfig.useVisualIndicators)
                  ? border
                  : null,
          borderHoverColor:
              (scaleConfig.preferBorders || scaleConfig.useVisualIndicators)
                  ? hoverBorder
                  : null,
          borderFocusColor:
              (scaleConfig.preferBorders || scaleConfig.useVisualIndicators)
                  ? activeBorder
                  : null,
          borderRadius: 12 * scaleConfig.borderRadiusScale,
          callback: callback,
          footerButtonIcon: loggedIn ? Icons.edit_outlined : null,
          footerCallback: footerCallback,
          footerButtonIconColor: border,
          footerButtonIconHoverColor: hoverBackground,
          footerButtonIconFocusColor: activeBackground,
        ));
  }

  List<Widget> _getAccountList(
      {required IList<LocalAccount> localAccounts,
      required TypedKey? activeLocalAccount,
      required PerAccountCollectionBlocMapState
          perAccountCollectionBlocMapState}) {
    final theme = Theme.of(context);
    final scaleScheme = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final loggedInAccounts = <Widget>[];
    final loggedOutAccounts = <Widget>[];

    for (final la in localAccounts) {
      final superIdentityRecordKey = la.superIdentity.recordKey;

      // See if this account is logged in
      final perAccountState =
          perAccountCollectionBlocMapState.get(superIdentityRecordKey);
      final avAccountRecordState = perAccountState?.avAccountRecordState;
      if (perAccountState != null && avAccountRecordState != null) {
        // Account is logged in
        final scale = scaleConfig.useVisualIndicators
            ? theme.extension<ScaleScheme>()!.primaryScale
            : theme.extension<ScaleScheme>()!.tertiaryScale;
        final loggedInAccount = avAccountRecordState.when(
          data: (value) => _makeAccountWidget(
              name: value.profile.name,
              scale: scale,
              scaleConfig: scaleConfig,
              selected: superIdentityRecordKey == activeLocalAccount,
              loggedIn: true,
              callback: () {
                _doSwitchClick(superIdentityRecordKey);
              },
              footerCallback: () {
                _doEditClick(
                    superIdentityRecordKey,
                    value.profile,
                    perAccountState.accountInfo.userLogin!.accountRecordInfo
                        .accountRecord);
              }),
          loading: () => _wrapInBox(
              child: buildProgressIndicator(),
              color: scaleScheme.grayScale.subtleBorder,
              borderRadius: 12 * scaleConfig.borderRadiusScale),
          error: (err, st) => _wrapInBox(
              child: errorPage(err, st),
              color: scaleScheme.errorScale.subtleBorder,
              borderRadius: 12 * scaleConfig.borderRadiusScale),
        );
        loggedInAccounts.add(loggedInAccount.paddingLTRB(0, 0, 0, 8));
      } else {
        // Account is not logged in
        final scale = theme.extension<ScaleScheme>()!.grayScale;
        final loggedOutAccount = _makeAccountWidget(
          name: la.name,
          scale: scale,
          scaleConfig: scaleConfig,
          selected: superIdentityRecordKey == activeLocalAccount,
          loggedIn: false,
          callback: () => {_doSwitchClick(superIdentityRecordKey)},
          footerCallback: null,
        );
        loggedOutAccounts.add(loggedOutAccount);
      }
    }

    // Assemble main menu
    return <Widget>[...loggedInAccounts, ...loggedOutAccounts];
  }

  Widget _getButton(
      {required Icon icon,
      required ScaleColor scale,
      required ScaleConfig scaleConfig,
      required String tooltip,
      required void Function()? onPressed}) {
    late final Color background;
    late final Color hoverBackground;
    late final Color activeBackground;
    late final Color border;
    late final Color hoverBorder;
    late final Color activeBorder;
    if (scaleConfig.useVisualIndicators && !scaleConfig.preferBorders) {
      background = scale.border;
      hoverBackground = scale.hoverBorder;
      activeBackground = scale.primary;
      border = scale.elementBackground;
      hoverBorder = scale.hoverElementBackground;
      activeBorder = scale.activeElementBackground;
    } else {
      background = scale.elementBackground;
      hoverBackground = scale.hoverElementBackground;
      activeBackground = scale.activeElementBackground;
      border = scale.border;
      hoverBorder = scale.hoverBorder;
      activeBorder = scale.primary;
    }
    return IconButton(
        icon: icon,
        color: border,
        constraints: const BoxConstraints.expand(height: 48, width: 48),
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return hoverBackground;
          }
          if (states.contains(WidgetState.focused)) {
            return activeBackground;
          }
          return background;
        }), shape: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return RoundedRectangleBorder(
                side: BorderSide(color: hoverBorder, width: 2),
                borderRadius: BorderRadius.all(
                    Radius.circular(12 * scaleConfig.borderRadiusScale)));
          }
          if (states.contains(WidgetState.focused)) {
            return RoundedRectangleBorder(
                side: BorderSide(color: activeBorder, width: 2),
                borderRadius: BorderRadius.all(
                    Radius.circular(12 * scaleConfig.borderRadiusScale)));
          }
          return RoundedRectangleBorder(
              side: BorderSide(color: border, width: 2),
              borderRadius: BorderRadius.all(
                  Radius.circular(12 * scaleConfig.borderRadiusScale)));
        })),
        tooltip: tooltip,
        onPressed: onPressed);
  }

  Widget _getBottomButtons() {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final settingsButton = _getButton(
        icon: const Icon(Icons.settings),
        tooltip: translate('menu.settings_tooltip'),
        scale: scale.tertiaryScale,
        scaleConfig: scaleConfig,
        onPressed: () async {
          await GoRouterHelper(context).push('/settings');
        }).paddingLTRB(0, 0, 16, 0);

    final addButton = _getButton(
        icon: const Icon(Icons.add),
        tooltip: translate('menu.add_account_tooltip'),
        scale: scale.tertiaryScale,
        scaleConfig: scaleConfig,
        onPressed: () async {
          await GoRouterHelper(context).push('/new_account');
        }).paddingLTRB(0, 0, 16, 0);

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [settingsButton, addButton]).paddingLTRB(0, 16, 0, 16);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;
    //final textTheme = theme.textTheme;
    final localAccounts = context.watch<LocalAccountsCubit>().state;
    final perAccountCollectionBlocMapState =
        context.watch<PerAccountCollectionBlocMapCubit>().state;
    final activeLocalAccount = context.watch<ActiveLocalAccountCubit>().state;
    final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scale.tertiaryScale.border,
          scale.tertiaryScale.subtleBorder,
        ]);

    return DecoratedBox(
      decoration: ShapeDecoration(
          shadows: [
            if (scaleConfig.useVisualIndicators && !scaleConfig.preferBorders)
              BoxShadow(
                color: scale.tertiaryScale.primary.darken(80),
                spreadRadius: 2,
              )
            else if (scaleConfig.useVisualIndicators &&
                scaleConfig.preferBorders)
              BoxShadow(
                color: scale.tertiaryScale.border,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: scale.tertiaryScale.primary.darken(40),
                blurRadius: 6,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
          ],
          gradient: scaleConfig.useVisualIndicators ? null : gradient,
          color: scaleConfig.useVisualIndicators
              ? (scaleConfig.preferBorders
                  ? scale.tertiaryScale.appBackground
                  : scale.tertiaryScale.subtleBorder)
              : null,
          shape: RoundedRectangleBorder(
              side: scaleConfig.preferBorders
                  ? BorderSide(color: scale.tertiaryScale.primary, width: 2)
                  : BorderSide.none,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16 * scaleConfig.borderRadiusScale),
                  bottomRight:
                      Radius.circular(16 * scaleConfig.borderRadiusScale)))),
      child: Column(children: [
        FittedBox(
            fit: BoxFit.scaleDown,
            child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    theme.brightness == Brightness.light
                        ? scale.tertiaryScale.primary
                        : scale.tertiaryScale.border,
                    scaleConfig.preferBorders
                        ? BlendMode.modulate
                        : BlendMode.dst),
                child: Row(children: [
                  SvgPicture.asset(
                          height: 48,
                          'assets/images/icon.svg',
                          colorFilter: scaleConfig.useVisualIndicators
                              ? grayColorFilter
                              : null)
                      .paddingLTRB(0, 0, 16, 0),
                  SvgPicture.asset(
                      height: 48,
                      'assets/images/title.svg',
                      colorFilter: scaleConfig.useVisualIndicators
                          ? grayColorFilter
                          : null),
                ]))),
        Text(translate('menu.accounts'),
                style: theme.textTheme.titleMedium!.copyWith(
                    color: scaleConfig.preferBorders
                        ? scale.tertiaryScale.border
                        : scale.tertiaryScale.borderText))
            .paddingLTRB(0, 16, 0, 16),
        ListView(
                shrinkWrap: true,
                children: _getAccountList(
                    localAccounts: localAccounts,
                    activeLocalAccount: activeLocalAccount,
                    perAccountCollectionBlocMapState:
                        perAccountCollectionBlocMapState))
            .expanded(),
        _getBottomButtons(),
        Row(children: [
          Text('${translate('menu.version')} $packageInfoVersion',
              style: theme.textTheme.labelMedium!.copyWith(
                  color: scaleConfig.preferBorders
                      ? scale.tertiaryScale.hoverBorder
                      : scale.tertiaryScale.subtleBackground)),
          const Spacer(),
          SignalStrengthMeterWidget(
            color: scaleConfig.preferBorders
                ? scale.tertiaryScale.hoverBorder
                : scale.tertiaryScale.subtleBackground,
            inactiveColor: scaleConfig.preferBorders
                ? scale.tertiaryScale.border
                : scale.tertiaryScale.elementBackground,
          ),
        ])
      ]).paddingAll(16),
    ).paddingLTRB(0, 2, 2, 2);
  }
}
