import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';

class AsyncTransformerCubit<T, S> extends Cubit<AsyncValue<T>> {
  AsyncTransformerCubit(this.input, {required this.transform})
      : super(const AsyncValue.loading()) {
    _asyncTransform(input.state);
    _subscription = input.stream.listen(_asyncTransform);
  }
  void _asyncTransform(AsyncValue<S> newInputState) {
    _singleStateProcessor.updateState(newInputState, closure: (newState) async {
      // Emit the transformed state
      try {
        if (newState is AsyncLoading<S>) {
          emit(const AsyncValue.loading());
        } else if (newState is AsyncError<S>) {
          emit(AsyncValue.error(newState.error, newState.stackTrace));
        } else {
          final transformedState = await transform(newState.data!.value);
          emit(transformedState);
        }
      } on Exception catch (e, st) {
        emit(AsyncValue.error(e, st));
      }
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await input.close();
    await super.close();
  }

  Cubit<AsyncValue<S>> input;
  final SingleStateProcessor<AsyncValue<S>> _singleStateProcessor =
      SingleStateProcessor();
  Future<AsyncValue<T>> Function(S) transform;
  late final StreamSubscription<AsyncValue<S>> _subscription;
}
