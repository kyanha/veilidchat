import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'unlocked_account_info.dart';

enum AccountInfoStatus {
  noAccount,
  accountInvalid,
  accountLocked,
  accountReady,
}

@immutable
class AccountInfo extends Equatable {
  const AccountInfo({
    required this.status,
    required this.active,
    required this.unlockedAccountInfo,
  });

  final AccountInfoStatus status;
  final bool active;
  final UnlockedAccountInfo? unlockedAccountInfo;

  @override
  List<Object?> get props => [status, active, unlockedAccountInfo];
}
