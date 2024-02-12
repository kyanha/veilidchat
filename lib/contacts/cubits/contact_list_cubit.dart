import 'dart:async';
import 'dart:convert';

import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';

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
    if (await shortArray.tryAddItem(contact.writeToBuffer()) == false) {
      throw Exception('Failed to add contact record');
    }
  }

  Future<void> deleteContact({required proto.Contact contact}) async {
    final pool = DHTRecordPool.instance;
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
    final localConversationKey = contact.localConversationRecordKey.toVeilid();
    final remoteConversationKey =
        contact.remoteConversationRecordKey.toVeilid();

    // Remove Contact from account's list
    for (var i = 0; i < shortArray.length; i++) {
      final item =
          await shortArray.getItemProtobuf(proto.Contact.fromBuffer, i);
      if (item == null) {
        throw Exception('Failed to get contact');
      }
      if (item.remoteConversationRecordKey ==
          contact.remoteConversationRecordKey) {
        await shortArray.tryRemoveItem(i);
        break;
      }
    }
    try {
      await (await pool.openRead(localConversationKey,
              parent: accountRecordKey))
          .delete();
    } on Exception catch (e) {
      log.debug('error removing local conversation record key: $e', e);
    }
    try {
      if (localConversationKey != remoteConversationKey) {
        await (await pool.openRead(remoteConversationKey,
                parent: accountRecordKey))
            .delete();
      }
    } on Exception catch (e) {
      log.debug('error removing remote conversation record key: $e', e);
    }
  }

  //
  final ActiveAccountInfo _activeAccountInfo;
}
