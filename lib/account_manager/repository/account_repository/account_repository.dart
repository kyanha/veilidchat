import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../../proto/proto.dart' as proto;
import 'active_logins.dart';
import 'encryption_key_type.dart';
import 'local_account.dart';
import 'new_profile_spec.dart';
import 'user_login.dart';

export 'active_logins.dart';
export 'encryption_key_type.dart';
export 'local_account.dart';
export 'user_login.dart';

const String veilidChatAccountKey = 'com.veilid.veilidchat';

enum AccountRepositoryChange { localAccounts, userLogins, activeUserLogin }

class AccountRepository {
  AccountRepository._()
      : _localAccounts = _initLocalAccounts(),
        _activeLogins = _initActiveLogins();

  static TableDBValue<IList<LocalAccount>> _initLocalAccounts() => TableDBValue(
      tableName: 'local_account_manager',
      tableKeyName: 'local_accounts',
      valueFromJson: (obj) => obj != null
          ? IList<LocalAccount>.fromJson(
              obj, genericFromJson(LocalAccount.fromJson))
          : IList<LocalAccount>(),
      valueToJson: (val) => val.toJson((la) => la.toJson()));

  static TableDBValue<ActiveLogins> _initActiveLogins() => TableDBValue(
      tableName: 'local_account_manager',
      tableKeyName: 'active_logins',
      valueFromJson: (obj) => obj != null
          ? ActiveLogins.fromJson(obj as Map<String, dynamic>)
          : ActiveLogins.empty(),
      valueToJson: (val) => val.toJson());

  final TableDBValue<IList<LocalAccount>> _localAccounts;
  final TableDBValue<ActiveLogins> _activeLogins;

  //////////////////////////////////////////////////////////////
  /// Singleton initialization

  static AccountRepository instance = AccountRepository._();

  Future<void> init() async {
    await _localAccounts.load();
    await _activeLogins.load();
  }

  //////////////////////////////////////////////////////////////
  /// Streams

  Stream<AccountRepositoryChange> changes() async* {}

  //////////////////////////////////////////////////////////////
  /// Selectors
  IList<LocalAccount> getLocalAccounts() => _localAccounts.requireValue;
  IList<UserLogin> getUserLogins() => _activeLogins.requireValue.userLogins;
  TypedKey? getActiveUserLogin() => _activeLogins.requireValue.activeUserLogin;

  LocalAccount? fetchLocalAccount({required TypedKey accountMasterRecordKey}) {
    final localAccounts = _localAccounts.requireValue;
    final idx = localAccounts.indexWhere(
        (e) => e.identityMaster.masterRecordKey == accountMasterRecordKey);
    if (idx == -1) {
      return null;
    }
    return localAccounts[idx];
  }

  UserLogin? fetchLogin({required TypedKey accountMasterRecordKey}) {
    final userLogins = _activeLogins.requireValue.userLogins;
    final idx = userLogins
        .indexWhere((e) => e.accountMasterRecordKey == accountMasterRecordKey);
    if (idx == -1) {
      return null;
    }
    return userLogins[idx];
  }

  //////////////////////////////////////////////////////////////
  /// Mutators

  /// Reorder accounts
  Future<void> reorderAccount(int oldIndex, int newIndex) async {
    final localAccounts = await _localAccounts.get();
    final removedItem = Output<LocalAccount>();
    final updated = localAccounts
        .removeAt(oldIndex, removedItem)
        .insert(newIndex, removedItem.value!);
    await _localAccounts.set(updated);
  }

  /// Creates a new master identity, an account associated with the master
  /// identity, stores the account in the identity key and then logs into
  /// that account with no password set at this time
  Future<void> createMasterIdentity(NewProfileSpec newProfileSpec) async {
    final imws = await IdentityMasterWithSecrets.create();
    try {
      final localAccount = await _newLocalAccount(
          identityMaster: imws.identityMaster,
          identitySecret: imws.identitySecret,
          newProfileSpec: newProfileSpec);

      // Log in the new account by default with no pin
      final ok = await login(localAccount.identityMaster.masterRecordKey,
          EncryptionKeyType.none, '');
      assert(ok, 'login with none should never fail');
    } on Exception catch (_) {
      await imws.delete();
      rethrow;
    }
  }

  /// Creates a new Account associated with master identity
  /// Adds a logged-out LocalAccount to track its existence on this device
  Future<LocalAccount> _newLocalAccount(
      {required IdentityMaster identityMaster,
      required SecretKey identitySecret,
      required NewProfileSpec newProfileSpec,
      EncryptionKeyType encryptionKeyType = EncryptionKeyType.none,
      String encryptionKey = ''}) async {
    final localAccounts = await _localAccounts.get();

    // Add account with profile to DHT
    await identityMaster.addAccountToIdentity(
        identitySecret: identitySecret,
        accountKey: veilidChatAccountKey,
        createAccountCallback: (parent) async {
          // Make empty contact list
          final contactList = await (await DHTShortArray.create(parent: parent))
              .scope((r) async => r.record.ownedDHTRecordPointer);

          // Make empty contact invitation record list
          final contactInvitationRecords =
              await (await DHTShortArray.create(parent: parent))
                  .scope((r) async => r.record.ownedDHTRecordPointer);

          // Make empty chat record list
          final chatRecords = await (await DHTShortArray.create(parent: parent))
              .scope((r) async => r.record.ownedDHTRecordPointer);

          // Make account object
          final account = proto.Account()
            ..profile = (proto.Profile()
              ..name = newProfileSpec.name
              ..pronouns = newProfileSpec.pronouns)
            ..contactList = contactList.toProto()
            ..contactInvitationRecords = contactInvitationRecords.toProto()
            ..chatList = chatRecords.toProto();
          return account;
        });

    // Encrypt identitySecret with key
    final identitySecretBytes = await encryptionKeyType.encryptSecretToBytes(
      secret: identitySecret,
      cryptoKind: identityMaster.identityRecordKey.kind,
      encryptionKey: encryptionKey,
    );

    // Create local account object
    // Does not contain the account key or its secret
    // as that is not to be persisted, and only pulled from the identity key
    // and optionally decrypted with the unlock password
    final localAccount = LocalAccount(
      identityMaster: identityMaster,
      identitySecretBytes: identitySecretBytes,
      encryptionKeyType: encryptionKeyType,
      biometricsEnabled: false,
      hiddenAccount: false,
      name: newProfileSpec.name,
    );

    // Add local account object to internal store
    final newLocalAccounts = localAccounts.add(localAccount);

    await _localAccounts.set(newLocalAccounts);

    // Return local account object
    return localAccount;
  }

  /// Remove an account and wipe the messages for this account from this device
  Future<bool> deleteLocalAccount(TypedKey accountMasterRecordKey) async {
    await logout(accountMasterRecordKey);

    final localAccounts = await _localAccounts.get();
    final newLocalAccounts = localAccounts.removeWhere(
        (la) => la.identityMaster.masterRecordKey == accountMasterRecordKey);

    await _localAccounts.set(newLocalAccounts);

    // TO DO: wipe messages

    return true;
  }

  /// Import an account from another VeilidChat instance

  /// Recover an account with the master identity secret

  /// Delete an account from all devices

  Future<void> switchToAccount(TypedKey? accountMasterRecordKey) async {
    final activeLogins = await _activeLogins.get();

    if (accountMasterRecordKey != null) {
      // Assert the specified record key can be found, will throw if not
      final _ = activeLogins.userLogins.firstWhere(
          (ul) => ul.accountMasterRecordKey == accountMasterRecordKey);
    }
    final newActiveLogins =
        activeLogins.copyWith(activeUserLogin: accountMasterRecordKey);
    await _activeLogins.set(newActiveLogins);
  }

  Future<bool> _decryptedLogin(
      IdentityMaster identityMaster, SecretKey identitySecret) async {
    final cs = await Veilid.instance
        .getCryptoSystem(identityMaster.identityRecordKey.kind);
    final keyOk = await cs.validateKeyPair(
        identityMaster.identityPublicKey, identitySecret);
    if (!keyOk) {
      throw Exception('Identity is corrupted');
    }

    // Read the identity key to get the account keys
    final accountRecordInfo = await identityMaster.readAccountFromIdentity(
        identitySecret: identitySecret, accountKey: veilidChatAccountKey);

    // Add to user logins and select it
    final activeLogins = await _activeLogins.get();
    final now = Veilid.instance.now();
    final newActiveLogins = activeLogins.copyWith(
        userLogins: activeLogins.userLogins.replaceFirstWhere(
            (ul) => ul.accountMasterRecordKey == identityMaster.masterRecordKey,
            (ul) => ul != null
                ? ul.copyWith(lastActive: now)
                : UserLogin(
                    accountMasterRecordKey: identityMaster.masterRecordKey,
                    identitySecret:
                        TypedSecret(kind: cs.kind(), value: identitySecret),
                    accountRecordInfo: accountRecordInfo,
                    lastActive: now),
            addIfNotFound: true),
        activeUserLogin: identityMaster.masterRecordKey);
    await _activeLogins.set(newActiveLogins);

    return true;
  }

  Future<bool> login(TypedKey accountMasterRecordKey,
      EncryptionKeyType encryptionKeyType, String encryptionKey) async {
    final localAccounts = await _localAccounts.get();

    // Get account, throws if not found
    final localAccount = localAccounts.firstWhere(
        (la) => la.identityMaster.masterRecordKey == accountMasterRecordKey);

    // Log in with this local account

    // Derive key from password
    if (localAccount.encryptionKeyType != encryptionKeyType) {
      throw Exception('Wrong authentication type');
    }

    final identitySecret =
        await localAccount.encryptionKeyType.decryptSecretFromBytes(
      secretBytes: localAccount.identitySecretBytes,
      cryptoKind: localAccount.identityMaster.identityRecordKey.kind,
      encryptionKey: encryptionKey,
    );

    // Validate this secret with the identity public key and log in
    return _decryptedLogin(localAccount.identityMaster, identitySecret);
  }

  Future<void> logout(TypedKey? accountMasterRecordKey) async {
    final activeLogins = await _activeLogins.get();
    final logoutUser = accountMasterRecordKey ?? activeLogins.activeUserLogin;
    if (logoutUser == null) {
      return;
    }
    final newActiveLogins = activeLogins.copyWith(
        activeUserLogin: activeLogins.activeUserLogin == logoutUser
            ? null
            : activeLogins.activeUserLogin,
        userLogins: activeLogins.userLogins
            .removeWhere((ul) => ul.accountMasterRecordKey == logoutUser));
    await _activeLogins.set(newActiveLogins);
  }
}
