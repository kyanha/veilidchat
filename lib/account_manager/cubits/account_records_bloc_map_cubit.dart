import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';

typedef AccountRecordsBlocMapState
    = BlocMapState<TypedKey, AsyncValue<AccountRecordState>>;

/// Map of the logged in user accounts to their AccountRecordCubit
/// Ensures there is an single account record cubit for each logged in account
class AccountRecordsBlocMapCubit extends BlocMapCubit<TypedKey,
        AsyncValue<AccountRecordState>, AccountRecordCubit>
    with StateMapFollower<LocalAccountsState, TypedKey, LocalAccount> {
  AccountRecordsBlocMapCubit(
      AccountRepository accountRepository, Locator locator)
      : _accountRepository = accountRepository {
    // Follow the local accounts cubit
    follow(locator<LocalAccountsCubit>());
  }

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
  Future<void> updateState(TypedKey key, LocalAccount value) async {
    await _addAccountRecordCubit(
        superIdentityRecordKey: value.superIdentity.recordKey);
  }

  ////////////////////////////////////////////////////////////////////////////
  final AccountRepository _accountRepository;
}
