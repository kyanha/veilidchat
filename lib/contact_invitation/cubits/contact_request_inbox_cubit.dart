import 'package:provider/provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

// Watch subkey #1 of the ContactRequest record for accept/reject
class ContactRequestInboxCubit
    extends DefaultDHTRecordCubit<proto.SignedContactResponse?> {
  ContactRequestInboxCubit(
      {required Locator locator, required this.contactInvitationRecord})
      : super(
            open: () => _open(
                locator: locator,
                contactInvitationRecord: contactInvitationRecord),
            decodeState: (buf) => buf.isEmpty
                ? null
                : proto.SignedContactResponse.fromBuffer(buf));

  static Future<DHTRecord> _open(
      {required Locator locator,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    final pool = DHTRecordPool.instance;

    final unlockedAccountInfo =
        locator<AccountInfoCubit>().state.unlockedAccountInfo!;
    final accountRecordKey = unlockedAccountInfo.accountRecordKey;

    final writerSecret = contactInvitationRecord.writerSecret.toVeilid();
    final recordKey =
        contactInvitationRecord.contactRequestInbox.recordKey.toVeilid();
    final writerTypedSecret =
        TypedKey(kind: recordKey.kind, value: writerSecret);
    return pool.openRecordRead(recordKey,
        debugName: 'ContactRequestInboxCubit::_open::'
            'ContactRequestInbox',
        crypto:
            await DHTRecordPool.privateCryptoFromTypedSecret(writerTypedSecret),
        parent: accountRecordKey,
        defaultSubkey: 1);
  }

  final proto.ContactInvitationRecord contactInvitationRecord;
}
