import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../account_manager/account_manager.dart';
import '../../theme/theme.dart';
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
    final activeLocalAccount = context.watch<ActiveLocalAccountCubit>().state;

    if (activeLocalAccount == null) {
      // If no logged in user is active, show the loading panel
      return const HomeNoActive();
    }

    final accountInfo =
        AccountRepository.instance.getAccountInfo(activeLocalAccount);

    switch (accountInfo.status) {
      case AccountInfoStatus.noAccount:
        return const HomeAccountMissing();
      case AccountInfoStatus.accountInvalid:
        return const HomeAccountInvalid();
      case AccountInfoStatus.accountLocked:
        return const HomeAccountLocked();
      case AccountInfoStatus.accountReady:
        return Provider<ActiveAccountInfo>.value(
            value: accountInfo.activeAccountInfo!,
            child: BlocProvider(
                create: (context) => AccountRecordCubit(
                    open: () async => AccountRepository.instance
                        .openAccountRecord(
                            accountInfo.activeAccountInfo!.userLogin)),
                child: widget.accountReadyBuilder));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    // XXX: eventually write account switcher here
    return SafeArea(
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: scale.primaryScale.activeElementBackground),
            child: buildWithLogin(context)));
  }
}
