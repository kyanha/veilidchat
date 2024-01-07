import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';

import '../../veilid_support.dart';

class DhtRecordCubit<T> extends Cubit<AsyncValue<T>> {
  DhtRecordCubit({
    required DHTRecord record,
    required Future<T?> Function(DHTRecord) initialStateFunction,
    required Future<T?> Function(DHTRecord, List<ValueSubkeyRange>, ValueData)
        stateFunction,
  }) : super(const AsyncValue.loading()) {
    Future.delayed(Duration.zero, () async {
      // Make initial state update
      try {
        final initialState = await initialStateFunction(record);
        if (initialState != null) {
          emit(AsyncValue.data(initialState));
        }
      } on Exception catch (e) {
        emit(AsyncValue.error(e));
      }

      _subscription = await record.listen((update) async {
        try {
          final newState =
              await stateFunction(record, update.subkeys, update.valueData);
          if (newState != null) {
            emit(AsyncValue.data(newState));
          }
        } on Exception catch (e) {
          emit(AsyncValue.error(e));
        }
      });
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await super.close();
  }

  StreamSubscription<VeilidUpdateValueChange>? _subscription;
}

// Cubit that watches the default subkey value of a dhtrecord
class DefaultDHTRecordCubit<T> extends DhtRecordCubit<T> {
  DefaultDHTRecordCubit({
    required super.record,
    required T Function(List<int> data) decodeState,
  }) : super(
          initialStateFunction: (record) async {
            final initialData = await record.get();
            if (initialData == null) {
              return null;
            }
            return decodeState(initialData);
          },
          stateFunction: (record, subkeys, valueData) async {
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
          },
        );
}
