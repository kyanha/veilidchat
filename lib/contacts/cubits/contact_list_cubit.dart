import 'dart:async';
import 'dart:convert';

import 'package:async_tools/async_tools.dart';
import 'package:protobuf/protobuf.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';

//////////////////////////////////////////////////
// Mutable state for per-account contacts

class ContactListCubit extends DHTShortArrayCubit<proto.Contact> {
  ContactListCubit({
    required AccountInfo accountInfo,
    required OwnedDHTRecordPointer contactListRecordPointer,
  }) : super(
            open: () =>
                _open(accountInfo.accountRecordKey, contactListRecordPointer),
            decodeElement: proto.Contact.fromBuffer);

  static Future<DHTShortArray> _open(TypedKey accountRecordKey,
      OwnedDHTRecordPointer contactListRecordPointer) async {
    final dhtRecord = await DHTShortArray.openOwned(contactListRecordPointer,
        debugName: 'ContactListCubit::_open::ContactList',
        parent: accountRecordKey);

    return dhtRecord;
  }

  @override
  Future<void> close() async {
    await _contactProfileUpdateMap.close();
    await super.close();
  }
  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  void followContactProfileChanges(TypedKey localConversationRecordKey,
      Stream<proto.Profile?> profileStream, proto.Profile? profileState) {
    _contactProfileUpdateMap
        .follow(localConversationRecordKey, profileStream, profileState,
            (remoteProfile) async {
      if (remoteProfile == null) {
        return;
      }
      return updateContactProfile(
          localConversationRecordKey: localConversationRecordKey,
          profile: remoteProfile);
    });
  }

  Future<void> updateContactProfile({
    required TypedKey localConversationRecordKey,
    required proto.Profile profile,
  }) async {
    // Update contact's remoteProfile
    await operateWriteEventual((writer) async {
      for (var pos = 0; pos < writer.length; pos++) {
        final c = await writer.getProtobuf(proto.Contact.fromBuffer, pos);
        if (c != null &&
            c.localConversationRecordKey.toVeilid() ==
                localConversationRecordKey) {
          if (c.profile == profile) {
            // Unchanged
            break;
          }
          final newContact = c.deepCopy()..profile = profile;
          final updated = await writer.tryWriteItemProtobuf(
              proto.Contact.fromBuffer, pos, newContact);
          if (!updated) {
            throw DHTExceptionOutdated();
          }
          break;
        }
      }
    });
  }

  Future<void> createContact({
    required proto.Profile profile,
    required SuperIdentity remoteSuperIdentity,
    required TypedKey localConversationRecordKey,
    required TypedKey remoteConversationRecordKey,
  }) async {
    // Create Contact
    final contact = proto.Contact()
      ..profile = profile
      ..superIdentityJson = jsonEncode(remoteSuperIdentity.toJson())
      ..identityPublicKey =
          remoteSuperIdentity.currentInstance.typedPublicKey.toProto()
      ..localConversationRecordKey = localConversationRecordKey.toProto()
      ..remoteConversationRecordKey = remoteConversationRecordKey.toProto()
      ..showAvailability = false;

    // Add Contact to account's list
    await operateWriteEventual((writer) async {
      await writer.add(contact.writeToBuffer());
    });
  }

  Future<void> deleteContact(
      {required TypedKey localConversationRecordKey}) async {
    // Remove Contact from account's list
    final deletedItem = await operateWriteEventual((writer) async {
      for (var i = 0; i < writer.length; i++) {
        final item = await writer.getProtobuf(proto.Contact.fromBuffer, i);
        if (item == null) {
          throw Exception('Failed to get contact');
        }
        if (item.localConversationRecordKey.toVeilid() ==
            localConversationRecordKey) {
          await writer.remove(i);
          return item;
        }
      }
      return null;
    });

    if (deletedItem != null) {
      try {
        // Mark the conversation records for deletion
        await DHTRecordPool.instance
            .deleteRecord(deletedItem.localConversationRecordKey.toVeilid());
        await DHTRecordPool.instance
            .deleteRecord(deletedItem.remoteConversationRecordKey.toVeilid());
      } on Exception catch (e) {
        log.debug('error deleting conversation records: $e', e);
      }
    }
  }

  final _contactProfileUpdateMap =
      SingleStateProcessorMap<TypedKey, proto.Profile?>();
}
