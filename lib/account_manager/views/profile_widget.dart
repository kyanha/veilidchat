import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';

import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    required proto.Profile profile,
    super.key,
  }) : _profile = profile;

  //

  final proto.Profile _profile;

  //

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final textTheme = theme.textTheme;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: scaleConfig.preferBorders
            ? scale.primaryScale.elementBackground
            : scale.primaryScale.border,
        shape: RoundedRectangleBorder(
            side: !scaleConfig.useVisualIndicators
                ? BorderSide.none
                : BorderSide(
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: scaleConfig.preferBorders
                        ? scale.primaryScale.border
                        : scale.primaryScale.borderText,
                    width: 2),
            borderRadius: BorderRadius.all(
                Radius.circular(16 * scaleConfig.borderRadiusScale))),
      ),
      child: Column(children: [
        Text(
          _profile.name,
          style: textTheme.headlineSmall!.copyWith(
              color: scaleConfig.preferBorders
                  ? scale.primaryScale.border
                  : scale.primaryScale.borderText),
          textAlign: TextAlign.left,
        ).paddingAll(4),
        if (_profile.pronouns.isNotEmpty)
          Text(_profile.pronouns,
                  style: textTheme.bodyMedium!.copyWith(
                      color: scaleConfig.preferBorders
                          ? scale.primaryScale.border
                          : scale.primaryScale.borderText))
              .paddingLTRB(4, 0, 4, 4),
      ]),
    );
  }
}
