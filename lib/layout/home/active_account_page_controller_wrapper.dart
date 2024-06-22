import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';

class ActiveAccountPageControllerWrapper {
  ActiveAccountPageControllerWrapper(Locator locator, int initialPage) {
    pageController = PageController(initialPage: initialPage, keepPage: false);

    final activeLocalAccountCubit = locator<ActiveLocalAccountCubit>();
    _subscription =
        activeLocalAccountCubit.stream.listen((activeLocalAccountRecordKey) {
      singleFuture(this, () async {
        final localAccounts = locator<LocalAccountsCubit>().state;
        final activeIndex = localAccounts.indexWhere(
            (x) => x.superIdentity.recordKey == activeLocalAccountRecordKey);
        if (pageController.page == activeIndex) {
          return;
        }
        await pageController.animateToPage(activeIndex,
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn);
      });
    });
  }

  void dispose() {
    unawaited(_subscription.cancel());
  }

  late PageController pageController;
  late StreamSubscription<TypedKey?> _subscription;
}
