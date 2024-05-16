import 'dart:async';

abstract class DHTOpenable<C> {
  bool get isOpen;
  Future<C> ref();
  Future<void> close();
  Future<void> delete();
}

extension DHTOpenableExt<D extends DHTOpenable<D>> on D {
  /// Runs a closure that guarantees the DHTOpenable
  /// will be closed upon exit, even if an uncaught exception is thrown
  Future<T> scope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('not open in scope');
    }
    try {
      return await scopeFunction(this);
    } finally {
      await close();
    }
  }

  /// Runs a closure that guarantees the DHTOpenable
  /// will be closed upon exit, and deleted if an an
  /// uncaught exception is thrown
  Future<T> deleteScope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('not open in deleteScope');
    }

    try {
      return await scopeFunction(this);
    } on Exception {
      await delete();
      rethrow;
    } finally {
      await close();
    }
  }

  /// Scopes a closure that conditionally deletes the DHTOpenable on exit
  Future<T> maybeDeleteScope<T>(
      bool delete, Future<T> Function(D) scopeFunction) async {
    if (delete) {
      return deleteScope(scopeFunction);
    }
    return scope(scopeFunction);
  }
}
