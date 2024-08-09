import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/theme.dart';

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: scale.primaryScale.appBackground,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            color: scale.primaryScale.subtleBorder,
            size: 48,
          ),
          Text(
            translate('chat.say_something'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scale.primaryScale.subtleBorder,
                ),
          ),
        ],
      ),
    );
  }
}
