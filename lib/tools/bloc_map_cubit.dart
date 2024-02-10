import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

typedef BlocMapState<K, S> = IMap<K, S>;

class _ItemEntry<S, B> {
  _ItemEntry({required this.bloc, required this.subscription});
  final B bloc;
  final StreamSubscription<S> subscription;
}

abstract class BlocMapCubit<K, S, B extends BlocBase<S>>
    extends Cubit<BlocMapState<K, S>> {
  BlocMapCubit()
      : _entries = {},
        _tagLock = AsyncTagLock(),
        super(IMap<K, S>());

  @override
  Future<void> close() async {
    await _entries.values.map((e) => e.subscription.cancel()).wait;
    await _entries.values.map((e) => e.bloc.close()).wait;
    await super.close();
  }

  Future<void> add(MapEntry<K, B> Function() create) {
    // Create new element
    final newElement = create();
    final key = newElement.key;
    final bloc = newElement.value;

    return _tagLock.protect(key, closure: () async {
      // Remove entry with the same key if it exists
      await _internalRemove(key);

      // Add entry with this key
      _entries[key] = _ItemEntry(
          bloc: bloc,
          subscription: bloc.stream.listen((data) {
            // Add sub-cubit's state to the map state
            emit(state.add(key, data));
          }));

      emit(state.add(key, bloc.state));
    });
  }

  Future<void> _internalRemove(K key) async {
    final sub = _entries.remove(key);
    if (sub != null) {
      await sub.subscription.cancel();
      await sub.bloc.close();
    }
  }

  Future<void> remove(K key) => _tagLock.protect(key, closure: () async {
        await _internalRemove(key);
        emit(state.remove(key));
      });

  R operate<R>(K key, {required R Function(B bloc) closure}) {
    final bloc = _entries[key]!.bloc;
    return closure(bloc);
  }

  R? tryOperate<R>(K key, {required R Function(B bloc) closure}) {
    final entry = _entries[key];
    if (entry == null) {
      return null;
    }
    return closure(entry.bloc);
  }

  Future<R> operateAsync<R>(K key,
          {required Future<R> Function(B bloc) closure}) =>
      _tagLock.protect(key, closure: () async {
        final bloc = _entries[key]!.bloc;
        return closure(bloc);
      });

  Future<R?> tryOperateAsync<R>(K key,
          {required Future<R> Function(B bloc) closure}) =>
      _tagLock.protect(key, closure: () async {
        final entry = _entries[key];
        if (entry == null) {
          return null;
        }
        return closure(entry.bloc);
      });

  final Map<K, _ItemEntry<S, B>> _entries;
  final AsyncTagLock<K> _tagLock;
}
