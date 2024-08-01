import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../proto/proto.dart' as proto;

class AvailabilityWidget extends StatelessWidget {
  const AvailabilityWidget(
      {required this.availability,
      this.vertical = true,
      this.iconSize = 32,
      super.key});

  static Widget availabilityIcon(proto.Availability availability,
      {double size = 32}) {
    late final Widget iconData;
    switch (availability) {
      case proto.Availability.AVAILABILITY_AWAY:
        iconData =
            ImageIcon(const AssetImage('assets/images/toilet.png'), size: size);
      case proto.Availability.AVAILABILITY_BUSY:
        iconData = Icon(Icons.event_busy, size: size);
      case proto.Availability.AVAILABILITY_FREE:
        iconData = Icon(Icons.event_available, size: size);
      case proto.Availability.AVAILABILITY_OFFLINE:
        iconData = Icon(Icons.cloud_off, size: size);
      case proto.Availability.AVAILABILITY_UNSPECIFIED:
        iconData = Icon(Icons.question_mark, size: size);
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
    final icon = availabilityIcon(availability, size: iconSize);

    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
                icon,
                Text(name, style: textTheme.labelSmall).paddingLTRB(0, 0, 0, 0)
              ])
        : Row(mainAxisSize: MainAxisSize.min, children: [
            icon,
            Text(name, style: textTheme.labelSmall).paddingLTRB(8, 0, 0, 0)
          ]);
  }

  ////////////////////////////////////////////////////////////////////////////

  final proto.Availability availability;
  final bool vertical;
  final double iconSize;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
          DiagnosticsProperty<proto.Availability>('availability', availability))
      ..add(DiagnosticsProperty<bool>('vertical', vertical))
      ..add(DoubleProperty('iconSize', iconSize));
  }
}
