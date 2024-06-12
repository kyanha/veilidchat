import 'dart:async';

import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;

typedef AccountRecordState = proto.Account;

class AccountRecordCubit extends DefaultDHTRecordCubit<AccountRecordState> {
  AccountRecordCubit({
    required super.open,
  }) : super(decodeState: proto.Account.fromBuffer);

  @override
  Future<void> close() async {
    await super.close();
  }
}
