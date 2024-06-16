import 'dart:async';
import 'dart:convert';

import 'package:async_tools/async_tools.dart';
import 'package:protobuf/protobuf.dart';
import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../conversation/conversation.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';

//////////////////////////////////////////////////
// Mutable state for per-account contacts

class ContactListCubit extends DHTShortArrayCubit<proto.Contact> {
  ContactListCubit({
    required Locator locator,
    required TypedKey accountRecordKey,
    required OwnedDHTRecordPointer contactListRecordPointer,
  })  : _locator = locator,
        super(
            open: () => _open(accountRecordKey, contactListRecordPointer),
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
            throw DHTExceptionTryAgain();
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
    // if this fails, don't keep retrying, user can try again later
    await operateWrite((writer) async {
      await writer.add(contact.writeToBuffer());
    });
  }

  Future<void> deleteContact(
      {required TypedKey localConversationRecordKey}) async {
    // Remove Contact from account's list
    final deletedItem = await operateWrite((writer) async {
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
        // Make a conversation cubit to manipulate the conversation
        final conversationCubit = ConversationCubit(
          locator: _locator,
          remoteIdentityPublicKey: deletedItem.identityPublicKey.toVeilid(),
          localConversationRecordKey:
              deletedItem.localConversationRecordKey.toVeilid(),
          remoteConversationRecordKey:
              deletedItem.remoteConversationRecordKey.toVeilid(),
        );

        // Delete the local and remote conversation records
        await conversationCubit.delete();
      } on Exception catch (e) {
        log.debug('error deleting conversation records: $e', e);
      }
    }
  }

  final _contactProfileUpdateMap =
      SingleStateProcessorMap<TypedKey, proto.Profile?>();
  final Locator _locator;
}
