import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../models/models.dart';
import '../repository/account_repository.dart';

class AccountInfoCubit extends Cubit<AccountInfo> {
  AccountInfoCubit(
      {required AccountRepository accountRepository,
      required TypedKey superIdentityRecordKey})
      : _accountRepository = accountRepository,
        super(accountRepository.getAccountInfo(superIdentityRecordKey)!) {
    // Subscribe to streams
    _accountRepositorySubscription = _accountRepository.stream.listen((change) {
      switch (change) {
        case AccountRepositoryChange.activeLocalAccount:
        case AccountRepositoryChange.localAccounts:
        case AccountRepositoryChange.userLogins:
          final acctInfo =
              accountRepository.getAccountInfo(superIdentityRecordKey);
          if (acctInfo != null) {
            emit(acctInfo);
          }
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
