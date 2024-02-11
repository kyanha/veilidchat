import 'dart:async';

import 'async_tag_lock.dart';

AsyncTagLock<Object> _keys = AsyncTagLock();

void singleFuture<T>(Object tag, Future<T> Function() closure,
    {void Function()? onBusy, void Function(T)? onDone}) {
  if (!_keys.tryLock(tag)) {
    if (onBusy != null) {
      onBusy();
    }
    return;
  }
  unawaited(() async {
    try {
      final out = await closure();
      if (onDone != null) {
        onDone(out);
      }
    } finally {
      _keys.unlockTag(tag);
    }
  }());
}
