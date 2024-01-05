import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../models/models.dart';
import '../../repository/account_repository/account_repository.dart';

part 'local_accounts_state.dart';

class LocalAccountsCubit extends Cubit<LocalAccountsState> {
  LocalAccountsCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository,
        super(LocalAccountsState()) {
    // Subscribe to streams
    _initAccountRepositorySubscription();
  }

  void _initAccountRepositorySubscription() {
    _accountRepositorySubscription =
        _accountRepository.changes().listen((change) {
      switch (change) {
        case AccountRepositoryChange.localAccounts:
          emit(_accountRepository.getLocalAccounts());
          break;
        // Ignore these
        case AccountRepositoryChange.userLogins:
        case AccountRepositoryChange.activeUserLogin:
          break;
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    await _accountRepositorySubscription.cancel();
  }

  final AccountRepository _accountRepository;
  late final StreamSubscription<AccountRepositoryChange>
      _accountRepositorySubscription;
}
