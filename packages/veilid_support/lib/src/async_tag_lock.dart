import 'package:mutex/mutex.dart';

class _AsyncTagLockEntry {
  _AsyncTagLockEntry()
      : mutex = Mutex(),
        waitingCount = 1;
  //
  Mutex mutex;
  int waitingCount;
}

class AsyncTagLock<T> {
  AsyncTagLock()
      : _tableLock = Mutex(),
        _locks = {};

  Future<void> lockTag(T tag) async {
    await _tableLock.protect(() async {
      var lockEntry = _locks[tag];
      if (lockEntry != null) {
        lockEntry.waitingCount++;
      } else {
        lockEntry = _locks[tag] = _AsyncTagLockEntry();
      }

      await lockEntry.mutex.acquire();
      lockEntry.waitingCount--;
    });
  }

  void unlockTag(T tag) {
    final lockEntry = _locks[tag]!;
    if (lockEntry.waitingCount == 0) {
      // If nobody is waiting for the mutex we can just drop it
      _locks.remove(tag);
    } else {
      // Someone's waiting for the tag lock so release the mutex for it
      lockEntry.mutex.release();
    }
  }

  //
  final Mutex _tableLock;
  final Map<T, _AsyncTagLockEntry> _locks;
}
