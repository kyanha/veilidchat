import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../repository/account_repository/account_repository.dart';

class ActiveLocalAccountCubit extends Cubit<TypedKey?> {
  ActiveLocalAccountCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository,
        super(accountRepository.getActiveLocalAccount()) {
    // Subscribe to streams
    _accountRepositorySubscription = _accountRepository.stream.listen((change) {
      switch (change) {
        case AccountRepositoryChange.activeLocalAccount:
          emit(_accountRepository.getActiveLocalAccount());
          break;
        // Ignore these
        case AccountRepositoryChange.localAccounts:
        case AccountRepositoryChange.userLogins:
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
