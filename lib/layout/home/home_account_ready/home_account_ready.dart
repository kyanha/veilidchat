import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../account_manager/account_manager.dart';
import '../../../contact_invitation/contact_invitation.dart';
import '../../../proto/proto.dart' as proto;
import '../../../theme/theme.dart';
import '../../../tools/tools.dart';
import 'main_pager/main_pager.dart';

class HomeAccountReady extends StatefulWidget {
  const HomeAccountReady(
      {required ActiveAccountInfo activeAccountInfo,
      required Account account,
      super.key})
      : _accountReadyContext = accountReadyContext;

  final AccountReadyContext _accountReadyContext;

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
          widget.activeAccountInfo, widget._accountReadyContext.account);

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

  Widget buildUnlockAccount(
    BuildContext context,
    IList<LocalAccount> localAccounts,
    // ignore: prefer_expression_function_bodies
  ) {
    return const Center(child: Text('unlock account'));
  }

  Widget buildUserPanel(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return Column(children: <Widget>[
      Row(children: [
        IconButton(
            icon: const Icon(Icons.settings),
            color: scale.secondaryScale.text,
            constraints: const BoxConstraints.expand(height: 64, width: 64),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(scale.secondaryScale.border),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))))),
            tooltip: translate('app_bar.settings_tooltip'),
            onPressed: () async {
              context.go('/home/settings');
            }).paddingLTRB(0, 0, 8, 0),
        ProfileWidget(
          name: widget._accountReadyContext.account.profile.name,
          pronouns: widget._accountReadyContext.account.profile.pronouns,
        ).expanded(),
      ]).paddingAll(8),
      MainPager().expanded()
    ]);
  }

  Widget buildPhone(BuildContext context) =>
      Material(color: Colors.transparent, child: buildUserPanel(context));

  Widget buildTabletLeftPane(BuildContext context) => Builder(
      builder: (context) =>
          Material(color: Colors.transparent, child: buildUserPanel(context)));

  Widget buildTabletRightPane(BuildContext context) => buildChatComponent();

  // ignore: prefer_expression_function_bodies
  Widget buildTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    final children = [
      ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: w / 2),
              child: buildTabletLeftPane(context))),
      SizedBox(
          width: 2,
          height: double.infinity,
          child: ColoredBox(color: scale.primaryScale.hoverBorder)),
      Expanded(child: buildTabletRightPane(context)),
    ];

    return Row(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contactInvitationRepository == null) {
      return waitingPage(context);
    }

    return RepositoryProvider.value(
        value: _contactInvitationRepository,
        child: responsiveVisibility(
          context: context,
          phone: false,
        )
            ? buildTablet(context)
            : buildPhone(context));
  }
}
