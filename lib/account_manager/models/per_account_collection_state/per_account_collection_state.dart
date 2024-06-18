import 'package:async_tools/async_tools.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../contact_invitation/contact_invitation.dart';
import '../../../proto/proto.dart' show Account;
import '../../account_manager.dart';

part 'per_account_collection_state.freezed.dart';

@freezed
class PerAccountCollectionState with _$PerAccountCollectionState {
  const factory PerAccountCollectionState(
          {required AccountInfo accountInfo,
          required AsyncValue<AccountRecordState> avAccountRecordState,
          required ContactInvitationListCubit? contactInvitationListCubit}) =
      _PerAccountCollectionState;
}
