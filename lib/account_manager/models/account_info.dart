import 'package:meta/meta.dart';

import 'unlocked_account_info.dart';

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
    required this.unlockedAccountInfo,
  });

  final AccountInfoStatus status;
  final bool active;
  final UnlockedAccountInfo? unlockedAccountInfo;
}
