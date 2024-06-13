import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';

typedef AccountRecordsBlocMapState
    = BlocMapState<TypedKey, AsyncValue<AccountRecordState>>;

// Map of the logged in user accounts to their account information
class AccountRecordsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<AccountRecordState>, AccountRecordCubit>
    with StateMapFollower<UserLoginsState, TypedKey, UserLogin> {
  AccountRecordsBlocMapCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository;

  // Add account record cubit
  Future<void> _addAccountRecordCubit(
          {required TypedKey superIdentityRecordKey}) async =>
      add(() => MapEntry(
          superIdentityRecordKey,
          AccountRecordCubit(
              accountRepository: _accountRepository,
              superIdentityRecordKey: superIdentityRecordKey)));

  /// StateFollower /////////////////////////

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(TypedKey key, UserLogin value) async {
    await _addAccountRecordCubit(
        superIdentityRecordKey: value.superIdentityRecordKey);
  }

  ////////////////////////////////////////////////////////////////////////////
  final AccountRepository _accountRepository;
}
