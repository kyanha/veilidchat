import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../account_manager/account_manager.dart';
import '../../../theme/theme.dart';
import '../../../tools/tools.dart';
import 'menu_item_widget.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State createState() => _DrawerMenuState();
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

  void _doLoginClick(TypedKey superIdentityRecordKey) {
    //
  }

  void _doEditClick(TypedKey superIdentityRecordKey) {
    //
  }

  Widget _wrapInBox({required Widget child, required Color color}) =>
      DecoratedBox(
          decoration: ShapeDecoration(
              color: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: child);

  Widget _makeAccountWidget(
      {required String name,
      required bool loggedIn,
      required void Function() clickHandler}) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!.tertiaryScale;
    final abbrev = name.split(' ').map((s) => s.isEmpty ? '' : s[0]).join();
    late final String shortname;
    if (abbrev.length >= 3) {
      shortname = abbrev[0] + abbrev[1] + abbrev[abbrev.length - 1];
    } else {
      shortname = abbrev;
    }

    final avatar = AvatarImage(
        size: 32,
        backgroundColor: loggedIn ? scale.primary : scale.elementBackground,
        foregroundColor: loggedIn ? scale.primaryText : scale.subtleText,
        child: Text(shortname, style: theme.textTheme.titleLarge));

    return MenuItemWidget(
      title: name,
      headerWidget: avatar,
      titleStyle: theme.textTheme.titleLarge!,
      foregroundColor: scale.primary,
      backgroundColor: scale.elementBackground,
      backgroundHoverColor: scale.hoverElementBackground,
      backgroundFocusColor: scale.activeElementBackground,
      borderColor: scale.border,
      borderHoverColor: scale.hoverBorder,
      borderFocusColor: scale.primary,
      footerButtonIcon: loggedIn ? Icons.edit_outlined : Icons.login_outlined,
      footerCallback: clickHandler,
      footerButtonIconColor: scale.border,
      footerButtonIconHoverColor: scale.hoverElementBackground,
      footerButtonIconFocusColor: scale.activeElementBackground,
    );
  }

  Widget _getAccountList(
      {required TypedKey? activeLocalAccount,
      required AccountRecordsBlocMapState accountRecords}) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    final accountRepo = AccountRepository.instance;
    final localAccounts = accountRepo.getLocalAccounts();
    //final userLogins = accountRepo.getUserLogins();

    final loggedInAccounts = <Widget>[];
    final loggedOutAccounts = <Widget>[];

    for (final la in localAccounts) {
      final superIdentityRecordKey = la.superIdentity.recordKey;

      // See if this account is logged in
      final acctRecord = accountRecords.get(superIdentityRecordKey);
      if (acctRecord != null) {
        // Account is logged in
        final loggedInAccount = acctRecord.when(
          data: (value) => _makeAccountWidget(
              name: value.profile.name,
              loggedIn: true,
              clickHandler: () {
                _doEditClick(superIdentityRecordKey);
              }),
          loading: () => _wrapInBox(
              child: buildProgressIndicator(),
              color: scale.grayScale.subtleBorder),
          error: (err, st) => _wrapInBox(
              child: errorPage(err, st), color: scale.errorScale.subtleBorder),
        );
        loggedInAccounts.add(loggedInAccount);
      } else {
        // Account is not logged in
        final loggedOutAccount = _makeAccountWidget(
            name: la.name,
            loggedIn: false,
            clickHandler: () {
              _doLoginClick(superIdentityRecordKey);
            });
        loggedOutAccounts.add(loggedOutAccount);
      }
    }

    // Assemble main menu
    final mainMenu = <Widget>[...loggedInAccounts, ...loggedOutAccounts];

    // Return main menu widgets
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[...mainMenu],
    );
  }

  Widget _getButton(
          {required Icon icon,
          required ScaleColor scale,
          required String tooltip,
          required void Function()? onPressed}) =>
      IconButton(
          icon: icon,
          color: scale.hoverBorder,
          constraints: const BoxConstraints.expand(height: 64, width: 64),
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return scale.hoverElementBackground;
            }
            if (states.contains(WidgetState.focused)) {
              return scale.activeElementBackground;
            }
            return scale.elementBackground;
          }), shape: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return RoundedRectangleBorder(
                  side: BorderSide(color: scale.hoverBorder),
                  borderRadius: const BorderRadius.all(Radius.circular(16)));
            }
            if (states.contains(WidgetState.focused)) {
              return RoundedRectangleBorder(
                  side: BorderSide(color: scale.primary),
                  borderRadius: const BorderRadius.all(Radius.circular(16)));
            }
            return RoundedRectangleBorder(
                side: BorderSide(color: scale.border),
                borderRadius: const BorderRadius.all(Radius.circular(16)));
          })),
          tooltip: tooltip,
          onPressed: onPressed);

  Widget _getBottomButtons() {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    final settingsButton = _getButton(
        icon: const Icon(Icons.settings),
        tooltip: translate('menu.settings_tooltip'),
        scale: scale.tertiaryScale,
        onPressed: () async {
          await GoRouterHelper(context).push('/settings');
        }).paddingLTRB(0, 0, 16, 0);

    final addButton = _getButton(
        icon: const Icon(Icons.add),
        tooltip: translate('menu.add_account_tooltip'),
        scale: scale.tertiaryScale,
        onPressed: () async {
          await GoRouterHelper(context).push('/new_account');
        }).paddingLTRB(0, 0, 16, 0);

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [settingsButton, addButton]).paddingLTRB(0, 16, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    //final textTheme = theme.textTheme;
    final accountRecords = context.watch<AccountRecordsBlocMapCubit>().state;
    final activeLocalAccount = context.watch<ActiveLocalAccountCubit>().state;
    final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scale.tertiaryScale.hoverElementBackground,
          scale.tertiaryScale.subtleBackground,
        ]);

    return DecoratedBox(
      decoration: ShapeDecoration(
          shadows: [
            BoxShadow(
              color: scale.tertiaryScale.appBackground,
              blurRadius: 6,
              offset: const Offset(
                0,
                3,
              ),
            ),
          ],
          gradient: gradient,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16)))),
      child: Column(children: [
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(children: [
              SvgPicture.asset(
                height: 48,
                'assets/images/icon.svg',
              ).paddingLTRB(0, 0, 16, 0),
              SvgPicture.asset(
                height: 48,
                'assets/images/title.svg',
              ),
            ])),
        const Spacer(),
        _getAccountList(
            activeLocalAccount: activeLocalAccount,
            accountRecords: accountRecords),
        _getBottomButtons(),
        const Spacer(),
        Text('Version $packageInfoVersion',
            style: theme.textTheme.labelMedium!
                .copyWith(color: scale.tertiaryScale.hoverBorder))
      ]).paddingAll(16),
    );
  }
}
