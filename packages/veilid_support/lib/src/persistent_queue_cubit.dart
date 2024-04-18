import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mutex/mutex.dart';
import 'package:protobuf/protobuf.dart';

import 'table_db.dart';

class PersistentQueueCubit<T extends GeneratedMessage>
    extends Cubit<AsyncValue<IList<T>>> with TableDBBackedFromBuffer<IList<T>> {
  //
  PersistentQueueCubit(
      {required String table,
      required String key,
      required T Function(Uint8List) fromBuffer,
      bool deleteOnClose = true})
      : _table = table,
        _key = key,
        _fromBuffer = fromBuffer,
        _deleteOnClose = deleteOnClose,
        super(const AsyncValue.loading()) {
    _initWait.add(_build);
    unawaited(Future.delayed(Duration.zero, () async {
      await for (final elem in _syncAddController.stream) {
        await addAll(elem);
      }
    }));
  }

  @override
  Future<void> close() async {
    // Ensure the init finished
    await _initWait();

    // Close the sync add stream
    await _syncAddController.close();

    // Wait for any setStates to finish
    await _stateMutex.acquire();

    // Clean up table if desired
    if (_deleteOnClose) {
      await delete();
    }

    await super.close();
  }

  Future<void> _build() async {
    await _stateMutex.protect(() async {
      try {
        emit(AsyncValue.data(await load() ?? await store(IList<T>.empty())));
      } on Exception catch (e, stackTrace) {
        emit(AsyncValue.error(e, stackTrace));
      }
    });
  }

  Future<void> _setStateInner(IList<T> newState) async {
    emit(AsyncValue.data(await store(newState)));
  }

  Future<void> add(T item) async {
    await _initWait();
    await _stateMutex.protect(() async {
      final queue = state.asData!.value.add(item);
      await _setStateInner(queue);
    });
  }

  Future<void> addAll(IList<T> items) async {
    await _initWait();
    await _stateMutex.protect(() async {
      var queue = state.asData!.value;
      for (final item in items) {
        queue = queue.add(item);
      }
      await _setStateInner(queue);
    });
  }

  void addSync(T item) {
    _syncAddController.sink.add([item].toIList());
  }

  void addAllSync(IList<T> items) {
    _syncAddController.sink.add(items.toIList());
  }

  Future<bool> get isEmpty async {
    await _initWait();
    return state.asData!.value.isEmpty;
  }

  Future<bool> get isNotEmpty async {
    await _initWait();
    return state.asData!.value.isNotEmpty;
  }

  Future<int> get length async {
    await _initWait();
    return state.asData!.value.length;
  }

  // Future<T?> pop() async {
  //   await _initWait();
  //   return _processingMutex.protect(() async => _stateMutex.protect(() async {
  //         final removedItem = Output<T>();
  //         final queue = state.asData!.value.removeAt(0, removedItem);
  //         await _setStateInner(queue);
  //         return removedItem.value;
  //       }));
  // }

  // Future<IList<T>> popAll() async {
  //   await _initWait();
  //   return _processingMutex.protect(() async => _stateMutex.protect(() async {
  //         final queue = state.asData!.value;
  //         await _setStateInner(IList<T>.empty);
  //         return queue;
  //       }));
  // }

  Future<R> process<R>(Future<R> Function(IList<T>) closure,
      {int? count}) async {
    await _initWait();
    // Only one processor at a time
    return _processingMutex.protect(() async {
      // Take 'count' items from the front of the list
      final toProcess = await _stateMutex.protect(() async {
        final queue = state.asData!.value;
        final processCount = (count ?? queue.length).clamp(0, queue.length);
        return queue.take(processCount).toIList();
      });

      // Run the processing closure
      final processCount = toProcess.length;
      final out = await closure(toProcess);

      // If there was nothing to process just return
      if (toProcess.isEmpty) {
        return out;
      }

      // If there was no exception, remove the processed items
      return _stateMutex.protect(() async {
        // Get the queue from the state again as items could
        // have been added during processing
        final queue = state.asData!.value;
        final newQueue = queue.skip(processCount).toIList();
        await _setStateInner(newQueue);
        return out;
      });
    });
  }

  // TableDBBacked
  @override
  String tableKeyName() => _key;

  @override
  String tableName() => _table;

  @override
  IList<T> valueFromBuffer(Uint8List bytes) {
    final reader = CodedBufferReader(bytes);
    var out = IList<T>();
    while (!reader.isAtEnd()) {
      out = out.add(_fromBuffer(reader.readBytesAsView()));
    }
    return out;
  }

  @override
  Uint8List valueToBuffer(IList<T> val) {
    final writer = CodedBufferWriter();
    for (final elem in val) {
      writer.writeRawBytes(elem.writeToBuffer());
    }
    return writer.toBuffer();
  }

  final String _table;
  final String _key;
  final T Function(Uint8List) _fromBuffer;
  final bool _deleteOnClose;
  final WaitSet _initWait = WaitSet();
  final Mutex _stateMutex = Mutex();
  final Mutex _processingMutex = Mutex();
  final StreamController<IList<T>> _syncAddController = StreamController();
}
