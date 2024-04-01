import 'package:flutter/material.dart';

class NoConversationWidget extends StatelessWidget {
  const NoConversationWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) =>
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_people_outlined,
              color: Theme.of(context).disabledColor,
              size: 48,
            ),
            Text(
              'Choose A Conversation To Chat',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
          ],
        ),
      );
}
