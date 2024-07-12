import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';

import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    required proto.Profile profile,
    required bool showPronouns,
    super.key,
  })  : _profile = profile,
        _showPronouns = showPronouns;

  //

  final proto.Profile _profile;
  final bool _showPronouns;

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
                Radius.circular(12 * scaleConfig.borderRadiusScale))),
      ),
      child: Row(children: [
        const Spacer(),
        Text(
          _profile.name,
          style: textTheme.titleMedium!.copyWith(
              color: scaleConfig.preferBorders
                  ? scale.primaryScale.border
                  : scale.primaryScale.borderText),
          textAlign: TextAlign.left,
        ).paddingAll(12),
        if (_profile.pronouns.isNotEmpty && _showPronouns)
          Text('(${_profile.pronouns})',
                  textAlign: TextAlign.right,
                  style: textTheme.bodySmall!.copyWith(
                      color: scaleConfig.preferBorders
                          ? scale.primaryScale.border
                          : scale.primaryScale.primary))
              .paddingAll(12),
        const Spacer()
      ]),
    );
  }
}
