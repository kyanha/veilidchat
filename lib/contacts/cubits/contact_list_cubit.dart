import 'dart:async';
import 'dart:convert';

import 'package:async_tools/async_tools.dart';
import 'package:protobuf/protobuf.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import '../../conversation/cubits/conversation_cubit.dart';

//////////////////////////////////////////////////
// Mutable state for per-account contacts

class ContactListCubit extends DHTShortArrayCubit<proto.Contact> {
  ContactListCubit({
    required UnlockedAccountInfo unlockedAccountInfo,
    required proto.Account account,
  })  : _activeAccountInfo = unlockedAccountInfo,
        super(
            open: () => _open(unlockedAccountInfo, account),
            decodeElement: proto.Contact.fromBuffer);

  static Future<DHTShortArray> _open(
      UnlockedAccountInfo activeAccountInfo, proto.Account account) async {
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final contactListRecordKey = account.contactList.toVeilid();

    final dhtRecord = await DHTShortArray.openOwned(contactListRecordKey,
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
      return updateContactRemoteProfile(
          localConversationRecordKey: localConversationRecordKey,
          remoteProfile: remoteProfile);
    });
  }

  Future<void> updateContactRemoteProfile({
    required TypedKey localConversationRecordKey,
    required proto.Profile remoteProfile,
  }) async {
    // Update contact's remoteProfile
    await operateWriteEventual((writer) async {
      for (var pos = 0; pos < writer.length; pos++) {
        final c = await writer.getProtobuf(proto.Contact.fromBuffer, pos);
        if (c != null &&
            c.localConversationRecordKey.toVeilid() ==
                localConversationRecordKey) {
          if (c.remoteProfile == remoteProfile) {
            // Unchanged
            break;
          }
          final newContact = c.deepCopy()..remoteProfile = remoteProfile;
          final updated = await writer.tryWriteItemProtobuf(
              proto.Contact.fromBuffer, pos, newContact);
          if (!updated) {
            throw DHTExceptionTryAgain();
          }
        }
      }
    });
  }

  Future<void> createContact({
    required proto.Profile remoteProfile,
    required SuperIdentity remoteSuperIdentity,
    required TypedKey remoteConversationRecordKey,
    required TypedKey localConversationRecordKey,
  }) async {
    // Create Contact
    final contact = proto.Contact()
      ..editedProfile = remoteProfile
      ..remoteProfile = remoteProfile
      ..superIdentityJson = jsonEncode(remoteSuperIdentity.toJson())
      ..identityPublicKey =
          remoteSuperIdentity.currentInstance.typedPublicKey.toProto()
      ..remoteConversationRecordKey = remoteConversationRecordKey.toProto()
      ..localConversationRecordKey = localConversationRecordKey.toProto()
      ..showAvailability = false;

    // Add Contact to account's list
    // if this fails, don't keep retrying, user can try again later
    await operateWrite((writer) async {
      await writer.add(contact.writeToBuffer());
    });
  }

  Future<void> deleteContact({required proto.Contact contact}) async {
    final remoteIdentityPublicKey = contact.identityPublicKey.toVeilid();
    final localConversationRecordKey =
        contact.localConversationRecordKey.toVeilid();
    final remoteConversationRecordKey =
        contact.remoteConversationRecordKey.toVeilid();

    // Remove Contact from account's list
    final deletedItem = await operateWrite((writer) async {
      for (var i = 0; i < writer.length; i++) {
        final item = await writer.getProtobuf(proto.Contact.fromBuffer, i);
        if (item == null) {
          throw Exception('Failed to get contact');
        }
        if (item.localConversationRecordKey ==
            contact.localConversationRecordKey) {
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

  final UnlockedAccountInfo _activeAccountInfo;
  final _contactProfileUpdateMap =
      SingleStateProcessorMap<TypedKey, proto.Profile?>();
}
