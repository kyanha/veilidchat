import 'dart:async';
import 'dart:convert';

import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import 'conversation_cubit.dart';

//////////////////////////////////////////////////
// Mutable state for per-account contacts

class ContactListCubit extends DHTShortArrayCubit<proto.Contact> {
  ContactListCubit({
    required ActiveAccountInfo activeAccountInfo,
    required proto.Account account,
  })  : _activeAccountInfo = activeAccountInfo,
        super(
            open: () => _open(activeAccountInfo, account),
            decodeElement: proto.Contact.fromBuffer);

  static Future<DHTShortArray> _open(
      ActiveAccountInfo activeAccountInfo, proto.Account account) async {
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final contactListRecordKey = account.contactList.toVeilid();

    final dhtRecord = await DHTShortArray.openOwned(contactListRecordKey,
        debugName: 'ContactListCubit::_open::ContactList',
        parent: accountRecordKey);

    return dhtRecord;
  }

  Future<void> createContact({
    required proto.Profile remoteProfile,
    required IdentityMaster remoteIdentity,
    required TypedKey remoteConversationRecordKey,
    required TypedKey localConversationRecordKey,
  }) async {
    // Create Contact
    final contact = proto.Contact()
      ..editedProfile = remoteProfile
      ..remoteProfile = remoteProfile
      ..identityMasterJson = jsonEncode(remoteIdentity.toJson())
      ..identityPublicKey = TypedKey(
              kind: remoteIdentity.identityRecordKey.kind,
              value: remoteIdentity.identityPublicKey)
          .toProto()
      ..remoteConversationRecordKey = remoteConversationRecordKey.toProto()
      ..localConversationRecordKey = localConversationRecordKey.toProto()
      ..showAvailability = false;

    // Add Contact to account's list
    // if this fails, don't keep retrying, user can try again later
    await operateWrite((writer) async {
      if (!await writer.tryAddItem(contact.writeToBuffer())) {
        throw Exception('Failed to add contact record');
      }
    });
  }

  Future<void> deleteContact({required proto.Contact contact}) async {
    final remoteIdentityPublicKey = contact.identityPublicKey.toVeilid();
    final localConversationRecordKey =
        contact.localConversationRecordKey.toVeilid();
    final remoteConversationRecordKey =
        contact.remoteConversationRecordKey.toVeilid();

    // Remove Contact from account's list
    final (deletedItem, success) = await operateWrite((writer) async {
      for (var i = 0; i < writer.length; i++) {
        final item = await writer.getItemProtobuf(proto.Contact.fromBuffer, i);
        if (item == null) {
          throw Exception('Failed to get contact');
        }
        if (item.remoteConversationRecordKey ==
            contact.remoteConversationRecordKey) {
          if (await writer.tryRemoveItem(i) != null) {
            return item;
          }
          return null;
        }
      }
      return null;
    });

    if (success && deletedItem != null) {
      try {
        // Make a conversation cubit to manipulate the conversation
        final conversationCubit = ConversationCubit(
          activeAccountInfo: _activeAccountInfo,
          remoteIdentityPublicKey: remoteIdentityPublicKey,
          localConversationRecordKey: localConversationRecordKey,
          remoteConversationRecordKey: remoteConversationRecordKey,
        );

        // Delete the local and remote conversation records
        await conversationCubit.delete();
      } on Exception catch (e) {
        log.debug('error deleting conversation records: $e', e);
      }
    }
  }

  final ActiveAccountInfo _activeAccountInfo;
}
