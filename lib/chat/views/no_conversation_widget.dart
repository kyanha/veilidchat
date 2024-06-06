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

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
