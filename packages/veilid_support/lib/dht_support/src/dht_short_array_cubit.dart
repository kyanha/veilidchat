import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../veilid_support.dart';

class DHTShortArrayCubit<T> extends Cubit<AsyncValue<IList<T>>> {
  DHTShortArrayCubit({
    required Future<DHTShortArray> Function() open,
    required T Function(List<int> data) decodeElement,
  })  : _decodeElement = decodeElement,
        _wantsUpdate = false,
        _isUpdating = false,
        _wantsCloseRecord = false,
        super(const AsyncValue.loading()) {
    Future.delayed(Duration.zero, () async {
      // Open DHT record
      _shortArray = await open();
      _wantsCloseRecord = true;

      // Make initial state update
      _update();
      _subscription = await _shortArray.listen(_update);
    });
  }

  DHTShortArrayCubit.value({
    required DHTShortArray shortArray,
    required T Function(List<int> data) decodeElement,
  })  : _shortArray = shortArray,
        _decodeElement = decodeElement,
        _wantsUpdate = false,
        _isUpdating = false,
        _wantsCloseRecord = false,
        super(const AsyncValue.loading()) {
    // Make initial state update
    _update();
    Future.delayed(Duration.zero, () async {
      _subscription = await shortArray.listen(_update);
    });
  }

  Future<void> refresh({bool forceRefresh = false}) async {
    var out = IList<T>();
    // xxx could be parallelized but we need to watch out for rate limits
    for (var i = 0; i < _shortArray.length; i++) {
      final cir = await _shortArray.getItem(i, forceRefresh: forceRefresh);
      if (cir == null) {
        throw Exception('Failed to get short array element');
      }
      out = out.add(_decodeElement(cir));
    }
    emit(AsyncValue.data(out));
  }

  void _update() {
    // Run at most one background update process
    _wantsUpdate = true;
    if (_isUpdating) {
      return;
    }
    _isUpdating = true;
    Future.delayed(Duration.zero, () async {
      // Keep updating until we don't want to update any more
      // Because this is async, we could get an update while we're
      // still processing the last one
      do {
        _wantsUpdate = false;
        try {
          final initialState = await _getElements();
          emit(AsyncValue.data(initialState));
        } on Exception catch (e) {
          emit(AsyncValue.error(e));
        }
      } while (_wantsUpdate);

      // Note that this update future has finished
      _isUpdating = false;
    });
  }

  // Get and decode the entire short array
  Future<IList<T>> _getElements() async {
    var out = IList<T>();
    for (var i = 0; i < _shortArray.length; i++) {
      // Get the element bytes (throw if fails, array state is invalid)
      final bytes = (await _shortArray.getItem(i))!;
      // Decode the element
      final elem = _decodeElement(bytes);
      // Append to the output list
      out = out.add(elem);
    }
    return out;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _shortArray.close();
    }
    await super.close();
  }

  DHTShortArray get shortArray => _shortArray;

  late final DHTShortArray _shortArray;
  final T Function(List<int> data) _decodeElement;
  StreamSubscription<void>? _subscription;
  bool _wantsUpdate;
  bool _isUpdating;
  bool _wantsCloseRecord;
}
