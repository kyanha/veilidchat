import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class StyledScaffold extends StatelessWidget {
  const StyledScaffold({required this.appBar, required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return clipBorder(
            clipEnabled: true,
            borderEnabled: scaleConfig.useVisualIndicators,
            borderRadius: 16 * scaleConfig.borderRadiusScale,
            borderColor: scale.primaryScale.border,
            child: Scaffold(appBar: appBar, body: body, key: key))
        .paddingAll(32);
  }

  ////////////////////////////////////////////////////////////////////////////
  final PreferredSizeWidget? appBar;
  final Widget? body;
}
