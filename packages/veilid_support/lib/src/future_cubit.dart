import 'dart:async';

import 'package:bloc/bloc.dart';

import '../veilid_support.dart';

abstract class FutureCubit<State> extends Cubit<AsyncValue<State>> {
  FutureCubit(Future<State> fut) : super(const AsyncValue.loading()) {
    unawaited(fut.then((value) {
      emit(AsyncValue.data(value));
      // ignore: avoid_types_on_closure_parameters
    }, onError: (Object e, StackTrace stackTrace) {
      emit(AsyncValue.error(e, stackTrace));
    }));
  }
}
