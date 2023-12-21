// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchChatListHash() => r'0c166082625799862128dff09d9286f64785ba6c';

/// Get the active account contact list
///
/// Copied from [fetchChatList].
@ProviderFor(fetchChatList)
final fetchChatListProvider =
    AutoDisposeFutureProvider<IList<proto.Chat>?>.internal(
  fetchChatList,
  name: r'fetchChatListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchChatListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchChatListRef = AutoDisposeFutureProviderRef<IList<proto.Chat>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
