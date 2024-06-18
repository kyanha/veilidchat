import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/models.dart';
import '../repository/account_repository.dart';

typedef UserLoginsState = IList<UserLogin>;

class UserLoginsCubit extends Cubit<UserLoginsState> {
  UserLoginsCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository,
        super(accountRepository.getUserLogins()) {
    // Subscribe to streams
    _accountRepositorySubscription = _accountRepository.stream.listen((change) {
      switch (change) {
        case AccountRepositoryChange.userLogins:
          emit(_accountRepository.getUserLogins());
          break;
        // Ignore these
        case AccountRepositoryChange.localAccounts:
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
  ////////////////////////////////////////////////////////////////////////////

  final AccountRepository _accountRepository;
  late final StreamSubscription<AccountRepositoryChange>
      _accountRepositorySubscription;
}
