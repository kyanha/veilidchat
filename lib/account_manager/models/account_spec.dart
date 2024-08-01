import 'package:flutter/widgets.dart';

import '../../proto/proto.dart' as proto;

/// Profile and Account configurable fields
/// Some are publicly visible via the proto.Profile
/// Some are privately held as proto.Account configurations
class AccountSpec {
  AccountSpec(
      {required this.name,
      required this.pronouns,
      required this.about,
      required this.availability,
      required this.invisible,
      required this.freeMessage,
      required this.awayMessage,
      required this.busyMessage,
      required this.avatar,
      required this.autoAway,
      required this.autoAwayTimeout});

  String get status {
    late final String status;
    switch (availability) {
      case proto.Availability.AVAILABILITY_AWAY:
        status = awayMessage;
        break;
      case proto.Availability.AVAILABILITY_BUSY:
        status = busyMessage;
        break;
      case proto.Availability.AVAILABILITY_FREE:
        status = freeMessage;
        break;
      case proto.Availability.AVAILABILITY_UNSPECIFIED:
      case proto.Availability.AVAILABILITY_OFFLINE:
        status = '';
        break;
    }
    return status;
  }

  ////////////////////////////////////////////////////////////////////////////

  String name;
  String pronouns;
  String about;
  proto.Availability availability;
  bool invisible;
  String freeMessage;
  String awayMessage;
  String busyMessage;
  ImageProvider? avatar;
  bool autoAway;
  int autoAwayTimeout;
}
