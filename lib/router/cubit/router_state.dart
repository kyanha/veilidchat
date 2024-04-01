part of 'router_cubit.dart';

@freezed
class RouterState with _$RouterState {
  const factory RouterState(
      {required bool isInitialized,
      required bool hasAnyAccount,
      required bool hasActiveChat}) = _RouterState;

  factory RouterState.fromJson(dynamic json) =>
      _$RouterStateFromJson(json as Map<String, dynamic>);
}
