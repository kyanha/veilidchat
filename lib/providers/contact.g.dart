// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchContactListHash() => r'03e5b90435c331be87495d999a62a97af5b74d9e';

/// Get the active account contact list
///
/// Copied from [fetchContactList].
@ProviderFor(fetchContactList)
final fetchContactListProvider =
    AutoDisposeFutureProvider<IList<proto.Contact>?>.internal(
  fetchContactList,
  name: r'fetchContactListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchContactListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchContactListRef
    = AutoDisposeFutureProviderRef<IList<proto.Contact>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
