// A Conversation is a type of Chat that is 1:1 between two Contacts only
// Each Contact in the ContactList has at most one Conversation between the
// remote contact and the local account

import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

@immutable
class ConversationState extends Equatable {
  const ConversationState(
      {required this.localConversation, required this.remoteConversation});

  final proto.Conversation? localConversation;
  final proto.Conversation? remoteConversation;

  @override
  List<Object?> get props => [localConversation, remoteConversation];
}

class ConversationCubit extends Cubit<AsyncValue<ConversationState>> {
  ConversationCubit(
      {required ActiveAccountInfo activeAccountInfo,
      required TypedKey remoteIdentityPublicKey,
      TypedKey? localConversationRecordKey,
      TypedKey? remoteConversationRecordKey})
      : _activeAccountInfo = activeAccountInfo,
        _localConversationRecordKey = localConversationRecordKey,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _remoteConversationRecordKey = remoteConversationRecordKey,
        _incrementalState = const ConversationState(
            localConversation: null, remoteConversation: null),
        super(const AsyncValue.loading()) {
    if (_localConversationRecordKey != null) {
      Future.delayed(Duration.zero, () async {
        final accountRecordKey = _activeAccountInfo
            .userLogin.accountRecordInfo.accountRecord.recordKey;

        // Open local record key if it is specified
        final pool = DHTRecordPool.instance;
        final crypto = await getConversationCrypto();
        final writer = _activeAccountInfo.conversationWriter;
        final record = await pool.openWrite(
            _localConversationRecordKey!, writer,
            parent: accountRecordKey, crypto: crypto);
        await _setLocalConversation(record);
      });
    }

    if (_remoteConversationRecordKey != null) {
      Future.delayed(Duration.zero, () async {
        final accountRecordKey = _activeAccountInfo
            .userLogin.accountRecordInfo.accountRecord.recordKey;

        // Open remote record key if it is specified
        final pool = DHTRecordPool.instance;
        final crypto = await getConversationCrypto();
        final record = await pool.openRead(_remoteConversationRecordKey!,
            parent: accountRecordKey, crypto: crypto);
        await _setRemoteConversation(record);
      });
    }
  }

  @override
  Future<void> close() async {
    await super.close();
  }

  // Open local converation key
  Future<void> _setLocalConversation(DHTRecord localConversationRecord) async {
    _localConversationCubit = DefaultDHTRecordCubit.value(
        record: localConversationRecord,
        decodeState: proto.Conversation.fromBuffer);
    _localConversationCubit!.stream.listen((avconv) {
      final newState = avconv.when(
        data: (conv) {
          _incrementalState = ConversationState(
              localConversation: conv,
              remoteConversation: _incrementalState.remoteConversation);
          // return loading still if state isn't complete
          if ((_localConversationRecordKey != null &&
                  _incrementalState.localConversation == null) ||
              (_remoteConversationRecordKey != null &&
                  _incrementalState.remoteConversation == null)) {
            return const AsyncValue<ConversationState>.loading();
          }
          // state is complete, all required keys are open
          return AsyncValue.data(_incrementalState);
        },
        loading: AsyncValue<ConversationState>.loading,
        error: AsyncValue<ConversationState>.error,
      );
      emit(newState);
    });
  }

  // Open remote converation key
  Future<void> _setRemoteConversation(
      DHTRecord remoteConversationRecord) async {
    _remoteConversationCubit = DefaultDHTRecordCubit.value(
        record: remoteConversationRecord,
        decodeState: proto.Conversation.fromBuffer);
    _remoteConversationCubit!.stream.listen((avconv) {
      final newState = avconv.when(
        data: (conv) {
          _incrementalState = ConversationState(
              localConversation: _incrementalState.localConversation,
              remoteConversation: conv);
          // return loading still if state isn't complete
          if ((_localConversationRecordKey != null &&
                  _incrementalState.localConversation == null) ||
              (_remoteConversationRecordKey != null &&
                  _incrementalState.remoteConversation == null)) {
            return const AsyncValue<ConversationState>.loading();
          }
          // state is complete, all required keys are open
          return AsyncValue.data(_incrementalState);
        },
        loading: AsyncValue<ConversationState>.loading,
        error: AsyncValue<ConversationState>.error,
      );
      emit(newState);
    });
  }

  // Initialize a local conversation
  // If we were the initiator of the conversation there may be an
  // incomplete 'existingConversationRecord' that we need to fill
  // in now that we have the remote identity key
  // The ConversationCubit must not already have a local conversation
  Future<T> initLocalConversation<T>(
      {required proto.Profile profile,
      required FutureOr<T> Function(DHTRecord) callback,
      TypedKey? existingConversationRecordKey}) async {
    assert(_localConversationRecordKey == null,
        'must not have a local conversation yet');

    final pool = DHTRecordPool.instance;
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final crypto = await getConversationCrypto();
    final writer = _activeAccountInfo.conversationWriter;

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
    final out = localConversationRecord
        // ignore: prefer_expression_function_bodies
        .deleteScope((localConversation) async {
      // Make messages log
      return (await DHTShortArray.create(
              parent: localConversation.key,
              crypto: crypto,
              smplWriter: writer))
          .deleteScope((messages) async {
        // Write local conversation key
        final conversation = proto.Conversation()
          ..profile = profile
          ..identityMasterJson = jsonEncode(
              _activeAccountInfo.localAccount.identityMaster.toJson())
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

    // If success, save the new local conversation record key in this object
    _localConversationRecordKey = localConversationRecord.key;
    await _setLocalConversation(localConversationRecord);

    return out;
  }

  // Force refresh of conversation keys
  Future<void> refresh() async {
    if (_localConversationCubit != null) {
      xxx use defaultdhtrecordcubit refresh mechanism
    }
  }

  // Future<proto.Conversation?> readRemoteConversation() async {
  //   final accountRecordKey =
  //       _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  //   final pool = DHTRecordPool.instance;

  //   final crypto = await getConversationCrypto();
  //   return (await pool.openRead(_remoteConversationRecordKey!,
  //           parent: accountRecordKey, crypto: crypto))
  //       .scope((remoteConversation) async {
  //     //
  //     final conversation =
  //         await remoteConversation.getProtobuf(proto.Conversation.fromBuffer);
  //     return conversation;
  //   });
  // }

  // Future<proto.Conversation?> readLocalConversation() async {
  //   final accountRecordKey =
  //       _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  //   final pool = DHTRecordPool.instance;

  //   final crypto = await getConversationCrypto();
  //   return (await pool.openRead(_localConversationRecordKey!,
  //           parent: accountRecordKey, crypto: crypto))
  //       .scope((localConversation) async {
  //     //
  //     final update =
  //         await localConversation.getProtobuf(proto.Conversation.fromBuffer);
  //     if (update != null) {
  //       return update;
  //     }
  //     return null;
  //   });
  // }

  // Future<proto.Conversation?> writeLocalConversation({
  //   required proto.Conversation conversation,
  // }) async {
  //   final accountRecordKey =
  //       _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  //   final pool = DHTRecordPool.instance;

  //   final crypto = await getConversationCrypto();
  //   final writer = _activeAccountInfo.conversationWriter;

  //   return (await pool.openWrite(_localConversationRecordKey!, writer,
  //           parent: accountRecordKey, crypto: crypto))
  //       .scope((localConversation) async {
  //     //
  //     final update = await localConversation.tryWriteProtobuf(
  //         proto.Conversation.fromBuffer, conversation);
  //     if (update != null) {
  //       return update;
  //     }
  //     return null;
  //   });
  // }

  //

  Future<DHTRecordCrypto> getConversationCrypto() async {
    var conversationCrypto = _conversationCrypto;
    if (conversationCrypto != null) {
      return conversationCrypto;
    }
    final identitySecret = _activeAccountInfo.userLogin.identitySecret;
    final cs = await Veilid.instance.getCryptoSystem(identitySecret.kind);
    final sharedSecret =
        await cs.cachedDH(_remoteIdentityPublicKey.value, identitySecret.value);

    conversationCrypto = await DHTRecordCryptoPrivate.fromSecret(
        identitySecret.kind, sharedSecret);
    _conversationCrypto = conversationCrypto;
    return conversationCrypto;
  }

  final ActiveAccountInfo _activeAccountInfo;
  final TypedKey _remoteIdentityPublicKey;
  TypedKey? _localConversationRecordKey;
  TypedKey? _remoteConversationRecordKey;
  DefaultDHTRecordCubit<proto.Conversation>? _localConversationCubit;
  DefaultDHTRecordCubit<proto.Conversation>? _remoteConversationCubit;
  ConversationState _incrementalState;
  //
  DHTRecordCrypto? _conversationCrypto;
}
