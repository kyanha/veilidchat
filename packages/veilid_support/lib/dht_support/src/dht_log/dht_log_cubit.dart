import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

@immutable
class DHTLogStateData<T> extends Equatable {
  const DHTLogStateData(
      {required this.elements,
      required this.tail,
      required this.count,
      required this.follow});
  // The view of the elements in the dhtlog
  // Span is from [tail-length, tail)
  final IList<OnlineElementState<T>> elements;
  // One past the end of the last element
  final int tail;
  // The total number of elements to try to keep in 'elements'
  final int count;
  // If we should have the tail following the log
  final bool follow;

  @override
  List<Object?> get props => [elements, tail, count, follow];
}

typedef DHTLogState<T> = AsyncValue<DHTLogStateData<T>>;
typedef DHTLogBusyState<T> = BlocBusyState<DHTLogState<T>>;

class DHTLogCubit<T> extends Cubit<DHTLogBusyState<T>>
    with BlocBusyWrapper<DHTLogState<T>> {
  DHTLogCubit({
    required Future<DHTLog> Function() open,
    required T Function(List<int> data) decodeElement,
  })  : _decodeElement = decodeElement,
        super(const BlocBusyState(AsyncValue.loading())) {
    _initWait.add(() async {
      // Open DHT record
      _log = await open();
      _wantsCloseRecord = true;

      // Make initial state update
      await _refreshNoWait();
      _subscription = await _log.listen(_update);
    });
  }

  // Set the tail position of the log for pagination.
  // If tail is 0, the end of the log is used.
  // If tail is negative, the position is subtracted from the current log
  // length.
  // If tail is positive, the position is absolute from the head of the log
  // If follow is enabled, the tail offset will update when the log changes
  Future<void> setWindow(
      {int? tail, int? count, bool? follow, bool forceRefresh = false}) async {
    await _initWait();
    if (tail != null) {
      _tail = tail;
    }
    if (count != null) {
      _count = count;
    }
    if (follow != null) {
      _follow = follow;
    }
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> refresh({bool forceRefresh = false}) async {
    await _initWait();
    await _refreshNoWait(forceRefresh: forceRefresh);
  }

  Future<void> _refreshNoWait({bool forceRefresh = false}) async =>
      busy((emit) async => _refreshInner(emit, forceRefresh: forceRefresh));

  Future<void> _refreshInner(void Function(AsyncValue<DHTLogStateData<T>>) emit,
      {bool forceRefresh = false}) async {
    final avElements = await operate(
        (reader) => loadElementsFromReader(reader, _tail, _count));
    final err = avElements.asError;
    if (err != null) {
      emit(AsyncValue.error(err.error, err.stackTrace));
      return;
    }
    final loading = avElements.asLoading;
    if (loading != null) {
      emit(const AsyncValue.loading());
      return;
    }
    final elements = avElements.asData!.value;
    emit(AsyncValue.data(DHTLogStateData(
        elements: elements, tail: _tail, count: _count, follow: _follow)));
  }

  // Tail is one past the last element to load
  Future<AsyncValue<IList<OnlineElementState<T>>>> loadElementsFromReader(
      DHTLogReadOperations reader, int tail, int count,
      {bool forceRefresh = false}) async {
    try {
      final length = reader.length;
      final end = ((tail - 1) % length) + 1;
      final start = (count < end) ? end - count : 0;

      final offlinePositions = await reader.getOfflinePositions();
      final allItems = (await reader.getRange(start,
              length: end - start, forceRefresh: forceRefresh))
          ?.indexed
          .map((x) => OnlineElementState(
              value: _decodeElement(x.$2),
              isOffline: offlinePositions.contains(x.$1)))
          .toIList();
      if (allItems == null) {
        return const AsyncValue.loading();
      }
      return AsyncValue.data(allItems);
    } on Exception catch (e, st) {
      return AsyncValue.error(e, st);
    }
  }

  void _update(DHTLogUpdate upd) {
    // Run at most one background update process
    // Because this is async, we could get an update while we're
    // still processing the last one. Only called after init future has run
    // so we dont have to wait for that here.

    // Accumulate head and tail deltas
    _headDelta += upd.headDelta;
    _tailDelta += upd.tailDelta;

    _sspUpdate.busyUpdate<T, DHTLogState<T>>(busy, (emit) async {
      // apply follow
      if (_follow) {
        if (_tail <= 0) {
          // Negative tail is already following tail changes
        } else {
          // Positive tail is measured from the head, so apply deltas
          _tail = (_tail + _tailDelta - _headDelta) % upd.length;
        }
      } else {
        if (_tail <= 0) {
          // Negative tail is following tail changes so apply deltas
          var posTail = _tail + upd.length;
          posTail = (posTail + _tailDelta - _headDelta) % upd.length;
          _tail = posTail - upd.length;
        } else {
          // Positive tail is measured from head so not following tail
        }
      }
      _headDelta = 0;
      _tailDelta = 0;

      await _refreshInner(emit);
    });
  }

  @override
  Future<void> close() async {
    await _initWait();
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _log.close();
    }
    await super.close();
  }

  Future<R> operate<R>(Future<R> Function(DHTLogReadOperations) closure) async {
    await _initWait();
    return _log.operate(closure);
  }

  Future<R> operateAppend<R>(
      Future<R> Function(DHTLogWriteOperations) closure) async {
    await _initWait();
    return _log.operateAppend(closure);
  }

  Future<void> operateAppendEventual(
      Future<bool> Function(DHTLogWriteOperations) closure,
      {Duration? timeout}) async {
    await _initWait();
    return _log.operateAppendEventual(closure, timeout: timeout);
  }

  final WaitSet<void> _initWait = WaitSet();
  late final DHTLog _log;
  final T Function(List<int> data) _decodeElement;
  StreamSubscription<void>? _subscription;
  bool _wantsCloseRecord = false;
  final _sspUpdate = SingleStatelessProcessor();

  // Accumulated deltas since last update
  var _headDelta = 0;
  var _tailDelta = 0;

  // Cubit window into the DHTLog
  var _tail = 0;
  var _count = DHTShortArray.maxElements;
  var _follow = true;
}
