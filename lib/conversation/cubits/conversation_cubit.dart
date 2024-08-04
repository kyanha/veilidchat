// A Conversation is a type of Chat that is 1:1 between two Contacts only
// Each Contact in the ContactList has at most one Conversation between the
// remote contact and the local account

import 'dart:async';
import 'dart:convert';

import 'package:async_tools/async_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

const _sfUpdateAccountChange = 'updateAccountChange';

@immutable
class ConversationState extends Equatable {
  const ConversationState(
      {required this.localConversation, required this.remoteConversation});

  final proto.Conversation? localConversation;
  final proto.Conversation? remoteConversation;

  @override
  List<Object?> get props => [localConversation, remoteConversation];
}

/// Represents the control channel between two contacts
/// Used to pass profile, identity and status changes, and the messages key for
/// 1-1 chats
class ConversationCubit extends Cubit<AsyncValue<ConversationState>> {
  ConversationCubit(
      {required AccountInfo accountInfo,
      required TypedKey remoteIdentityPublicKey,
      TypedKey? localConversationRecordKey,
      TypedKey? remoteConversationRecordKey})
      : _accountInfo = accountInfo,
        _localConversationRecordKey = localConversationRecordKey,
        _remoteIdentityPublicKey = remoteIdentityPublicKey,
        _remoteConversationRecordKey = remoteConversationRecordKey,
        super(const AsyncValue.loading()) {
    _identityWriter = _accountInfo.identityWriter;

    if (_localConversationRecordKey != null) {
      _initWait.add((_) async {
        await _setLocalConversation(() async {
          // Open local record key if it is specified
          final pool = DHTRecordPool.instance;
          final crypto = await _cachedConversationCrypto();
          final writer = _identityWriter;

          final record = await pool.openRecordWrite(
              _localConversationRecordKey!, writer,
              debugName: 'ConversationCubit::LocalConversation',
              parent: accountInfo.accountRecordKey,
              crypto: crypto);

          return record;
        });
      });
    }

    if (_remoteConversationRecordKey != null) {
      _initWait.add((cancel) async {
        await _setRemoteConversation(() async {
          // Open remote record key if it is specified
          final pool = DHTRecordPool.instance;
          final crypto = await _cachedConversationCrypto();

          final record = await pool.openRecordRead(_remoteConversationRecordKey,
              debugName: 'ConversationCubit::RemoteConversation',
              parent: pool.getParentRecordKey(_remoteConversationRecordKey) ??
                  accountInfo.accountRecordKey,
              crypto: crypto);

          return record;
        });
      });
    }
  }

  @override
  Future<void> close() async {
    await _initWait();
    await _accountSubscription?.cancel();
    await _localSubscription?.cancel();
    await _remoteSubscription?.cancel();
    await _localConversationCubit?.close();
    await _remoteConversationCubit?.close();

    await super.close();
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  /// Initialize a local conversation
  /// If we were the initiator of the conversation there may be an
  /// incomplete 'existingConversationRecord' that we need to fill
  /// in now that we have the remote identity key
  /// The ConversationCubit must not already have a local conversation
  /// The callback allows for more initialization to occur and for
  /// cleanup to delete records upon failure of the callback
  Future<T> initLocalConversation<T>(
      {required proto.Profile profile,
      required FutureOr<T> Function(DHTRecord) callback,
      TypedKey? existingConversationRecordKey}) async {
    assert(_localConversationRecordKey == null,
        'must not have a local conversation yet');

    final pool = DHTRecordPool.instance;

    final crypto = await _cachedConversationCrypto();
    final accountRecordKey = _accountInfo.accountRecordKey;
    final writer = _accountInfo.identityWriter;

    // Open with SMPL schema for identity writer
    late final DHTRecord localConversationRecord;
    if (existingConversationRecordKey != null) {
      localConversationRecord = await pool.openRecordWrite(
          existingConversationRecordKey, writer,
          debugName:
              'ConversationCubit::initLocalConversation::LocalConversation',
          parent: accountRecordKey,
          crypto: crypto);
    } else {
      localConversationRecord = await pool.createRecord(
          debugName:
              'ConversationCubit::initLocalConversation::LocalConversation',
          parent: accountRecordKey,
          crypto: crypto,
          writer: writer,
          schema: DHTSchema.smpl(
              oCnt: 0, members: [DHTSchemaMember(mKey: writer.key, mCnt: 1)]));
    }
    final out = localConversationRecord
        // ignore: prefer_expression_function_bodies
        .deleteScope((localConversation) async {
      // Make messages log
      return _initLocalMessages(
          localConversationKey: localConversation.key,
          callback: (messages) async {
            // Create initial local conversation key contents
            final conversation = proto.Conversation()
              ..profile = profile
              ..superIdentityJson =
                  jsonEncode(_accountInfo.localAccount.superIdentity.toJson())
              ..messages = messages.recordKey.toProto();

            // Write initial conversation to record
            final update = await localConversation.tryWriteProtobuf(
                proto.Conversation.fromBuffer, conversation);
            if (update != null) {
              throw Exception('Failed to write local conversation');
            }
            final out = await callback(localConversation);

            // Upon success emit the local conversation record to the state
            _updateLocalConversationState(AsyncValue.data(conversation));

            return out;
          });
    });

    // If success, save the new local conversation record key in this object
    _localConversationRecordKey = localConversationRecord.key;
    await _setLocalConversation(() async => localConversationRecord);

    return out;
  }

  /// Force refresh of conversation keys
  Future<void> refresh() async {
    await _initWait();

    final lcc = _localConversationCubit;
    final rcc = _remoteConversationCubit;

    if (lcc != null) {
      await lcc.refreshDefault();
    }
    if (rcc != null) {
      await rcc.refreshDefault();
    }
  }

  /// Watch for account record changes and update the conversation
  void watchAccountChanges(Stream<AsyncValue<proto.Account>> accountStream,
      AsyncValue<proto.Account> currentState) {
    assert(_accountSubscription == null, 'only watch account once');
    _accountSubscription = accountStream.listen(_updateAccountChange);
    _updateAccountChange(currentState);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Private Implementation

  void _updateAccountChange(AsyncValue<proto.Account> avaccount) {
    final account = avaccount.asData?.value;
    if (account == null) {
      return;
    }
    final cubit = _localConversationCubit;
    if (cubit == null) {
      return;
    }
    serialFuture((this, _sfUpdateAccountChange), () async {
      await cubit.record?.eventualUpdateProtobuf(proto.Conversation.fromBuffer,
          (old) async {
        if (old == null || old.profile == account.profile) {
          return null;
        }
        return old.deepCopy()..profile = account.profile;
      });
    });
  }

  void _updateLocalConversationState(AsyncValue<proto.Conversation> avconv) {
    final newState = avconv.when(
      data: (conv) {
        _incrementalState = ConversationState(
            localConversation: conv,
            remoteConversation: _incrementalState.remoteConversation);
        // return loading still if state isn't complete
        if (_localConversationRecordKey != null &&
            _incrementalState.localConversation == null) {
          return const AsyncValue<ConversationState>.loading();
        }
        // local state is complete, all remote state is emitted incrementally
        return AsyncValue.data(_incrementalState);
      },
      loading: AsyncValue<ConversationState>.loading,
      error: AsyncValue<ConversationState>.error,
    );
    emit(newState);
  }

  void _updateRemoteConversationState(AsyncValue<proto.Conversation> avconv) {
    final newState = avconv.when(
      data: (conv) {
        _incrementalState = ConversationState(
            localConversation: _incrementalState.localConversation,
            remoteConversation: conv);
        // return loading still if the local state isn't complete
        if (_localConversationRecordKey != null &&
            _incrementalState.localConversation == null) {
          return const AsyncValue<ConversationState>.loading();
        }
        // local state is complete, all remote state is emitted incrementally
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
        _localConversationCubit!.stream.listen(_updateLocalConversationState);
    _updateLocalConversationState(_localConversationCubit!.state);
  }

  // Open remote converation key
  Future<void> _setRemoteConversation(Future<DHTRecord> Function() open) async {
    assert(_remoteConversationCubit == null,
        'shoud not set remote conversation twice');
    _remoteConversationCubit = DefaultDHTRecordCubit(
        open: open, decodeState: proto.Conversation.fromBuffer);
    _remoteSubscription =
        _remoteConversationCubit!.stream.listen(_updateRemoteConversationState);
    _updateRemoteConversationState(_remoteConversationCubit!.state);
  }

  // Initialize local messages
  Future<T> _initLocalMessages<T>({
    required TypedKey localConversationKey,
    required FutureOr<T> Function(DHTLog) callback,
  }) async {
    final crypto = await _cachedConversationCrypto();
    final writer = _identityWriter;

    return (await DHTLog.create(
            debugName: 'ConversationCubit::initLocalMessages::LocalMessages',
            parent: localConversationKey,
            crypto: crypto,
            writer: writer))
        .deleteScope((messages) async => await callback(messages));
  }

  Future<VeilidCrypto> _cachedConversationCrypto() async {
    var conversationCrypto = _conversationCrypto;
    if (conversationCrypto != null) {
      return conversationCrypto;
    }
    conversationCrypto =
        await _accountInfo.makeConversationCrypto(_remoteIdentityPublicKey);
    _conversationCrypto = conversationCrypto;
    return conversationCrypto;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Fields
  TypedKey get remoteIdentityPublicKey => _remoteIdentityPublicKey;

  final AccountInfo _accountInfo;
  late final KeyPair _identityWriter;
  final TypedKey _remoteIdentityPublicKey;
  TypedKey? _localConversationRecordKey;
  final TypedKey? _remoteConversationRecordKey;
  DefaultDHTRecordCubit<proto.Conversation>? _localConversationCubit;
  DefaultDHTRecordCubit<proto.Conversation>? _remoteConversationCubit;
  StreamSubscription<AsyncValue<proto.Conversation>>? _localSubscription;
  StreamSubscription<AsyncValue<proto.Conversation>>? _remoteSubscription;
  StreamSubscription<AsyncValue<proto.Account>>? _accountSubscription;
  ConversationState _incrementalState = const ConversationState(
      localConversation: null, remoteConversation: null);
  VeilidCrypto? _conversationCrypto;
  final WaitSet<void, void> _initWait = WaitSet();
}
