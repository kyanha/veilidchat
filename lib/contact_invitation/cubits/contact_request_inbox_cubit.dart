import 'package:veilid_support/veilid_support.dart';

import '../../account_manager/account_manager.dart';
import '../../proto/proto.dart' as proto;

// Watch subkey #1 of the ContactRequest record for accept/reject
class ContactRequestInboxCubit
    extends DefaultDHTRecordCubit<proto.SignedContactResponse?> {
  ContactRequestInboxCubit(
      {required this.activeAccountInfo, required this.contactInvitationRecord})
      : super(
            open: () => _open(
                activeAccountInfo: activeAccountInfo,
                contactInvitationRecord: contactInvitationRecord),
            decodeState: (buf) => buf.isEmpty
                ? null
                : proto.SignedContactResponse.fromBuffer(buf));

  // ContactRequestInboxCubit.value(
  //     {required super.record,
  //     required this.activeAccountInfo,
  //     required this.contactInvitationRecord})
  //     : super.value(decodeState: proto.SignedContactResponse.fromBuffer);

  static Future<DHTRecord> _open(
      {required UnlockedAccountInfo activeAccountInfo,
      required proto.ContactInvitationRecord contactInvitationRecord}) async {
    final pool = DHTRecordPool.instance;
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
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

  final UnlockedAccountInfo activeAccountInfo;
  final proto.ContactInvitationRecord contactInvitationRecord;
}
