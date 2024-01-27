import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import 'home_account_invalid.dart';
import 'home_account_locked.dart';
import 'home_account_missing.dart';
import 'home_account_ready.dart';
import 'home_account_ready/home_account_ready.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.normal);
    });
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  Widget buildWithLogin(BuildContext context, IList<LocalAccount> localAccounts,
      Typed<FixedEncodedString43>? activeUserLogin) {
    if (activeUserLogin == null) {
      // If no logged in user is active, show the loading panel
      return waitingPage(context);
    }

    final accountInfo = AccountRepository.instance
        .getAccountInfo(accountMasterRecordKey: activeUserLogin)!;

    switch (accountInfo.status) {
      case AccountInfoStatus.noAccount:
        return const HomeAccountMissing();
      case AccountInfoStatus.accountInvalid:
        return const HomeAccountInvalid();
      case AccountInfoStatus.accountLocked:
        return const HomeAccountLocked();
      case AccountInfoStatus.accountReady:
        return BlocProvider(
            create: (context) => AccountRecordCubit(
                record: accountInfo.activeAccountInfo!.accountRecord),
            child: context.watch<AccountRecordCubit>().state.builder(
                (context, account) => HomeAccountReady(
                    localAccounts: localAccounts,
                    activeUserLogin: activeUserLogin,
                    activeAccountInfo: accountInfo.activeAccountInfo!,
                    account: account)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final activeUserLogin = context.watch<ActiveUserLoginCubit>().state;
    final localAccounts = context.watch<LocalAccountsCubit>().state;

    return SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: scale.primaryScale.activeElementBackground),
                child:
                    buildWithLogin(context, localAccounts, activeUserLogin))));
  }
}
