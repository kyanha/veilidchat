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
  const HomeShell({required this.child, super.key});

  @override
  HomeShellState createState() => HomeShellState();

  final Widget child;
}

class HomeShellState extends State<HomeShell> {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  Widget buildWithLogin(BuildContext context, Widget child) {
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
                    record: accountInfo.activeAccountInfo!.accountRecord),
                child: child));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    // XXX: eventually write account switcher here
    return SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: scale.primaryScale.activeElementBackground),
                child: buildWithLogin(context, widget.child))));
  }
}
