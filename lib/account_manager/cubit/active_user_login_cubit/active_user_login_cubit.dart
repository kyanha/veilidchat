import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../repository/account_repository/account_repository.dart';

part 'active_user_login_state.dart';

class ActiveUserLoginCubit extends Cubit<ActiveUserLoginState> {
  ActiveUserLoginCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository,
        super(null) {
    // Subscribe to streams
    _initAccountRepositorySubscription();
  }

  void _initAccountRepositorySubscription() {
    _accountRepositorySubscription = _accountRepository.stream.listen((change) {
      switch (change) {
        case AccountRepositoryChange.activeUserLogin:
          emit(_accountRepository.getActiveUserLogin());
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
