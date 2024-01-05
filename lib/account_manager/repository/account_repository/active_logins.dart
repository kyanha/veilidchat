// Represents a set of user logins and the currently selected account
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../models/models.dart';

part 'active_logins.g.dart';
part 'active_logins.freezed.dart';

@freezed
class ActiveLogins with _$ActiveLogins {
  const factory ActiveLogins({
    // The list of current logged in accounts
    required IList<UserLogin> userLogins,
    // The current selected account indexed by master record key
    TypedKey? activeUserLogin,
  }) = _ActiveLogins;

  factory ActiveLogins.empty() =>
      const ActiveLogins(userLogins: IListConst([]));

  factory ActiveLogins.fromJson(dynamic json) =>
      _ActiveLogins.fromJson(json as Map<String, dynamic>);
}
