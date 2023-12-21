// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchAccountInfoHash() => r'3d2e3b3ddce5158d03bceaf82cdb35bae000280c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Get an account from the identity key and if it is logged in and we
/// have its secret available, return the account record contents
///
/// Copied from [fetchAccountInfo].
@ProviderFor(fetchAccountInfo)
const fetchAccountInfoProvider = FetchAccountInfoFamily();

/// Get an account from the identity key and if it is logged in and we
/// have its secret available, return the account record contents
///
/// Copied from [fetchAccountInfo].
class FetchAccountInfoFamily extends Family<AsyncValue<AccountInfo>> {
  /// Get an account from the identity key and if it is logged in and we
  /// have its secret available, return the account record contents
  ///
  /// Copied from [fetchAccountInfo].
  const FetchAccountInfoFamily();

  /// Get an account from the identity key and if it is logged in and we
  /// have its secret available, return the account record contents
  ///
  /// Copied from [fetchAccountInfo].
  FetchAccountInfoProvider call({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) {
    return FetchAccountInfoProvider(
      accountMasterRecordKey: accountMasterRecordKey,
    );
  }

  @override
  FetchAccountInfoProvider getProviderOverride(
    covariant FetchAccountInfoProvider provider,
  ) {
    return call(
      accountMasterRecordKey: provider.accountMasterRecordKey,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchAccountInfoProvider';
}

/// Get an account from the identity key and if it is logged in and we
/// have its secret available, return the account record contents
///
/// Copied from [fetchAccountInfo].
class FetchAccountInfoProvider extends AutoDisposeFutureProvider<AccountInfo> {
  /// Get an account from the identity key and if it is logged in and we
  /// have its secret available, return the account record contents
  ///
  /// Copied from [fetchAccountInfo].
  FetchAccountInfoProvider({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) : this._internal(
          (ref) => fetchAccountInfo(
            ref as FetchAccountInfoRef,
            accountMasterRecordKey: accountMasterRecordKey,
          ),
          from: fetchAccountInfoProvider,
          name: r'fetchAccountInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchAccountInfoHash,
          dependencies: FetchAccountInfoFamily._dependencies,
          allTransitiveDependencies:
              FetchAccountInfoFamily._allTransitiveDependencies,
          accountMasterRecordKey: accountMasterRecordKey,
        );

  FetchAccountInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.accountMasterRecordKey,
  }) : super.internal();

  final Typed<FixedEncodedString43> accountMasterRecordKey;

  @override
  Override overrideWith(
    FutureOr<AccountInfo> Function(FetchAccountInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchAccountInfoProvider._internal(
        (ref) => create(ref as FetchAccountInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        accountMasterRecordKey: accountMasterRecordKey,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AccountInfo> createElement() {
    return _FetchAccountInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchAccountInfoProvider &&
        other.accountMasterRecordKey == accountMasterRecordKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountMasterRecordKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FetchAccountInfoRef on AutoDisposeFutureProviderRef<AccountInfo> {
  /// The parameter `accountMasterRecordKey` of this provider.
  Typed<FixedEncodedString43> get accountMasterRecordKey;
}

class _FetchAccountInfoProviderElement
    extends AutoDisposeFutureProviderElement<AccountInfo>
    with FetchAccountInfoRef {
  _FetchAccountInfoProviderElement(super.provider);

  @override
  Typed<FixedEncodedString43> get accountMasterRecordKey =>
      (origin as FetchAccountInfoProvider).accountMasterRecordKey;
}

String _$fetchActiveAccountInfoHash() =>
    r'85276ff85b0e82c8d3c6313250954f5b578697d1';

/// Get the active account info
///
/// Copied from [fetchActiveAccountInfo].
@ProviderFor(fetchActiveAccountInfo)
final fetchActiveAccountInfoProvider =
    AutoDisposeFutureProvider<ActiveAccountInfo?>.internal(
  fetchActiveAccountInfo,
  name: r'fetchActiveAccountInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchActiveAccountInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchActiveAccountInfoRef
    = AutoDisposeFutureProviderRef<ActiveAccountInfo?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
