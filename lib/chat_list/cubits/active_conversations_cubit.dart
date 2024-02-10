import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../contacts/contacts.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';

class ActiveConversationsCubit extends BlocMapCubit<TypedKey,
    AsyncValue<ConversationState>, ConversationCubit> {
  ActiveConversationsCubit({required ActiveAccountInfo activeAccountInfo})
      : _activeAccountInfo = activeAccountInfo;

  Future<void> addConversation({required proto.Contact contact}) async =>
      add(() => MapEntry(
          contact.remoteConversationRecordKey,
          ConversationCubit(
            activeAccountInfo: _activeAccountInfo,
            remoteIdentityPublicKey: contact.identityPublicKey,
            localConversationRecordKey: contact.localConversationRecordKey,
            remoteConversationRecordKey: contact.remoteConversationRecordKey,
          )));

  final ActiveAccountInfo _activeAccountInfo;
}
