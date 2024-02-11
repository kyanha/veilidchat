import 'dart:async';

import 'async_tag_lock.dart';

AsyncTagLock<Object> _keys = AsyncTagLock();

void singleFuture(Object tag, Future<void> Function() closure,
    {void Function()? onBusy}) {
  if (!_keys.tryLock(tag)) {
    if (onBusy != null) {
      onBusy();
    }
    return;
  }
  unawaited(() async {
    await closure();
    _keys.unlockTag(tag);
  }());
}
