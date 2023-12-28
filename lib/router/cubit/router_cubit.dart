import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

import '../../init.dart';
import '../../local_account_manager/respository/account_repository/account_repository.dart';
import '../../old_to_refactor/pages/chat_only.dart';
import '../../old_to_refactor/pages/developer.dart';
import '../../old_to_refactor/pages/home.dart';
import '../../old_to_refactor/pages/index.dart';
import '../../account_manager/view/new_account_page/new_account_page.dart';
import '../../old_to_refactor/pages/settings.dart';
import '../../tools/tools.dart';

part 'router_cubit.freezed.dart';
part 'router_cubit.g.dart';
part 'router_state.dart';

class RouterCubit extends Cubit<RouterState> {
  RouterCubit(AccountRepository accountRepository)
      : super(const RouterState(
          isInitialized: false,
          hasAnyAccount: false,
          hasActiveChat: false,
        )) {
    // Watch for changes that the router will care about
    Future.delayed(Duration.zero, () async {
      await eventualInitialized.future;
      emit(state.copyWith(isInitialized: true));
    });
    // Subscribe to repository streams
    _accountRepositorySubscription =
        accountRepository.changes().listen((event) {
      switch (event) {
        case AccountRepositoryChange.localAccounts:
          emit(state.copyWith(
              hasAnyAccount: accountRepository.getLocalAccounts().isNotEmpty));
          break;
        case AccountRepositoryChange.userLogins:
        case AccountRepositoryChange.activeUserLogin:
          break;
      }
    });
    _chatListRepositorySubscription = ...
  }

  @override
  Future<void> close() async {
    await _accountRepositorySubscription.cancel();
    await super.close();
  }

  /// Our application routes
  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          builder: (context, state) => const IndexPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: 'chat',
              builder: (context, state) => const ChatOnlyPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/new_account',
          builder: (context, state) => const NewAccountPage(),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/developer',
          builder: (context, state) => const DeveloperPage(),
        )
      ];

  /// Redirects when our state changes
  String? redirect(BuildContext context, GoRouterState goRouterState) {
    // if (state.isLoading || state.hasError) {
    //   return null;
    // }

    // No matter where we are, if there's not
    switch (goRouterState.matchedLocation) {
      case '/':

        // Wait for veilid to be initialized
        if (!eventualVeilid.isCompleted) {
          return null;
        }

        return state.hasAnyAccount ? '/home' : '/new_account';
      case '/new_account':
        return state.hasAnyAccount ? '/home' : null;
      case '/home':
        if (!state.hasAnyAccount) {
          return '/new_account';
        }
        if (responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false)) {
          if (state.hasActiveChat) {
            return '/home/chat';
          }
        }
        return null;
      case '/home/chat':
        if (!state.hasAnyAccount) {
          return '/new_account';
        }
        if (responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false)) {
          if (!state.hasActiveChat) {
            return '/home';
          }
        } else {
          return '/home';
        }
        return null;
      case '/home/settings':
      case '/new_account/settings':
        return null;
      case '/developer':
        return null;
      default:
        return state.hasAnyAccount ? null : '/new_account';
    }
  }

  late final StreamSubscription<AccountRepositoryChange>
      _accountRepositorySubscription;
}
