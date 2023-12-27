import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_transform/stream_transform.dart';

import '../tools/stream_listenable.dart';
import 'cubit/router_cubit.dart';

final _key = GlobalKey<NavigatorState>(debugLabel: 'routerKey');

/// This simple provider caches our GoRouter.
GoRouter router({required RouterCubit routerCubit}) => GoRouter(
      navigatorKey: _key,
      refreshListenable: StreamListenable(
          routerCubit.stream.startWith(routerCubit.state).distinct()),
      debugLogDiagnostics: kDebugMode,
      initialLocation: '/',
      routes: routerCubit.routes,
      redirect: routerCubit.redirect,
    );
