import 'dart:async';

import 'package:protobuf/protobuf.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;
import '../account_manager.dart';

typedef AccountRecordState = proto.Account;

/// The saved state of a VeilidChat Account on the DHT
/// Used to synchronize status, profile, and options for a specific account
/// across multiple clients. This DHT record is the 'source of truth' for an
/// account and is privately encrypted with an owned record from the 'userLogin'
/// tabledb-local storage, encrypted by the unlock code for the account.
class AccountRecordCubit extends DefaultDHTRecordCubit<AccountRecordState> {
  AccountRecordCubit(
      {required LocalAccount localAccount, required UserLogin userLogin})
      : super(
            decodeState: proto.Account.fromBuffer,
            open: () => _open(localAccount, userLogin));

  static Future<DHTRecord> _open(
      LocalAccount localAccount, UserLogin userLogin) async {
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

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  Future<void> updateProfile(proto.Profile profile) async {
    await record.eventualUpdateProtobuf(proto.Account.fromBuffer, (old) async {
      if (old == null || old.profile == profile) {
        return null;
      }
      return old.deepCopy()..profile = profile;
    });
  }
}
