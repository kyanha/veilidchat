import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

enum AccountInfoStatus {
  noAccount,
  accountInvalid,
  accountLocked,
  accountReady,
}

@immutable
class AccountInfo {
  const AccountInfo({
    required this.status,
    required this.active,
    this.accountRecord,
  });

  final AccountInfoStatus status;
  final bool active;
  final DHTRecord? accountRecord;
}
