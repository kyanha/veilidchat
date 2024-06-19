import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';

typedef PerAccountCollectionBlocMapState
    = BlocMapState<TypedKey, PerAccountCollectionState>;

/// Map of the logged in user accounts to their PerAccountCollectionCubit
/// Ensures there is an single account record cubit for each logged in account
class PerAccountCollectionBlocMapCubit extends BlocMapCubit<TypedKey,
        PerAccountCollectionState, PerAccountCollectionCubit>
    with StateMapFollower<LocalAccountsState, TypedKey, LocalAccount> {
  PerAccountCollectionBlocMapCubit({
    required Locator locator,
    required AccountRepository accountRepository,
  })  : _locator = locator,
        _accountRepository = accountRepository {
    // Follow the local accounts cubit
    follow(locator<LocalAccountsCubit>());
  }

  // Add account record cubit
  Future<void> _addPerAccountCollectionCubit(
          {required TypedKey superIdentityRecordKey}) async =>
      add(() => MapEntry(
          superIdentityRecordKey,
          PerAccountCollectionCubit(
              locator: _locator,
              accountInfoCubit: AccountInfoCubit(
                  accountRepository: _accountRepository,
                  superIdentityRecordKey: superIdentityRecordKey))));

  /// StateFollower /////////////////////////

  @override
  Future<void> removeFromState(TypedKey key) => remove(key);

  @override
  Future<void> updateState(TypedKey key, LocalAccount value) async {
    await _addPerAccountCollectionCubit(
        superIdentityRecordKey: value.superIdentity.recordKey);
  }

  ////////////////////////////////////////////////////////////////////////////
  final AccountRepository _accountRepository;
  final Locator _locator;
}
