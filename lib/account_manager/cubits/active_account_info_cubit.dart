import 'dart:async';

import 'package:bloc/bloc.dart';

import '../models/models.dart';
import '../repository/account_repository.dart';

class ActiveAccountInfoCubit extends Cubit<AccountInfo> {
  ActiveAccountInfoCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository,
        super(accountRepository
            .getAccountInfo(accountRepository.getActiveLocalAccount())) {
    // Subscribe to streams
    _accountRepositorySubscription = _accountRepository.stream.listen((change) {
      switch (change) {
        case AccountRepositoryChange.activeLocalAccount:
        case AccountRepositoryChange.localAccounts:
        case AccountRepositoryChange.userLogins:
          emit(accountRepository
              .getAccountInfo(accountRepository.getActiveLocalAccount()));
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
