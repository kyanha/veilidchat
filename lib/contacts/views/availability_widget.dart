import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../proto/proto.dart' as proto;

class AvailabilityWidget extends StatelessWidget {
  const AvailabilityWidget({required this.availability, super.key});

  static IconData availabilityIcon(proto.Availability availability) {
    late final IconData iconData;
    switch (availability) {
      case proto.Availability.AVAILABILITY_AWAY:
        iconData = Icons.hot_tub;
      case proto.Availability.AVAILABILITY_BUSY:
        iconData = Icons.event_busy;
      case proto.Availability.AVAILABILITY_FREE:
        iconData = Icons.event_available;
      case proto.Availability.AVAILABILITY_OFFLINE:
        iconData = Icons.cloud_off;
      case proto.Availability.AVAILABILITY_UNSPECIFIED:
        iconData = Icons.question_mark;
    }
    return iconData;
  }

  static String availabilityName(proto.Availability availability) {
    late final String name;
    switch (availability) {
      case proto.Availability.AVAILABILITY_AWAY:
        name = translate('availability.away');
      case proto.Availability.AVAILABILITY_BUSY:
        name = translate('availability.busy');
      case proto.Availability.AVAILABILITY_FREE:
        name = translate('availability.free');
      case proto.Availability.AVAILABILITY_OFFLINE:
        name = translate('availability.offline');
      case proto.Availability.AVAILABILITY_UNSPECIFIED:
        name = translate('availability.unspecified');
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // final scale = theme.extension<ScaleScheme>()!;
    // final scaleConfig = theme.extension<ScaleConfig>()!;

    final name = availabilityName(availability);
    final iconData = availabilityIcon(availability);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(iconData, size: 32),
      Text(name, style: textTheme.labelSmall)
    ]);
  }

  final proto.Availability availability;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<proto.Availability>('availability', availability));
  }
}
