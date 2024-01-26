import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;

@immutable
class AcceptedContact {
  const AcceptedContact({
    required this.profile,
    required this.remoteIdentity,
    required this.remoteConversationRecordKey,
    required this.localConversationRecordKey,
  });

  final proto.Profile profile;
  final IdentityMaster remoteIdentity;
  final TypedKey remoteConversationRecordKey;
  final TypedKey localConversationRecordKey;
}
