import 'dart:async';

import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;

class AccountRecordCubit extends DefaultDHTRecordCubit<proto.Account> {
  AccountRecordCubit({
    required super.record,
  }) : super.value(decodeState: proto.Account.fromBuffer);

  @override
  Future<void> close() async {
    await super.close();
  }
}
