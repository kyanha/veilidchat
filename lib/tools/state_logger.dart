import 'package:bloc/bloc.dart';
import 'loggy.dart';

/// [BlocObserver] for the VeilidChat application that
/// observes all state changes.
class StateLogger extends BlocObserver {
  /// {@macro counter_observer}
  const StateLogger();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log.debug('Change: ${bloc.runtimeType} $change');
  }

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    log.debug('Create: ${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    log.debug('Close: ${bloc.runtimeType}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log.error('Error: ${bloc.runtimeType} $error\n$stackTrace');
  }
}
