// A Conversation is a type of Chat that is 1:1 between two Contacts only
// Each Contact in the ContactList has at most one Conversation between the
// remote contact and the local account

import 'dart:async';
import 'dart:convert';

import 'package:async_tools/async_tools.dart';
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
        await _setLocalConversation(() async {
          final accountRecordKey = _activeAccountInfo
              .userLogin.accountRecordInfo.accountRecord.recordKey;

          // Open local record key if it is specified
          final pool = DHTRecordPool.instance;
          final crypto = await _cachedConversationCrypto();
          final writer = _activeAccountInfo.conversationWriter;
          final record = await pool.openWrite(
              _localConversationRecordKey!, writer,
              parent: accountRecordKey, crypto: crypto);
          return record;
        });
      });
    }

    if (_remoteConversationRecordKey != null) {
      Future.delayed(Duration.zero, () async {
        await _setRemoteConversation(() async {
          final accountRecordKey = _activeAccountInfo
              .userLogin.accountRecordInfo.accountRecord.recordKey;

          // Open remote record key if it is specified
          final pool = DHTRecordPool.instance;
          final crypto = await _cachedConversationCrypto();
          final record = await pool.openRead(_remoteConversationRecordKey,
              parent: accountRecordKey, crypto: crypto);
          return record;
        });
      });
    }
  }

  @override
  Future<void> close() async {
    await _localSubscription?.cancel();
    await _remoteSubscription?.cancel();
    await _localConversationCubit?.close();
    await _remoteConversationCubit?.close();

    await super.close();
  }

  void updateLocalConversationState(AsyncValue<proto.Conversation> avconv) {
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
  }

  void updateRemoteConversationState(AsyncValue<proto.Conversation> avconv) {
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
  }

  // Open local converation key
  Future<void> _setLocalConversation(Future<DHTRecord> Function() open) async {
    assert(_localConversationCubit == null,
        'shoud not set local conversation twice');
    _localConversationCubit = DefaultDHTRecordCubit(
        open: open, decodeState: proto.Conversation.fromBuffer);
    _localSubscription =
        _localConversationCubit!.stream.listen(updateLocalConversationState);
  }

  // Open remote converation key
  Future<void> _setRemoteConversation(Future<DHTRecord> Function() open) async {
    assert(_remoteConversationCubit == null,
        'shoud not set remote conversation twice');
    _remoteConversationCubit = DefaultDHTRecordCubit(
        open: open, decodeState: proto.Conversation.fromBuffer);
    _remoteSubscription =
        _remoteConversationCubit!.stream.listen(updateRemoteConversationState);
  }

  // Initialize a local conversation
  // If we were the initiator of the conversation there may be an
  // incomplete 'existingConversationRecord' that we need to fill
  // in now that we have the remote identity key
  // The ConversationCubit must not already have a local conversation
  // The callback allows for more initialization to occur and for
  // cleanup to delete records upon failure of the callback
  Future<T> initLocalConversation<T>(
      {required proto.Profile profile,
      required FutureOr<T> Function(DHTRecord) callback,
      TypedKey? existingConversationRecordKey}) async {
    assert(_localConversationRecordKey == null,
        'must not have a local conversation yet');

    final pool = DHTRecordPool.instance;
    final accountRecordKey =
        _activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

    final crypto = await _cachedConversationCrypto();
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
      return initLocalMessages(
          activeAccountInfo: _activeAccountInfo,
          remoteIdentityPublicKey: _remoteIdentityPublicKey,
          localConversationKey: localConversation.key,
          callback: (messages) async {
            // Create initial local conversation key contents
            final conversation = proto.Conversation()
              ..profile = profile
              ..identityMasterJson = jsonEncode(
                  _activeAccountInfo.localAccount.identityMaster.toJson())
              ..messages = messages.recordKey.toProto();

            // Write initial conversation to record
            final update = await localConversation.tryWriteProtobuf(
                proto.Conversation.fromBuffer, conversation);
            if (update != null) {
              throw Exception('Failed to write local conversation');
            }
            final out = await callback(localConversation);

            // Upon success emit the local conversation record to the state
            updateLocalConversationState(AsyncValue.data(conversation));

            return out;
          });
    });

    // If success, save the new local conversation record key in this object
    _localConversationRecordKey = localConversationRecord.key;
    await _setLocalConversation(() async => localConversationRecord);

    return out;
  }

  // Initialize local messages
  Future<T> initLocalMessages<T>({
    required ActiveAccountInfo activeAccountInfo,
    required TypedKey remoteIdentityPublicKey,
    required TypedKey localConversationKey,
    required FutureOr<T> Function(DHTShortArray) callback,
  }) async {
    final crypto =
        await activeAccountInfo.makeConversationCrypto(remoteIdentityPublicKey);
    final writer = activeAccountInfo.conversationWriter;

    return (await DHTShortArray.create(
            parent: localConversationKey, crypto: crypto, smplWriter: writer))
        .deleteScope((messages) async => await callback(messages));
  }

  // Force refresh of conversation keys
  Future<void> refresh() async {
    final lcc = _localConversationCubit;
    final rcc = _remoteConversationCubit;

    if (lcc != null) {
      await lcc.refreshDefault();
    }
    if (rcc != null) {
      await rcc.refreshDefault();
    }
  }

  Future<proto.Conversation?> writeLocalConversation({
    required proto.Conversation conversation,
  }) async {
    final update = await _localConversationCubit!.record
        .tryWriteProtobuf(proto.Conversation.fromBuffer, conversation);

    if (update != null) {
      updateLocalConversationState(AsyncValue.data(conversation));
    }

    return update;
  }

  Future<DHTRecordCrypto> _cachedConversationCrypto() async {
    var conversationCrypto = _conversationCrypto;
    if (conversationCrypto != null) {
      return conversationCrypto;
    }
    conversationCrypto = await _activeAccountInfo
        .makeConversationCrypto(_remoteIdentityPublicKey);

    _conversationCrypto = conversationCrypto;
    return conversationCrypto;
  }

  final ActiveAccountInfo _activeAccountInfo;
  final TypedKey _remoteIdentityPublicKey;
  TypedKey? _localConversationRecordKey;
  final TypedKey? _remoteConversationRecordKey;
  DefaultDHTRecordCubit<proto.Conversation>? _localConversationCubit;
  DefaultDHTRecordCubit<proto.Conversation>? _remoteConversationCubit;
  StreamSubscription<AsyncValue<proto.Conversation>>? _localSubscription;
  StreamSubscription<AsyncValue<proto.Conversation>>? _remoteSubscription;
  ConversationState _incrementalState;
  //
  DHTRecordCrypto? _conversationCrypto;
}
