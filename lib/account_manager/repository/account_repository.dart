import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../proto/proto.dart' as proto;
import '../../tools/tools.dart';
import '../models/models.dart';

const String veilidChatAccountKey = 'com.veilid.veilidchat';

enum AccountRepositoryChange { localAccounts, userLogins, activeLocalAccount }

class AccountRepository {
  AccountRepository._()
      : _localAccounts = _initLocalAccounts(),
        _userLogins = _initUserLogins(),
        _activeLocalAccount = _initActiveAccount(),
        _streamController =
            StreamController<AccountRepositoryChange>.broadcast();

  static TableDBValue<IList<LocalAccount>> _initLocalAccounts() => TableDBValue(
      tableName: 'local_account_manager',
      tableKeyName: 'local_accounts',
      valueFromJson: (obj) => obj != null
          ? IList<LocalAccount>.fromJson(
              obj, genericFromJson(LocalAccount.fromJson))
          : IList<LocalAccount>(),
      valueToJson: (val) => val?.toJson((la) => la.toJson()),
      makeInitialValue: IList<LocalAccount>.empty);

  static TableDBValue<IList<UserLogin>> _initUserLogins() => TableDBValue(
      tableName: 'local_account_manager',
      tableKeyName: 'user_logins',
      valueFromJson: (obj) => obj != null
          ? IList<UserLogin>.fromJson(obj, genericFromJson(UserLogin.fromJson))
          : IList<UserLogin>(),
      valueToJson: (val) => val?.toJson((la) => la.toJson()),
      makeInitialValue: IList<UserLogin>.empty);

  static TableDBValue<TypedKey?> _initActiveAccount() => TableDBValue(
      tableName: 'local_account_manager',
      tableKeyName: 'active_local_account',
      valueFromJson: (obj) => obj == null ? null : TypedKey.fromJson(obj),
      valueToJson: (val) => val?.toJson(),
      makeInitialValue: () => null);

  Future<void> init() async {
    await _localAccounts.get();
    await _userLogins.get();
    await _activeLocalAccount.get();
  }

  Future<void> close() async {
    await _localAccounts.close();
    await _userLogins.close();
    await _activeLocalAccount.close();
  }

  //////////////////////////////////////////////////////////////
  /// Public Interface
  ///
  Stream<AccountRepositoryChange> get stream => _streamController.stream;

  IList<LocalAccount> getLocalAccounts() => _localAccounts.value;
  TypedKey? getActiveLocalAccount() => _activeLocalAccount.value;
  IList<UserLogin> getUserLogins() => _userLogins.value;
  UserLogin? getActiveUserLogin() {
    final activeLocalAccount = _activeLocalAccount.value;
    return activeLocalAccount == null
        ? null
        : fetchUserLogin(activeLocalAccount);
  }

  LocalAccount? fetchLocalAccount(TypedKey accountSuperIdentityRecordKey) {
    final localAccounts = _localAccounts.value;
    final idx = localAccounts.indexWhere(
        (e) => e.superIdentity.recordKey == accountSuperIdentityRecordKey);
    if (idx == -1) {
      return null;
    }
    return localAccounts[idx];
  }

  UserLogin? fetchUserLogin(TypedKey superIdentityRecordKey) {
    final userLogins = _userLogins.value;
    final idx = userLogins
        .indexWhere((e) => e.superIdentityRecordKey == superIdentityRecordKey);
    if (idx == -1) {
      return null;
    }
    return userLogins[idx];
  }

  AccountInfo? getAccountInfo(TypedKey superIdentityRecordKey) {
    // Get active account if we have one
    final activeLocalAccount = getActiveLocalAccount();
    final active = superIdentityRecordKey == activeLocalAccount;

    // Get which local account we want to fetch the profile for
    final localAccount = fetchLocalAccount(superIdentityRecordKey);
    if (localAccount == null) {
      return null;
    }

    // See if we've logged into this account or if it is locked
    final userLogin = fetchUserLogin(superIdentityRecordKey);
    if (userLogin == null) {
      // Account was locked
      return AccountInfo(
        status: AccountInfoStatus.accountLocked,
        active: active,
        localAccount: localAccount,
        userLogin: null,
      );
    }

    // Got account, decrypted and decoded
    return AccountInfo(
      status: AccountInfoStatus.accountUnlocked,
      active: active,
      localAccount: localAccount,
      userLogin: userLogin,
    );
  }

  /// Reorder accounts
  Future<void> reorderAccount(int oldIndex, int newIndex) async {
    final localAccounts = await _localAccounts.get();
    final removedItem = Output<LocalAccount>();
    final updated = localAccounts
        .removeAt(oldIndex, removedItem)
        .insert(newIndex, removedItem.value!);
    await _localAccounts.set(updated);
    _streamController.add(AccountRepositoryChange.localAccounts);
  }

  /// Creates a new super identity, an identity instance, an account associated
  /// with the identity instance, stores the account in the identity key and
  /// then logs into that account with no password set at this time
  Future<SecretKey> createWithNewSuperIdentity(proto.Profile newProfile) async {
    log.debug('Creating super identity');
    final wsi = await WritableSuperIdentity.create();
    try {
      final localAccount = await _newLocalAccount(
          superIdentity: wsi.superIdentity,
          identitySecret: wsi.identitySecret,
          newProfile: newProfile);

      // Log in the new account by default with no pin
      final ok = await login(
          localAccount.superIdentity.recordKey, EncryptionKeyType.none, '');
      assert(ok, 'login with none should never fail');

      return wsi.superSecret;
    } on Exception catch (_) {
      await wsi.delete();
      rethrow;
    }
  }

  Future<void> editAccountProfile(
      TypedKey superIdentityRecordKey, proto.Profile newProfile) async {
    log.debug('Editing profile for $superIdentityRecordKey');

    final localAccounts = await _localAccounts.get();

    final newLocalAccounts = localAccounts.replaceFirstWhere(
        (x) => x.superIdentity.recordKey == superIdentityRecordKey,
        (localAccount) => localAccount!.copyWith(name: newProfile.name));

    await _localAccounts.set(newLocalAccounts);
    _streamController.add(AccountRepositoryChange.localAccounts);
  }

  /// Remove an account and wipe the messages for this account from this device
  Future<bool> deleteLocalAccount(TypedKey superIdentityRecordKey) async {
    await logout(superIdentityRecordKey);

    final localAccounts = await _localAccounts.get();
    final newLocalAccounts = localAccounts.removeWhere(
        (la) => la.superIdentity.recordKey == superIdentityRecordKey);

    await _localAccounts.set(newLocalAccounts);
    _streamController.add(AccountRepositoryChange.localAccounts);

    // TO DO: wipe messages

    return true;
  }

  /// Import an account from another VeilidChat instance

  /// Recover an account with the master identity secret

  /// Delete an account from all devices

  Future<void> switchToAccount(TypedKey? superIdentityRecordKey) async {
    final activeLocalAccount = await _activeLocalAccount.get();

    if (activeLocalAccount == superIdentityRecordKey) {
      // Nothing to do
      return;
    }

    if (superIdentityRecordKey != null) {
      // Assert the specified record key can be found, will throw if not
      final _ = _userLogins.value.firstWhere(
          (ul) => ul.superIdentityRecordKey == superIdentityRecordKey);
    }
    await _activeLocalAccount.set(superIdentityRecordKey);
    _streamController.add(AccountRepositoryChange.activeLocalAccount);
  }

  //////////////////////////////////////////////////////////////
  /// Internal Implementation

  /// Creates a new Account associated with the current instance of the identity
  /// Adds a logged-out LocalAccount to track its existence on this device
  Future<LocalAccount> _newLocalAccount(
      {required SuperIdentity superIdentity,
      required SecretKey identitySecret,
      required proto.Profile newProfile,
      EncryptionKeyType encryptionKeyType = EncryptionKeyType.none,
      String encryptionKey = ''}) async {
    log.debug('Creating new local account');

    final localAccounts = await _localAccounts.get();

    // Add account with profile to DHT
    await superIdentity.currentInstance.addAccount(
        superRecordKey: superIdentity.recordKey,
        secretKey: identitySecret,
        accountKey: veilidChatAccountKey,
        createAccountCallback: (parent) async {
          // Make empty contact list
          log.debug('Creating contacts list');
          final contactList = await (await DHTShortArray.create(
                  debugName: 'AccountRepository::_newLocalAccount::Contacts',
                  parent: parent))
              .scope((r) async => r.recordPointer);

          // Make empty contact invitation record list
          log.debug('Creating contact invitation records list');
          final contactInvitationRecords = await (await DHTShortArray.create(
                  debugName:
                      'AccountRepository::_newLocalAccount::ContactInvitations',
                  parent: parent))
              .scope((r) async => r.recordPointer);

          // Make empty chat record list
          log.debug('Creating chat records list');
          final chatRecords = await (await DHTShortArray.create(
                  debugName: 'AccountRepository::_newLocalAccount::Chats',
                  parent: parent))
              .scope((r) async => r.recordPointer);

          // Make account object
          final account = proto.Account()
            ..profile = newProfile
            ..contactList = contactList.toProto()
            ..contactInvitationRecords = contactInvitationRecords.toProto()
            ..chatList = chatRecords.toProto();
          return account.writeToBuffer();
        });

    // Encrypt identitySecret with key
    final identitySecretBytes = await encryptionKeyType.encryptSecretToBytes(
      secret: identitySecret,
      cryptoKind: superIdentity.currentInstance.recordKey.kind,
      encryptionKey: encryptionKey,
    );

    // Create local account object
    // Does not contain the account key or its secret
    // as that is not to be persisted, and only pulled from the identity key
    // and optionally decrypted with the unlock password
    final localAccount = LocalAccount(
      superIdentity: superIdentity,
      identitySecretBytes: identitySecretBytes,
      encryptionKeyType: encryptionKeyType,
      biometricsEnabled: false,
      hiddenAccount: false,
      name: newProfile.name,
    );

    // Add local account object to internal store
    final newLocalAccounts = localAccounts.add(localAccount);

    await _localAccounts.set(newLocalAccounts);
    _streamController.add(AccountRepositoryChange.localAccounts);

    // Return local account object
    return localAccount;
  }

  Future<bool> _decryptedLogin(
      SuperIdentity superIdentity, SecretKey identitySecret) async {
    // Verify identity secret works and return the valid cryptosystem
    final cs = await superIdentity.currentInstance
        .validateIdentitySecret(identitySecret);

    // Read the identity key to get the account keys
    final accountRecordInfoList = await superIdentity.currentInstance
        .readAccount(
            superRecordKey: superIdentity.recordKey,
            secretKey: identitySecret,
            accountKey: veilidChatAccountKey);
    if (accountRecordInfoList.length > 1) {
      throw IdentityException.limitExceeded;
    } else if (accountRecordInfoList.isEmpty) {
      throw IdentityException.noAccount;
    }
    final accountRecordInfo = accountRecordInfoList.single;

    // Add to user logins and select it
    final userLogins = await _userLogins.get();
    final now = Veilid.instance.now();
    final newUserLogins = userLogins.replaceFirstWhere(
        (ul) => ul.superIdentityRecordKey == superIdentity.recordKey,
        (ul) => ul != null
            ? ul.copyWith(lastActive: now)
            : UserLogin(
                superIdentityRecordKey: superIdentity.recordKey,
                identitySecret:
                    TypedSecret(kind: cs.kind(), value: identitySecret),
                accountRecordInfo: accountRecordInfo,
                lastActive: now),
        addIfNotFound: true);

    await _userLogins.set(newUserLogins);
    await _activeLocalAccount.set(superIdentity.recordKey);

    _streamController
      ..add(AccountRepositoryChange.userLogins)
      ..add(AccountRepositoryChange.activeLocalAccount);

    return true;
  }

  Future<bool> login(TypedKey accountSuperRecordKey,
      EncryptionKeyType encryptionKeyType, String encryptionKey) async {
    final localAccounts = await _localAccounts.get();

    // Get account, throws if not found
    final localAccount = localAccounts.firstWhere(
        (la) => la.superIdentity.recordKey == accountSuperRecordKey);

    // Log in with this local account

    // Derive key from password
    if (localAccount.encryptionKeyType != encryptionKeyType) {
      throw Exception('Wrong authentication type');
    }

    final identitySecret =
        await localAccount.encryptionKeyType.decryptSecretFromBytes(
      secretBytes: localAccount.identitySecretBytes,
      cryptoKind: localAccount.superIdentity.currentInstance.recordKey.kind,
      encryptionKey: encryptionKey,
    );

    // Validate this secret with the identity public key and log in
    return _decryptedLogin(localAccount.superIdentity, identitySecret);
  }

  Future<void> logout(TypedKey? accountMasterRecordKey) async {
    // Resolve which user to log out
    final activeLocalAccount = await _activeLocalAccount.get();
    final logoutUser = accountMasterRecordKey ?? activeLocalAccount;
    if (logoutUser == null) {
      log.error('missing user in logout: $accountMasterRecordKey');
      return;
    }

    final logoutUserLogin = fetchUserLogin(logoutUser);
    if (logoutUserLogin == null) {
      // Already logged out
      return;
    }

    // Remove user from active logins list
    final newUserLogins = (await _userLogins.get())
        .removeWhere((ul) => ul.superIdentityRecordKey == logoutUser);
    await _userLogins.set(newUserLogins);
    _streamController.add(AccountRepositoryChange.userLogins);
  }

  //////////////////////////////////////////////////////////////
  /// Fields

  static AccountRepository instance = AccountRepository._();

  final TableDBValue<IList<LocalAccount>> _localAccounts;
  final TableDBValue<IList<UserLogin>> _userLogins;
  final TableDBValue<TypedKey?> _activeLocalAccount;
  final StreamController<AccountRepositoryChange> _streamController;
}
