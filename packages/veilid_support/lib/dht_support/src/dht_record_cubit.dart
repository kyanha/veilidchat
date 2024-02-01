import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';

import '../../veilid_support.dart';

class DHTRecordCubit<T> extends Cubit<AsyncValue<T>> {
  DHTRecordCubit({
    required Future<DHTRecord> Function() open,
    required Future<T?> Function(DHTRecord) initialStateFunction,
    required Future<T?> Function(DHTRecord, List<ValueSubkeyRange>, ValueData)
        stateFunction,
  })  : _wantsCloseRecord = false,
        super(const AsyncValue.loading()) {
    Future.delayed(Duration.zero, () async {
      // Do record open/create
      _record = await open();
      _wantsCloseRecord = true;
      await _init(initialStateFunction, stateFunction);
    });
  }

  DHTRecordCubit.value({
    required DHTRecord record,
    required Future<T?> Function(DHTRecord) initialStateFunction,
    required Future<T?> Function(DHTRecord, List<ValueSubkeyRange>, ValueData)
        stateFunction,
  })  : _record = record,
        _wantsCloseRecord = false,
        super(const AsyncValue.loading()) {
    Future.delayed(Duration.zero, () async {
      await _init(initialStateFunction, stateFunction);
    });
  }

  Future<void> _init(
    Future<T?> Function(DHTRecord) initialStateFunction,
    Future<T?> Function(DHTRecord, List<ValueSubkeyRange>, ValueData)
        stateFunction,
  ) async {
    // Make initial state update
    try {
      final initialState = await initialStateFunction(_record);
      if (initialState != null) {
        emit(AsyncValue.data(initialState));
      }
    } on Exception catch (e) {
      emit(AsyncValue.error(e));
    }

    _subscription = await _record.listen((update) async {
      try {
        final newState =
            await stateFunction(_record, update.subkeys, update.valueData);
        if (newState != null) {
          emit(AsyncValue.data(newState));
        }
      } on Exception catch (e) {
        emit(AsyncValue.error(e));
      }
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _record.close();
      _wantsCloseRecord = false;
    }
    await super.close();
  }

  StreamSubscription<VeilidUpdateValueChange>? _subscription;
  late DHTRecord _record;
  bool _wantsCloseRecord;
}

// Cubit that watches the default subkey value of a dhtrecord
class DefaultDHTRecordCubit<T> extends DHTRecordCubit<T> {
  DefaultDHTRecordCubit({
    required super.open,
    required T Function(List<int> data) decodeState,
  }) : super(
            initialStateFunction: _makeInitialStateFunction(decodeState),
            stateFunction: _makeStateFunction(decodeState));

  DefaultDHTRecordCubit.value({
    required super.record,
    required T Function(List<int> data) decodeState,
  }) : super.value(
          initialStateFunction: _makeInitialStateFunction(decodeState),
          stateFunction: _makeStateFunction(decodeState),
        );

  static Future<T?> Function(DHTRecord) _makeInitialStateFunction<T>(
          T Function(List<int> data) decodeState) =>
      (record) async {
        final initialData = await record.get();
        if (initialData == null) {
          return null;
        }
        return decodeState(initialData);
      };

  static Future<T?> Function(DHTRecord, List<ValueSubkeyRange>, ValueData)
      _makeStateFunction<T>(T Function(List<int> data) decodeState) =>
          (record, subkeys, valueData) async {
            final defaultSubkey = record.subkeyOrDefault(-1);
            if (subkeys.containsSubkey(defaultSubkey)) {
              final Uint8List data;
              final firstSubkey = subkeys.firstOrNull!.low;
              if (firstSubkey != defaultSubkey) {
                final maybeData = await record.get(forceRefresh: true);
                if (maybeData == null) {
                  return null;
                }
                data = maybeData;
              } else {
                data = valueData.data;
              }
              final newState = decodeState(data);
              return newState;
            }
            return null;
          };

  xxx add refresh/get mechanism to DHTRecordCubit and here too, then propagage to conversation_cubit
  xxx should just be a 'get' like in dht_short_array_cubit
}
