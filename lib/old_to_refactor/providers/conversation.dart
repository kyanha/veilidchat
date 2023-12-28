// A Conversation is a type of Chat that is 1:1 between two Contacts only
// Each Contact in the ContactList has at most one Conversation between the
// remote contact and the local account

import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../proto/proto.dart' as proto;

import '../../tools/tools.dart';
import '../../init.dart';
import '../../../packages/veilid_support/veilid_support.dart';
import 'account.dart';
import 'chat.dart';
import 'contact.dart';

part 'conversation.g.dart';

class Conversation {
  Conversation._(
      {required ActiveAccountInfo activeAccountInfo,
      required TypedKey localConversationRecordKey,
      required TypedKey remoteIdentityPublicKey,
      required TypedKey remoteConversationRecordKey})
      : _activeAccountInfo = activeAccountInfo,
        _localConversationRecordKey = localConversationRecordKey,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _remoteConversationRecordKey = remoteConversationRecordKey;

  Future<Conversation> open() async {}

  Future<void> close() async {
    //
  }

  Future<proto.Conversation?> readRemoteConversation() async {
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
    final pool = await DHTRecordPool.instance();

    final crypto = await getConversationCrypto();
    return (await pool.openRead(_remoteConversationRecordKey,
            parent: accountRecordKey, crypto: crypto))
        .scope((remoteConversation) async {
      //
      final conversation =
          await remoteConversation.getProtobuf(proto.Conversation.fromBuffer);
      return conversation;
    });
  }

  Future<proto.Conversation?> readLocalConversation() async {
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
    final pool = await DHTRecordPool.instance();

    final crypto = await getConversationCrypto();
    return (await pool.openRead(_localConversationRecordKey,
            parent: accountRecordKey, crypto: crypto))
        .scope((localConversation) async {
      //
      final update =
          await localConversation.getProtobuf(proto.Conversation.fromBuffer);
      if (update != null) {
        return update;
      }
      return null;
    });
  }

  Future<proto.Conversation?> writeLocalConversation({
    required proto.Conversation conversation,
  }) async {
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
    final pool = await DHTRecordPool.instance();

    final crypto = await getConversationCrypto();
    final writer = _activeAccountInfo.getConversationWriter();

    return (await pool.openWrite(_localConversationRecordKey, writer,
            parent: accountRecordKey, crypto: crypto))
        .scope((localConversation) async {
      //
      final update = await localConversation.tryWriteProtobuf(
          proto.Conversation.fromBuffer, conversation);
      if (update != null) {
        return update;
      }
      return null;
    });
  }

  Future<void> addLocalConversationMessage(
      {required proto.Message message}) async {
    final conversation = await readLocalConversation();
    if (conversation == null) {
      return;
    }
    final messagesRecordKey =
        proto.TypedKeyProto.fromProto(conversation.messages);
    final crypto = await getConversationCrypto();
    final writer = _activeAccountInfo.getConversationWriter();

    await (await DHTShortArray.openWrite(messagesRecordKey, writer,
            parent: _localConversationRecordKey, crypto: crypto))
        .scope((messages) async {
      await messages.tryAddItem(message.writeToBuffer());
    });
  }

  Future<bool> mergeLocalConversationMessages(
      {required IList<proto.Message> newMessages}) async {
    final conversation = await readLocalConversation();
    if (conversation == null) {
      return false;
    }
    var changed = false;
    final messagesRecordKey =
        proto.TypedKeyProto.fromProto(conversation.messages);
    final crypto = await getConversationCrypto();
    final writer = _activeAccountInfo.getConversationWriter();

    newMessages = newMessages.sort((a, b) => Timestamp.fromInt64(a.timestamp)
        .compareTo(Timestamp.fromInt64(b.timestamp)));

    await (await DHTShortArray.openWrite(messagesRecordKey, writer,
            parent: _localConversationRecordKey, crypto: crypto))
        .scope((messages) async {
      // Ensure newMessages is sorted by timestamp
      newMessages =
          newMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Existing messages will always be sorted by timestamp so merging is easy
      var pos = 0;
      outer:
      for (final newMessage in newMessages) {
        var skip = false;
        while (pos < messages.length) {
          final m =
              await messages.getItemProtobuf(proto.Message.fromBuffer, pos);
          if (m == null) {
            log.error('unable to get message #$pos');
            break outer;
          }

          // If timestamp to insert is less than
          // the current position, insert it here
          final newTs = Timestamp.fromInt64(newMessage.timestamp);
          final curTs = Timestamp.fromInt64(m.timestamp);
          final cmp = newTs.compareTo(curTs);
          if (cmp < 0) {
            break;
          } else if (cmp == 0) {
            skip = true;
            break;
          }
          pos++;
        }
        // Insert at this position
        if (!skip) {
          await messages.tryInsertItem(pos, newMessage.writeToBuffer());
          changed = true;
        }
      }
    });
    return changed;
  }

  Future<IList<proto.Message>?> getRemoteConversationMessages() async {
    final conversation = await readRemoteConversation();
    if (conversation == null) {
      return null;
    }
    final messagesRecordKey =
        proto.TypedKeyProto.fromProto(conversation.messages);
    final crypto = await getConversationCrypto();

    return (await DHTShortArray.openRead(messagesRecordKey,
            parent: _remoteConversationRecordKey, crypto: crypto))
        .scope((messages) async {
      var out = IList<proto.Message>();
      for (var i = 0; i < messages.length; i++) {
        final msg = await messages.getItemProtobuf(proto.Message.fromBuffer, i);
        if (msg == null) {
          throw Exception('Failed to get message');
        }
        out = out.add(msg);
      }
      return out;
    });
  }

  //

  Future<DHTRecordCrypto> getConversationCrypto() async {
    var conversationCrypto = _conversationCrypto;
    if (conversationCrypto != null) {
      return conversationCrypto;
    }
    final veilid = await eventualVeilid.future;
    final identitySecret = _activeAccountInfo.userLogin.identitySecret;
    final cs = await veilid.getCryptoSystem(identitySecret.kind);
    final sharedSecret =
        await cs.cachedDH(_remoteIdentityPublicKey.value, identitySecret.value);

    conversationCrypto = await DHTRecordCryptoPrivate.fromSecret(
        identitySecret.kind, sharedSecret);
    _conversationCrypto = conversationCrypto;
    return conversationCrypto;
  }

  Future<IList<proto.Message>?> getLocalConversationMessages() async {
    final conversation = await readLocalConversation();
    if (conversation == null) {
      return null;
    }
    final messagesRecordKey =
        proto.TypedKeyProto.fromProto(conversation.messages);
    final crypto = await getConversationCrypto();

    return (await DHTShortArray.openRead(messagesRecordKey,
            parent: _localConversationRecordKey, crypto: crypto))
        .scope((messages) async {
      var out = IList<proto.Message>();
      for (var i = 0; i < messages.length; i++) {
        final msg = await messages.getItemProtobuf(proto.Message.fromBuffer, i);
        if (msg == null) {
          throw Exception('Failed to get message');
        }
        out = out.add(msg);
      }
      return out;
    });
  }

  final ActiveAccountInfo _activeAccountInfo;
  final TypedKey _localConversationRecordKey;
  final TypedKey _remoteIdentityPublicKey;
  final TypedKey _remoteConversationRecordKey;
  //
  DHTRecordCrypto? _conversationCrypto;
}

// Create a conversation
// If we were the initiator of the conversation there may be an
// incomplete 'existingConversationRecord' that we need to fill
// in now that we have the remote identity key
Future<T> createConversation<T>(
    {required ActiveAccountInfo activeAccountInfo,
    required TypedKey remoteIdentityPublicKey,
    required FutureOr<T> Function(DHTRecord) callback,
    TypedKey? existingConversationRecordKey}) async {
  final pool = await DHTRecordPool.instance();
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  final writer = activeAccountInfo.getConversationWriter();

  // Open with SMPL scheme for identity writer
  late final DHTRecord localConversationRecord;
  if (existingConversationRecordKey != null) {
    localConversationRecord = await pool.openWrite(
        existingConversationRecordKey, writer,
        parent: accountRecordKey, crypto: crypto);
  } else {
    final localConversationRecordCreate = await pool.create(
        parent: accountRecordKey,
        crypto: crypto,
        schema: DHTSchema.smpl(
            oCnt: 0, members: [DHTSchemaMember(mKey: writer.key, mCnt: 1)]));
    await localConversationRecordCreate.close();
    localConversationRecord = await pool.openWrite(
        localConversationRecordCreate.key, writer,
        parent: accountRecordKey, crypto: crypto);
  }
  return localConversationRecord
      // ignore: prefer_expression_function_bodies
      .deleteScope((localConversation) async {
    // Make messages log
    return (await DHTShortArray.create(
            parent: localConversation.key, crypto: crypto, smplWriter: writer))
        .deleteScope((messages) async {
      // Write local conversation key
      final conversation = proto.Conversation()
        ..profile = activeAccountInfo.account.profile
        ..identityMasterJson =
            jsonEncode(activeAccountInfo.localAccount.identityMaster.toJson())
        ..messages = messages.record.key.toProto();

      //
      final update = await localConversation.tryWriteProtobuf(
          proto.Conversation.fromBuffer, conversation);
      if (update != null) {
        throw Exception('Failed to write local conversation');
      }
      return await callback(localConversation);
    });
  });
}

//
//
//
//

@riverpod
class ActiveConversationMessages extends _$ActiveConversationMessages {
  /// Get message for active conversation
  @override
  FutureOr<IList<proto.Message>?> build() async {
    await eventualVeilid.future;

    final activeChat = ref.watch(activeChatStateProvider);
    if (activeChat == null) {
      return null;
    }

    final activeAccountInfo =
        await ref.watch(fetchActiveAccountProvider.future);
    if (activeAccountInfo == null) {
      return null;
    }

    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    final activeChatContactIdx = contactList.indexWhere(
      (c) =>
          proto.TypedKeyProto.fromProto(c.remoteConversationRecordKey) ==
          activeChat,
    );
    if (activeChatContactIdx == -1) {
      return null;
    }
    final activeChatContact = contactList[activeChatContactIdx];
    final remoteIdentityPublicKey =
        proto.TypedKeyProto.fromProto(activeChatContact.identityPublicKey);
    // final remoteConversationRecordKey = proto.TypedKeyProto.fromProto(
    //     activeChatContact.remoteConversationRecordKey);
    final localConversationRecordKey = proto.TypedKeyProto.fromProto(
        activeChatContact.localConversationRecordKey);

    return await getLocalConversationMessages(
      activeAccountInfo: activeAccountInfo,
      localConversationRecordKey: localConversationRecordKey,
      remoteIdentityPublicKey: remoteIdentityPublicKey,
    );
  }
}
