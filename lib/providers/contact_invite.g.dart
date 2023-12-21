// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_invite.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchContactInvitationRecordsHash() =>
    r'ff0b2c68d42cb106602982b1fb56a7bd8183c04a';

/// Get the active account contact invitation list
///
/// Copied from [fetchContactInvitationRecords].
@ProviderFor(fetchContactInvitationRecords)
final fetchContactInvitationRecordsProvider =
    AutoDisposeFutureProvider<IList<proto.ContactInvitationRecord>?>.internal(
  fetchContactInvitationRecords,
  name: r'fetchContactInvitationRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchContactInvitationRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchContactInvitationRecordsRef
    = AutoDisposeFutureProviderRef<IList<proto.ContactInvitationRecord>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
