import 'dart:async';

import 'package:meta/meta.dart';

abstract class DHTCloseable<C, D> {
  bool get isOpen;
  @protected
  FutureOr<D> scoped();
  Future<C> ref();
  Future<void> close();
}

abstract class DHTDeleteable<C, D> extends DHTCloseable<C, D> {
  Future<void> delete();
}

extension DHTCloseableExt<C, D> on DHTCloseable<C, D> {
  /// Runs a closure that guarantees the DHTCloseable
  /// will be closed upon exit, even if an uncaught exception is thrown
  Future<T> scope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('not open in scope');
    }
    try {
      return await scopeFunction(await scoped());
    } finally {
      await close();
    }
  }
}

extension DHTDeletableExt<C, D> on DHTDeleteable<C, D> {
  /// Runs a closure that guarantees the DHTCloseable
  /// will be closed upon exit, and deleted if an an
  /// uncaught exception is thrown
  Future<T> deleteScope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('not open in deleteScope');
    }

    try {
      return await scopeFunction(await scoped());
    } on Exception {
      await delete();
      rethrow;
    } finally {
      await close();
    }
  }

  /// Scopes a closure that conditionally deletes the DHTCloseable on exit
  Future<T> maybeDeleteScope<T>(
      bool delete, Future<T> Function(D) scopeFunction) async {
    if (delete) {
      return deleteScope(scopeFunction);
    }
    return scope(scopeFunction);
  }
}
