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
    // Use a singlefuture here to ensure we get dont lose any updates
    // If the input stream gives us an update while we are
    // still processing the last update, the most recent input state will
    // be saved and processed eventually.
    singleFuture(this, () async {
      var newState = newInputState;
      var done = false;
      while (!done) {
        // Emit the transformed state
        try {
          if (newState is AsyncLoading) {
            return AsyncValue<T>.loading();
          }
          if (newState is AsyncError) {
            final newStateError = newState as AsyncError<S>;
            return AsyncValue<T>.error(
                newStateError.error, newStateError.stackTrace);
          }
          final transformedState = await transform(newState.data!.value);
          emit(transformedState);
        } on Exception catch (e, st) {
          emit(AsyncValue.error(e, st));
        }
        // See if there's another state change to process
        final next = _nextInputState;
        _nextInputState = null;
        if (next != null) {
          newState = next;
        } else {
          done = true;
        }
      }
    }, onBusy: () {
      // Keep this state until we process again
      _nextInputState = newInputState;
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await input.close();
    await super.close();
  }

  Cubit<AsyncValue<S>> input;
  AsyncValue<S>? _nextInputState;
  Future<AsyncValue<T>> Function(S) transform;
  late final StreamSubscription<AsyncValue<S>> _subscription;
}
