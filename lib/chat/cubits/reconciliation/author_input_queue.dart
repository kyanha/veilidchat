import 'dart:async';
import 'package:veilid_support/veilid_support.dart';

import '../../../proto/proto.dart' as proto;

import 'author_input_source.dart';
import 'message_integrity.dart';
import 'output_position.dart';

class AuthorInputQueue {
  AuthorInputQueue._({
    required TypedKey author,
    required AuthorInputSource inputSource,
    required OutputPosition? outputPosition,
    required void Function(Object, StackTrace?) onError,
    required MessageIntegrity messageIntegrity,
  })  : _author = author,
        _onError = onError,
        _inputSource = inputSource,
        _outputPosition = outputPosition,
        _lastMessage = outputPosition?.message.content,
        _messageIntegrity = messageIntegrity,
        _currentPosition = inputSource.currentWindow.last;

  static Future<AuthorInputQueue?> create({
    required TypedKey author,
    required AuthorInputSource inputSource,
    required OutputPosition? outputPosition,
    required void Function(Object, StackTrace?) onError,
  }) async {
    final queue = AuthorInputQueue._(
        author: author,
        inputSource: inputSource,
        outputPosition: outputPosition,
        onError: onError,
        messageIntegrity: await MessageIntegrity.create(author: author));
    if (!await queue._findStartOfWork()) {
      return null;
    }
    return queue;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public interface

  // Check if there are no messages left in this queue to reconcile
  bool get isDone => _isDone;

  // Get the current message that needs reconciliation
  proto.Message? get current => _currentMessage;

  // Get the earliest output position to start inserting
  OutputPosition? get outputPosition => _outputPosition;

  // Get the author of this queue
  TypedKey get author => _author;

  // Remove a reconciled message and move to the next message
  // Returns true if there is more work to do
  Future<bool> consume() async {
    if (_isDone) {
      return false;
    }
    while (true) {
      _lastMessage = _currentMessage;

      _currentPosition++;

      // Get more window if we need to
      if (!await _updateWindow()) {
        // Window is not available so this queue can't work right now
        _isDone = true;
        return false;
      }
      final nextMessage = _inputSource.currentWindow
          .elements[_currentPosition - _inputSource.currentWindow.first];

      // Drop the 'offline' elements because we don't reconcile
      // anything until it has been confirmed to be committed to the DHT
      // if (nextMessage.isOffline) {
      //   continue;
      // }

      if (_lastMessage != null) {
        // Ensure the timestamp is not moving backward
        if (nextMessage.value.timestamp < _lastMessage!.timestamp) {
          continue;
        }
      }

      // Verify the id chain for the message
      final matchId = await _messageIntegrity.generateMessageId(_lastMessage);
      if (matchId.compare(nextMessage.value.idBytes) != 0) {
        continue;
      }

      // Verify the signature for the message
      if (!await _messageIntegrity.verifyMessage(nextMessage.value)) {
        continue;
      }

      _currentMessage = nextMessage.value;
      break;
    }
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Internal implementation

  // Walk backward from the tail of the input queue to find the first
  // message newer than our last reconcicled message from this author
  // Returns false if no work is needed
  Future<bool> _findStartOfWork() async {
    // Iterate windows over the inputSource
    outer:
    while (true) {
      // Iterate through current window backward
      for (var i = _inputSource.currentWindow.elements.length - 1;
          i >= 0 && _currentPosition >= 0;
          i--, _currentPosition--) {
        final elem = _inputSource.currentWindow.elements[i];

        // If we've found an input element that is older than our last
        // reconciled message for this author, then we stop
        if (_lastMessage != null) {
          if (elem.value.timestamp < _lastMessage!.timestamp) {
            break outer;
          }
        }
      }
      // If we're at the beginning of the inputSource then we stop
      if (_currentPosition < 0) {
        break;
      }

      // Get more window if we need to
      if (!await _updateWindow()) {
        // Window is not available or things are empty so this
        // queue can't work right now
        _isDone = true;
        return false;
      }
    }

    // _currentPosition points to either before the input source starts
    // or the position of the previous element. We still need to set the
    // _currentMessage to the previous element so consume() can compare
    // against it if we can.
    if (_currentPosition >= 0) {
      _currentMessage = _inputSource.currentWindow
          .elements[_currentPosition - _inputSource.currentWindow.first].value;
    }

    // After this consume(), the currentPosition and _currentMessage should
    // be equal to the first message to process and the current window to
    // process should not be empty
    return consume();
  }

  // Slide the window toward the current position and load the batch around it
  Future<bool> _updateWindow() async {
    // Check if we are still in the window
    if (_currentPosition >= _inputSource.currentWindow.first &&
        _currentPosition <= _inputSource.currentWindow.last) {
      return true;
    }

    // Get another input batch futher back
    final avOk =
        await _inputSource.updateWindow(_currentPosition, _maxWindowLength);

    final asErr = avOk.asError;
    if (asErr != null) {
      _onError(asErr.error, asErr.stackTrace);
      return false;
    }
    final asLoading = avOk.asLoading;
    if (asLoading != null) {
      // xxx: no need to block the cubit here for this
      // xxx: might want to switch to a 'busy' state though
      // xxx: to let the messages view show a spinner at the bottom
      // xxx: while we reconcile...
      // emit(const AsyncValue.loading());
      return false;
    }
    return avOk.asData!.value;
  }

  ////////////////////////////////////////////////////////////////////////////

  final TypedKey _author;
  final AuthorInputSource _inputSource;
  final OutputPosition? _outputPosition;
  final void Function(Object, StackTrace?) _onError;
  final MessageIntegrity _messageIntegrity;

  // The last message we've consumed
  proto.Message? _lastMessage;
  // The current position in the input log that we are looking at
  int _currentPosition;
  // The current message we're looking at
  proto.Message? _currentMessage;
  // If we have reached the end
  bool _isDone = false;

  // Desired maximum window length
  static const int _maxWindowLength = 256;
}
