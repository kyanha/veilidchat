import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/models.dart';
import '../repository/account_repository/account_repository.dart';

class UserLoginsCubit extends Cubit<IList<UserLogin>> {
  UserLoginsCubit(AccountRepository accountRepository)
      : _accountRepository = accountRepository,
        super(IList<UserLogin>()) {
    // Subscribe to streams
    _initAccountRepositorySubscription();
  }

  void _initAccountRepositorySubscription() {
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

  final AccountRepository _accountRepository;
  late final StreamSubscription<AccountRepositoryChange>
      _accountRepositorySubscription;
}
