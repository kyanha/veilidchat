import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

// Watch subkey #1 of the ContactRequest record for accept/reject
class ContactRequestInboxCubit
    extends DefaultDHTRecordCubit<proto.SignedContactResponse?> {
  ContactRequestInboxCubit(
      {required AccountInfo accountInfo, required this.contactInvitationRecord})
      : super(
            open: () => _open(
                accountInfo: accountInfo,
                contactInvitationRecord: contactInvitationRecord),
            decodeState: (buf) => buf.isEmpty
                ? null
                : proto.SignedContactResponse.fromBuffer(buf));

  static Future<DHTRecord> _open(
      {required AccountInfo accountInfo,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    final pool = DHTRecordPool.instance;

    final accountRecordKey = accountInfo.accountRecordKey;

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
