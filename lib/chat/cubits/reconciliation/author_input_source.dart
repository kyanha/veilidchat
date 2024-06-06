import 'dart:math';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../proto/proto.dart' as proto;

@immutable
class InputWindow {
  const InputWindow(
      {required this.elements, required this.first, required this.last});
  final IList<OnlineElementState<proto.Message>> elements;
  final int first;
  final int last;
}

class AuthorInputSource {
  AuthorInputSource.fromCubit(
      {required DHTLogStateData<proto.Message> cubitState,
      required this.cubit}) {
    _currentWindow = InputWindow(
        elements: cubitState.window,
        first: (cubitState.windowTail - cubitState.window.length) %
            cubitState.length,
        last: (cubitState.windowTail - 1) % cubitState.length);
  }

  ////////////////////////////////////////////////////////////////////////////

  InputWindow get currentWindow => _currentWindow;

  Future<AsyncValue<bool>> updateWindow(
          int currentPosition, int windowLength) async =>
      cubit.operate((reader) async {
        // See if we're beyond the input source
        if (currentPosition < 0 || currentPosition >= reader.length) {
          return const AsyncValue.data(false);
        }

        // Slide the window if we need to
        var first = _currentWindow.first;
        var last = _currentWindow.last;
        if (currentPosition < first) {
          // Slide it backward, current position is now last
          first = max((currentPosition - windowLength) + 1, 0);
          last = currentPosition;
        } else if (currentPosition > last) {
          // Slide it forward, current position is now first
          first = currentPosition;
          last = min((currentPosition + windowLength) - 1, reader.length - 1);
        } else {
          return const AsyncValue.data(true);
        }

        // Get another input batch futher back
        final nextWindow = await cubit.loadElementsFromReader(
            reader, last + 1, (last + 1) - first);
        final asErr = nextWindow.asError;
        if (asErr != null) {
          return AsyncValue.error(asErr.error, asErr.stackTrace);
        }
        final asLoading = nextWindow.asLoading;
        if (asLoading != null) {
          return const AsyncValue.loading();
        }
        _currentWindow = InputWindow(
            elements: nextWindow.asData!.value, first: first, last: last);
        return const AsyncValue.data(true);
      });

  ////////////////////////////////////////////////////////////////////////////
  final DHTLogCubit<proto.Message> cubit;

  late InputWindow _currentWindow;
}
