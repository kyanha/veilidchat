import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/theme.dart';

class EmptyChatListWidget extends StatelessWidget {
  const EmptyChatListWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat,
          color: scale.primaryScale.border,
          size: 48,
        ),
        Text(
          translate('chat_list.start_a_conversation'),
          style: textTheme.bodyMedium?.copyWith(
            color: scale.primaryScale.border,
          ),
        ),
      ],
    );
  }
}
