import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class OptionBox extends StatelessWidget {
  const OptionBox(
      {required String instructions,
      required IconData buttonIcon,
      required String buttonText,
      required void Function() onClick,
      super.key})
      : _instructions = instructions,
        _buttonIcon = buttonIcon,
        _buttonText = buttonText,
        _onClick = onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
                color: scale.primaryScale.subtleBackground,
                borderRadius:
                    BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
                border: Border.all(color: scale.primaryScale.border)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      style: theme.textTheme.labelMedium!
                          .copyWith(color: scale.primaryScale.appText),
                      softWrap: true,
                      textAlign: TextAlign.center,
                      _instructions),
                  ElevatedButton(
                      onPressed: _onClick,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_buttonIcon, size: 24).paddingLTRB(0, 8, 8, 8),
                        Text(textAlign: TextAlign.center, _buttonText)
                      ])).paddingLTRB(0, 12, 0, 0).toCenter()
                ]).paddingAll(12))
        .paddingLTRB(24, 0, 24, 12);
  }

  final String _instructions;
  final IconData _buttonIcon;
  final String _buttonText;
  final void Function() _onClick;
}
