import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/models/scale_scheme.dart';

class NoConversationWidget extends StatelessWidget {
  const NoConversationWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scale.primaryScale.appBackground,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.diversity_3,
            color: scale.primaryScale.subtleBorder,
            size: 48,
          ),
          Text(
            textAlign: TextAlign.center,
            translate('chat.start_a_conversation'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scale.primaryScale.subtleBorder,
                ),
          ),
        ],
      ),
    );
  }
}
