import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../account_manager/account_manager.dart';
import '../../../contact_invitation/contact_invitation.dart';
import '../../../proto/proto.dart' as proto;
import '../../../theme/theme.dart';
import '../../../tools/tools.dart';

class HomeAccountReady extends StatefulWidget {
  const HomeAccountReady(
      {required IList<LocalAccount> localAccounts,
      required TypedKey activeUserLogin,
      required ActiveAccountInfo activeAccountInfo,
      required proto.Account account,
      super.key})
      : _localAccounts = localAccounts,
        _activeUserLogin = activeUserLogin,
        _activeAccountInfo = activeAccountInfo,
        _account = account;

  final IList<LocalAccount> _localAccounts;
  final TypedKey _activeUserLogin;
  final ActiveAccountInfo _activeAccountInfo;
  final proto.Account _account;

  @override
  HomeAccountReadyState createState() => HomeAccountReadyState();
}

class HomeAccountReadyState extends State<HomeAccountReady>
    with TickerProviderStateMixin {
  //
  ContactInvitationRepository? _contactInvitationRepository;

  //
  @override
  void initState() {
    super.initState();

    // Async initialize repositories for the active user
    // xxx: this should not be necessary
    // xxx: but RepositoryProvider doesn't call dispose()
    Future.delayed(Duration.zero, () async {
      //
      final cir = await ContactInvitationRepository.open(
          widget._activeAccountInfo, widget._account);

      setState(() {
        _contactInvitationRepository = cir;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _contactInvitationRepository?.dispose();
  }

  // ignore: prefer_expression_function_bodies
  Widget buildAccountList() {
    return const Column(children: [
      Center(child: Text('Small Profile')),
      Center(child: Text('Contact invitations')),
      Center(child: Text('Contacts'))
    ]);
  }

  Widget buildUnlockAccount(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    // ignore: prefer_expression_function_bodies
  ) {
    return const Center(child: Text('unlock account'));
  }

  /// We have an active, unlocked, user login
  Widget buildReadyAccount(
      BuildContext context,
      IList<LocalAccount> localAccounts,
      TypedKey activeUserLogin,
      DHTRecord accountRecord) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

xxx get rid of the cubit here and 

    return BlocProvider(
        create: (context) => AccountRecordCubit(record: accountRecord),
        child: Column(children: <Widget>[
          Row(children: [
            IconButton(
                icon: const Icon(Icons.settings),
                color: scale.secondaryScale.text,
                constraints: const BoxConstraints.expand(height: 64, width: 64),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(scale.secondaryScale.border),
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))))),
                tooltip: translate('app_bar.settings_tooltip'),
                onPressed: () async {
                  context.go('/home/settings');
                }).paddingLTRB(0, 0, 8, 0),
            context
                .watch<AccountRecordCubit>()
                .state
                .builder((context, account) => ProfileWidget(
                      name: account.profile.name,
                      pronouns: account.profile.pronouns,
                    ))
                .expanded(),
          ]).paddingAll(8),
          context
              .watch<AccountRecordCubit>()
              .state
              .builder((context, account) => MainPager(
                  localAccounts: localAccounts,
                  activeUserLogin: activeUserLogin,
                  account: account))
              .expanded()
        ]));
  }

xxx get rid of this whole function

  Widget buildUserPanel() => Builder(builder: (context) {
        final activeUserLogin = context.watch<ActiveUserLoginCubit>().state;
        final localAccounts = context.watch<LocalAccountsCubit>().state;

        if (activeUserLogin == null) {
          // If no logged in user is active, show the loading panel
          return waitingPage(context);
        }

        final account = AccountRepository.instance
            .getAccountInfo(accountMasterRecordKey: activeUserLogin)!;

        switch (account.status) {
          case AccountInfoStatus.noAccount:
            Future.delayed(0.ms, () async {
              await showErrorModal(
                  context,
                  translate('home.missing_account_title'),
                  translate('home.missing_account_text'));
              // Delete account
              await AccountRepository.instance
                  .deleteLocalAccount(activeUserLogin);
              // Switch to no active user login
              await AccountRepository.instance.switchToAccount(null);
            });
            return waitingPage(context);
          case AccountInfoStatus.accountInvalid:
            Future.delayed(0.ms, () async {
              await showErrorModal(
                  context,
                  translate('home.invalid_account_title'),
                  translate('home.invalid_account_text'));
              // Delete account
              await AccountRepository.instance
                  .deleteLocalAccount(activeUserLogin);
              // Switch to no active user login
              await AccountRepository.instance.switchToAccount(null);
            });
            return waitingPage(context);
          case AccountInfoStatus.accountLocked:
            // Show unlock widget
            return buildUnlockAccount(context, localAccounts);
          case AccountInfoStatus.accountReady:
            return buildReadyAccount(
              context,
              localAccounts,
              activeUserLogin,
              account.activeAccountInfo!.accountRecord,
            );
        }
      });

  Widget buildPhone() =>
      Material(color: Colors.transparent, child: buildUserPanel());

  Widget buildTabletLeftPane() =>
      Material(color: Colors.transparent, child: buildUserPanel());

  Widget buildTabletRightPane() => buildChatComponent();

  // ignore: prefer_expression_function_bodies
  Widget buildTablet() => Builder(builder: (context) {
        final w = MediaQuery.of(context).size.width;
        final theme = Theme.of(context);
        final scale = theme.extension<ScaleScheme>()!;

        final children = [
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: w / 2),
                  child: buildTabletLeftPane())),
          SizedBox(
              width: 2,
              height: double.infinity,
              child: ColoredBox(color: scale.primaryScale.hoverBorder)),
          Expanded(child: buildTabletRightPane()),
        ];

        return Row(
          children: children,
        );
      });

  @override
  Widget build(BuildContext context) {
    if (_contactInvitationRepository == null) {
      return waitingPage(context);
    }

    return responsiveVisibility(
      context: context,
      phone: false,
    )
        ? buildTablet()
        : buildPhone();
  }
}
