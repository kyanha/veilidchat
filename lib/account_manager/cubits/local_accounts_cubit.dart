import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/models.dart';
import '../repository/account_repository/account_repository.dart';

class LocalAccountsCubit extends Cubit<IList<LocalAccount>> {
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

  final AccountRepository _accountRepository;
  late final StreamSubscription<AccountRepositoryChange>
      _accountRepositorySubscription;
}
