import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../account_manager/account_manager.dart';
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import 'home_account_invalid.dart';
import 'home_account_locked.dart';
import 'home_account_missing.dart';
import 'home_account_ready/home_account_ready.dart';
import 'home_no_active.dart';

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

  Widget buildWithLogin(BuildContext context) {
    final activeUserLogin = context.watch<ActiveUserLoginCubit>().state;

    if (activeUserLogin == null) {
      // If no logged in user is active, show the loading panel
      return const HomeNoActive();
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
        return Provider.value(
            value: accountInfo.activeAccountInfo,
            child: BlocProvider(
                create: (context) => AccountRecordCubit(
                    record: accountInfo.activeAccountInfo!.accountRecord),
                child: const HomeAccountReady()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: scale.primaryScale.activeElementBackground),
                child: buildWithLogin(context))));
  }
}
