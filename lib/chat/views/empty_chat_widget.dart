import 'package:flutter/material.dart';

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) =>
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              color: Theme.of(context).disabledColor,
              size: 48,
            ),
            Text(
              'Say Something',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
          ],
        ),
      );
}
