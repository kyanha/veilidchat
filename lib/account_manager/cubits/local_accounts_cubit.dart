import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../models/models.dart';
import '../repository/account_repository.dart';

typedef LocalAccountsState = IList<LocalAccount>;

class LocalAccountsCubit extends Cubit<LocalAccountsState>
    with StateMapFollowable<LocalAccountsState, TypedKey, LocalAccount> {
  LocalAccountsCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository,
        super(accountRepository.getLocalAccounts()) {
    // Subscribe to streams
    _accountRepositorySubscription = _accountRepository.stream.listen((change) {
      switch (change) {
        case AccountRepositoryChange.localAccounts:
          emit(_accountRepository.getLocalAccounts());
          break;
        // Ignore these
        case AccountRepositoryChange.userLogins:
        case AccountRepositoryChange.activeLocalAccount:
          break;
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    await _accountRepositorySubscription.cancel();
  }

  /// StateMapFollowable /////////////////////////
  @override
  IMap<TypedKey, LocalAccount> getStateMap(LocalAccountsState state) {
    final stateValue = state;
    return IMap.fromIterable(stateValue,
        keyMapper: (e) => e.superIdentity.recordKey, valueMapper: (e) => e);
  }

  final AccountRepository _accountRepository;
  late final StreamSubscription<AccountRepositoryChange>
      _accountRepositorySubscription;
}
