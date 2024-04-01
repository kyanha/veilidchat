import 'package:meta/meta.dart';

import 'active_account_info.dart';

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
    required this.activeAccountInfo,
  });

  final AccountInfoStatus status;
  final bool active;
  final ActiveAccountInfo? activeAccountInfo;
}
