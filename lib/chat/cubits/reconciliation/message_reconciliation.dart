import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../proto/proto.dart' as proto;
import 'author_input_queue.dart';
import 'author_input_source.dart';
import 'output_position.dart';

class MessageReconciliation {
  MessageReconciliation(
      {required TableDBArrayProtobufCubit<proto.ReconciledMessage> output,
      required void Function(Object, StackTrace?) onError})
      : _outputCubit = output,
        _onError = onError;

  ////////////////////////////////////////////////////////////////////////////

  void reconcileMessages(
      TypedKey author,
      DHTLogStateData<proto.Message> inputMessagesCubitState,
      DHTLogCubit<proto.Message> inputMessagesCubit) {
    if (inputMessagesCubitState.window.isEmpty) {
      return;
    }

    _inputSources[author] = AuthorInputSource.fromCubit(
        cubitState: inputMessagesCubitState, cubit: inputMessagesCubit);

    singleFuture(this, onError: _onError, () async {
      // Take entire list of input sources we have currently and process them
      final inputSources = _inputSources;
      _inputSources = {};

      final inputFuts = <Future<AuthorInputQueue?>>[];
      for (final kv in inputSources.entries) {
        final author = kv.key;
        final inputSource = kv.value;
        inputFuts
            .add(_enqueueAuthorInput(author: author, inputSource: inputSource));
      }
      final inputQueues = await inputFuts.wait;

      // Make this safe to cast by removing inputs that were rejected or empty
      inputQueues.removeNulls();

      // Process all input queues together
      await _outputCubit
          .operate((reconciledArray) async => _reconcileInputQueues(
                reconciledArray: reconciledArray,
                inputQueues: inputQueues.cast<AuthorInputQueue>(),
              ));
    });
  }

  ////////////////////////////////////////////////////////////////////////////

  // Set up a single author's message reconciliation
  Future<AuthorInputQueue?> _enqueueAuthorInput(
      {required TypedKey author,
      required AuthorInputSource inputSource}) async {
    // Get the position of our most recent reconciled message from this author
    final outputPosition = await _findLastOutputPosition(author: author);

    // Find oldest message we have not yet reconciled
    final inputQueue = await AuthorInputQueue.create(
      author: author,
      inputSource: inputSource,
      outputPosition: outputPosition,
      onError: _onError,
    );
    return inputQueue;
  }

  // Get the position of our most recent reconciled message from this author
  // XXX: For a group chat, this should find when the author
  // was added to the membership so we don't just go back in time forever
  Future<OutputPosition?> _findLastOutputPosition(
          {required TypedKey author}) async =>
      _outputCubit.operate((arr) async {
        var pos = arr.length - 1;
        while (pos >= 0) {
          final message = await arr.get(pos);
          if (message.content.author.toVeilid() == author) {
            return OutputPosition(message, pos);
          }
          pos--;
        }
        return null;
      });

  // Process a list of author input queues and insert their messages
  // into the output array, performing validation steps along the way
  Future<void> _reconcileInputQueues({
    required TableDBArrayProtobuf<proto.ReconciledMessage> reconciledArray,
    required List<AuthorInputQueue> inputQueues,
  }) async {
    // Ensure queues all have something to do
    inputQueues.removeWhere((q) => q.isDone);
    if (inputQueues.isEmpty) {
      return;
    }

    // Sort queues from earliest to latest and then by author
    // to ensure a deterministic insert order
    inputQueues.sort((a, b) {
      final acmp = a.outputPosition?.pos ?? -1;
      final bcmp = b.outputPosition?.pos ?? -1;
      if (acmp == bcmp) {
        return a.author.toString().compareTo(b.author.toString());
      }
      return acmp.compareTo(bcmp);
    });

    // Start at the earliest position we know about in all the queues
    var currentOutputPosition = inputQueues.first.outputPosition;

    final toInsert =
        SortedList<proto.Message>(proto.MessageExt.compareTimestamp);

    while (inputQueues.isNotEmpty) {
      // Get up to '_maxReconcileChunk' of the items from the queues
      // that we can insert at this location

      bool added;
      do {
        added = false;
        var someQueueEmpty = false;
        for (final inputQueue in inputQueues) {
          final inputCurrent = inputQueue.current!;
          if (currentOutputPosition == null ||
              inputCurrent.timestamp <
                  currentOutputPosition.message.content.timestamp) {
            toInsert.add(inputCurrent);
            added = true;

            // Advance this queue
            if (!await inputQueue.consume()) {
              // Queue is empty now, run a queue purge
              someQueueEmpty = true;
            }
          }
        }
        // Remove empty queues now that we're done iterating
        if (someQueueEmpty) {
          inputQueues.removeWhere((q) => q.isDone);
        }

        if (toInsert.length >= _maxReconcileChunk) {
          break;
        }
      } while (added);

      // Perform insertions in bulk
      if (toInsert.isNotEmpty) {
        final reconciledTime = Veilid.instance.now().toInt64();

        // Add reconciled timestamps
        final reconciledInserts = toInsert
            .map((message) => proto.ReconciledMessage()
              ..reconciledTime = reconciledTime
              ..content = message)
            .toList();

        await reconciledArray.insertAll(
            currentOutputPosition?.pos ?? reconciledArray.length,
            reconciledInserts);

        toInsert.clear();
      } else {
        // If there's nothing to insert at this position move to the next one
        final nextOutputPos = (currentOutputPosition != null)
            ? currentOutputPosition.pos + 1
            : reconciledArray.length;
        if (nextOutputPos == reconciledArray.length) {
          currentOutputPosition = null;
        } else {
          currentOutputPosition = OutputPosition(
              await reconciledArray.get(nextOutputPos), nextOutputPos);
        }
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////

  Map<TypedKey, AuthorInputSource> _inputSources = {};
  final TableDBArrayProtobufCubit<proto.ReconciledMessage> _outputCubit;
  final void Function(Object, StackTrace?) _onError;

  static const int _maxReconcileChunk = 65536;
}
