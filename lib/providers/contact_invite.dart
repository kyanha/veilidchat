import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/local_account.dart';
import '../proto/proto.dart' as proto;
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'account.dart';
import 'conversation.dart';

part 'contact_invite.g.dart';

/// Get the active account contact invitation list
@riverpod
Future<IList<proto.ContactInvitationRecord>?> fetchContactInvitationRecords(
    FetchContactInvitationRecordsRef ref) async {
  // See if we've logged into this account or if it is locked
  final activeAccountInfo = await ref.watch(fetchActiveAccountProvider.future);
  if (activeAccountInfo == null) {
    return null;
  }
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Decode the contact invitation list from the DHT
  IList<proto.ContactInvitationRecord> out = const IListConst([]);

  try {
    await (await DHTShortArray.openOwned(
            proto.OwnedDHTRecordPointerProto.fromProto(
                activeAccountInfo.account.contactInvitationRecords),
            parent: accountRecordKey))
        .scope((cirList) async {
      for (var i = 0; i < cirList.length; i++) {
        final cir = await cirList.getItem(i);
        if (cir == null) {
          throw Exception('Failed to get contact invitation record');
        }
        out = out.add(proto.ContactInvitationRecord.fromBuffer(cir));
      }
    });
  } on VeilidAPIExceptionTryAgain catch (_) {
    // Try again later
    ref.invalidateSelf();
    return null;
  } on Exception catch (_) {
    // Try again later
    ref.invalidateSelf();
    rethrow;
  }

  return out;
}
