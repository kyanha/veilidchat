part of 'local_accounts_cubit.dart';

typedef LocalAccountsState = IList<LocalAccount>;

extension LocalAccountsStateExt on LocalAccountsState {
  LocalAccount? fetchLocalAccount({required TypedKey accountMasterRecordKey}) {
    final idx = indexWhere(
        (e) => e.identityMaster.masterRecordKey == accountMasterRecordKey);
    if (idx == -1) {
      return null;
    }
    return this[idx];
  }
}
