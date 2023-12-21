// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_invitation_list_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactInvitationListManagerHash() =>
    r'8dda8e5005f0c0c921e3e8b7ce06e54bb5682085';

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

abstract class _$ContactInvitationListManager
    extends BuildlessAutoDisposeAsyncNotifier<
        IList<proto.ContactInvitationRecord>> {
  late final ActiveAccountInfo activeAccountInfo;

  FutureOr<IList<proto.ContactInvitationRecord>> build(
    ActiveAccountInfo activeAccountInfo,
  );
}

//////////////////////////////////////////////////
//////////////////////////////////////////////////
///
/// Copied from [ContactInvitationListManager].
@ProviderFor(ContactInvitationListManager)
const contactInvitationListManagerProvider =
    ContactInvitationListManagerFamily();

//////////////////////////////////////////////////
//////////////////////////////////////////////////
///
/// Copied from [ContactInvitationListManager].
class ContactInvitationListManagerFamily
    extends Family<AsyncValue<IList<proto.ContactInvitationRecord>>> {
  //////////////////////////////////////////////////
//////////////////////////////////////////////////
  ///
  /// Copied from [ContactInvitationListManager].
  const ContactInvitationListManagerFamily();

  //////////////////////////////////////////////////
//////////////////////////////////////////////////
  ///
  /// Copied from [ContactInvitationListManager].
  ContactInvitationListManagerProvider call(
    ActiveAccountInfo activeAccountInfo,
  ) {
    return ContactInvitationListManagerProvider(
      activeAccountInfo,
    );
  }

  @override
  ContactInvitationListManagerProvider getProviderOverride(
    covariant ContactInvitationListManagerProvider provider,
  ) {
    return call(
      provider.activeAccountInfo,
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
  String? get name => r'contactInvitationListManagerProvider';
}

//////////////////////////////////////////////////
//////////////////////////////////////////////////
///
/// Copied from [ContactInvitationListManager].
class ContactInvitationListManagerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ContactInvitationListManager,
        IList<proto.ContactInvitationRecord>> {
  //////////////////////////////////////////////////
//////////////////////////////////////////////////
  ///
  /// Copied from [ContactInvitationListManager].
  ContactInvitationListManagerProvider(
    ActiveAccountInfo activeAccountInfo,
  ) : this._internal(
          () => ContactInvitationListManager()
            ..activeAccountInfo = activeAccountInfo,
          from: contactInvitationListManagerProvider,
          name: r'contactInvitationListManagerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contactInvitationListManagerHash,
          dependencies: ContactInvitationListManagerFamily._dependencies,
          allTransitiveDependencies:
              ContactInvitationListManagerFamily._allTransitiveDependencies,
          activeAccountInfo: activeAccountInfo,
        );

  ContactInvitationListManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.activeAccountInfo,
  }) : super.internal();

  final ActiveAccountInfo activeAccountInfo;

  @override
  FutureOr<IList<proto.ContactInvitationRecord>> runNotifierBuild(
    covariant ContactInvitationListManager notifier,
  ) {
    return notifier.build(
      activeAccountInfo,
    );
  }

  @override
  Override overrideWith(ContactInvitationListManager Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContactInvitationListManagerProvider._internal(
        () => create()..activeAccountInfo = activeAccountInfo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        activeAccountInfo: activeAccountInfo,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ContactInvitationListManager,
      IList<proto.ContactInvitationRecord>> createElement() {
    return _ContactInvitationListManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactInvitationListManagerProvider &&
        other.activeAccountInfo == activeAccountInfo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, activeAccountInfo.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ContactInvitationListManagerRef on AutoDisposeAsyncNotifierProviderRef<
    IList<proto.ContactInvitationRecord>> {
  /// The parameter `activeAccountInfo` of this provider.
  ActiveAccountInfo get activeAccountInfo;
}

class _ContactInvitationListManagerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        ContactInvitationListManager, IList<proto.ContactInvitationRecord>>
    with ContactInvitationListManagerRef {
  _ContactInvitationListManagerProviderElement(super.provider);

  @override
  ActiveAccountInfo get activeAccountInfo =>
      (origin as ContactInvitationListManagerProvider).activeAccountInfo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
