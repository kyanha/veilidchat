part of 'user_logins_cubit.dart';

typedef UserLoginsState = IList<UserLogin>;

extension UserLoginsStateExt on UserLoginsState {
  UserLogin? fetchUserLogin({required TypedKey accountMasterRecordKey}) {
    final idx =
        indexWhere((e) => e.accountMasterRecordKey == accountMasterRecordKey);
    if (idx == -1) {
      return null;
    }
    return this[idx];
  }
}
