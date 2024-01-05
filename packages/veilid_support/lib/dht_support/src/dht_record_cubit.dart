import 'package:bloc/bloc.dart';

import '../../veilid_support.dart';

class DhtRecordCubit<T> extends Cubit<AsyncValue<T>> {
  DhtRecordCubit({
    required DHTRecord record,
    required Future<T?> Function(DHTRecord, VeilidUpdateValueChange)
        stateFunction,
    List<ValueSubkeyRange> watchSubkeys = const [],
  })  : _record = record,
        super(const AsyncValue.loading()) {
    Future.delayed(Duration.zero, () async {
      await record.watch((update) async {
        try {
          final newState = await stateFunction(record, update);
          if (newState != null) {
            emit(AsyncValue.data(newState));
          }
        } on Exception catch (e) {
          emit(AsyncValue.error(e));
        }
      }, subkeys: watchSubkeys);
    });
  }

  @override
  Future<void> close() async {
    await _record.cancelWatch();
    await super.close();
  }

  DHTRecord _record;
}

class SingleDHTRecordCubit<T> extends DhtRecordCubit<T> {
  SingleDHTRecordCubit(
      {required super.record,
      required T? Function(List<int> data) decodeState,
      int singleSubkey = 0})
      : super(
            stateFunction: (record, update) async {
              //
              if (update.subkeys.isNotEmpty) {
                final newState = decodeState(update.valueData.data);
                return newState;
              }
              return null;
            },
            watchSubkeys: [
              ValueSubkeyRange(low: singleSubkey, high: singleSubkey)
            ]);
}
