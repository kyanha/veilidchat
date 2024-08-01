import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../account_manager/account_manager.dart';
import '../../layout/layout.dart';
import '../../proto/proto.dart' as proto;
import '../../settings/settings.dart';
import '../../tools/tools.dart';
import '../../veilid_processor/views/developer.dart';
import '../views/router_shell.dart';

part 'router_cubit.freezed.dart';
part 'router_cubit.g.dart';

final _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavKey');

@freezed
class RouterState with _$RouterState {
  const factory RouterState({
    required bool hasAnyAccount,
  }) = _RouterState;

  factory RouterState.fromJson(dynamic json) =>
      _$RouterStateFromJson(json as Map<String, dynamic>);
}

class RouterCubit extends Cubit<RouterState> {
  RouterCubit(AccountRepository accountRepository)
      : super(RouterState(
          hasAnyAccount: accountRepository.getLocalAccounts().isNotEmpty,
        )) {
    // Subscribe to repository streams
    _accountRepositorySubscription = accountRepository.stream.listen((event) {
      switch (event) {
        case AccountRepositoryChange.localAccounts:
          emit(state.copyWith(
              hasAnyAccount: accountRepository.getLocalAccounts().isNotEmpty));
          break;
        case AccountRepositoryChange.userLogins:
        case AccountRepositoryChange.activeLocalAccount:
          break;
      }
    });
  }

  @override
  Future<void> close() async {
    await _accountRepositorySubscription.cancel();
    await super.close();
  }

  /// Our application routes
  List<RouteBase> get routes => [
        ShellRoute(
            builder: (context, state, child) => RouterShell(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/edit_account',
                builder: (context, state) {
                  final extra = state.extra! as List<Object?>;
                  return EditAccountPage(
                    superIdentityRecordKey: extra[0]! as TypedKey,
                    existingAccount: extra[1]! as proto.Account,
                    accountRecord: extra[2]! as OwnedDHTRecordPointer,
                  );
                },
              ),
              GoRoute(
                path: '/new_account',
                builder: (context, state) => const NewAccountPage(),
              ),
              GoRoute(
                  path: '/new_account/recovery_key',
                  builder: (context, state) {
                    final extra = state.extra! as List<Object?>;

                    return ShowRecoveryKeyPage(
                        writableSuperIdentity:
                            extra[0]! as WritableSuperIdentity,
                        name: extra[1]! as String);
                  }),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: '/developer',
                builder: (context, state) => const DeveloperPage(),
              )
            ])
      ];

  /// Redirects when our state changes
  String? redirect(BuildContext context, GoRouterState goRouterState) {
    // No matter where we are, if there's not

    switch (goRouterState.matchedLocation) {
      case '/':
        if (!state.hasAnyAccount) {
          return '/new_account';
        }
        return null;
      case '/new_account':
        return null;
      case '/new_account/recovery_key':
        return null;
      case '/settings':
        return null;
      case '/developer':
        return null;
      default:
        return state.hasAnyAccount ? null : '/new_account';
    }
  }

  /// Make a GoRouter instance that uses this cubit
  GoRouter router() {
    final r = _router;
    if (r != null) {
      return r;
    }
    return _router = GoRouter(
      navigatorKey: _rootNavKey,
      refreshListenable: StreamListenable(stream.startWith(state).distinct()),
      debugLogDiagnostics: kDebugMode,
      initialLocation: '/',
      routes: routes,
      redirect: redirect,
    );
  }

  ////////////////

  late final StreamSubscription<AccountRepositoryChange>
      _accountRepositorySubscription;
  GoRouter? _router;
}
