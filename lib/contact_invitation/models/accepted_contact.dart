import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../proto/proto.dart' as proto;

@immutable
class AcceptedContact extends Equatable {
  const AcceptedContact({
    required this.remoteProfile,
    required this.remoteIdentity,
    required this.remoteConversationRecordKey,
    required this.localConversationRecordKey,
  });

  final proto.Profile remoteProfile;
  final IdentityMaster remoteIdentity;
  final TypedKey remoteConversationRecordKey;
  final TypedKey localConversationRecordKey;

  @override
  List<Object?> get props => [
        remoteProfile,
        remoteIdentity,
        remoteConversationRecordKey,
        localConversationRecordKey
      ];
}
