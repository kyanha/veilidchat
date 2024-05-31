import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../proto/proto.dart' as proto;

import 'author_input_source.dart';
import 'output_position.dart';

class AuthorInputQueue {
  AuthorInputQueue({
    required this.author,
    required this.inputSource,
    required this.lastOutputPosition,
    required this.onError,
  }):
    assert(inputSource.messages.count>0, 'no input source window length'),
    assert(inputSource.messages.elements.isNotEmpty, 'no input source elements'),
    assert(inputSource.messages.tail >= inputSource.messages.elements.length, 'tail is before initial messages end'),
    assert(inputSource.messages.tail > 0, 'tail is not greater than zero'),
    currentPosition = inputSource.messages.tail,
    currentWindow = inputSource.messages.elements,
    windowLength = inputSource.messages.count,
    windowFirst = inputSource.messages.tail - inputSource.messages.elements.length,
    windowLast = inputSource.messages.tail - 1;

  ////////////////////////////////////////////////////////////////////////////

  bool get isEmpty => toReconcile.isEmpty;

  proto.Message? get current => toReconcile.firstOrNull;

  bool consume() {
    toReconcile.removeFirst();
    return toReconcile.isNotEmpty;
  }

  Future<bool> prepareInputQueue() async {
    // Go through batches of the input dhtlog starting with
    // the current cubit state which is at the tail of the log
    // Find the last reconciled message for this author

    outer:
    while (true) {
      for (var rn = currentWindow.length;
          rn >= 0 && currentPosition >= 0;
          rn--, currentPosition--) {
        final elem = currentWindow[rn];

        // If we've found an input element that is older than our last
        // reconciled message for this author, then we stop
        if (lastOutputPosition != null) {
          if (elem.value.timestamp < lastOutputPosition!.message.timestamp) {
            break outer;
          }
        }

        // Drop the 'offline' elements because we don't reconcile
        // anything until it has been confirmed to be committed to the DHT
        if (elem.isOffline) {
          continue;
        }

        // Add to head of reconciliation queue
        toReconcile.addFirst(elem.value);
        if (toReconcile.length > _maxQueueChunk) {
          toReconcile.removeLast();
        }
      }
      if (currentPosition < 0) {
        break;
      }

    xxx update window here and make this and other methods work
    }
    return true;
  }

  // Slide the window toward the current position and load the batch around it
  Future<bool> updateWindow() async {

      // Check if we are still in the window
      if (currentPosition>=windowFirst && currentPosition <= windowLast) {
        return true;
      }

      // Get the length of the cubit
      final inputLength = await inputSource.cubit.operate((r) async => r.length);

      // If not, slide the window
      if (currentPosition<windowFirst) {
        // Slide it backward, current position is now windowLast
        windowFirst = max((currentPosition - windowLength) + 1, 0);
        windowLast = currentPosition;
      } else {
        // Slide it forward, current position is now windowFirst
        windowFirst = currentPosition;
        windowLast = min((currentPosition + windowLength) - 1, inputLength - 1);
      }

      // Get another input batch futher back
      final nextWindow =
          await inputSource.cubit.loadElements(windowLast + 1, (windowLast + 1) - windowFirst);
      final asErr = nextWindow.asError;
      if (asErr != null) {
        onError(asErr.error, asErr.stackTrace);
        return false;
      }
      final asLoading = nextWindow.asLoading;
      if (asLoading != null) {
        // xxx: no need to block the cubit here for this
        // xxx: might want to switch to a 'busy' state though
        // xxx: to let the messages view show a spinner at the bottom
        // xxx: while we reconcile...
        // emit(const AsyncValue.loading());
        return false;
      }
      currentWindow = nextWindow.asData!.value;
      return true;
  }

  ////////////////////////////////////////////////////////////////////////////

  final TypedKey author;
  final ListQueue<proto.Message> toReconcile = ListQueue<proto.Message>();
  final AuthorInputSource inputSource;
  final OutputPosition? lastOutputPosition;
  final void Function(Object, StackTrace?) onError;

  // The current position in the input log that we are looking at
  int currentPosition;
  // The current input window elements
  IList<DHTLogElementState<proto.Message>> currentWindow;
  // The first position of the sliding input window
  int windowFirst;
  // The last position of the sliding input window
  int windowLast;
  // Desired maximum window length
  int windowLength;

  static const int _maxQueueChunk = 256;
}
