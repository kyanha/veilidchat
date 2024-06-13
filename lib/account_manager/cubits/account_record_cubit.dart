import 'dart:async';

import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;
import '../account_manager.dart';

typedef AccountRecordState = proto.Account;

class AccountRecordCubit extends DefaultDHTRecordCubit<AccountRecordState> {
  AccountRecordCubit(
      {required AccountRepository accountRepository,
      required TypedKey superIdentityRecordKey})
      : super(
            decodeState: proto.Account.fromBuffer,
            open: () => _open(accountRepository, superIdentityRecordKey));

  static Future<DHTRecord> _open(AccountRepository accountRepository,
      TypedKey superIdentityRecordKey) async {
    final localAccount =
        accountRepository.fetchLocalAccount(superIdentityRecordKey)!;
    final userLogin = accountRepository.fetchUserLogin(superIdentityRecordKey)!;

    // Record not yet open, do it
    final pool = DHTRecordPool.instance;
    final record = await pool.openRecordOwned(
        userLogin.accountRecordInfo.accountRecord,
        debugName: 'AccountRecordCubit::_open::AccountRecord',
        parent: localAccount.superIdentity.currentInstance.recordKey);

    return record;
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}
