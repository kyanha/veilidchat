import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/theme.dart';

class EmptyContactListWidget extends StatelessWidget {
  const EmptyContactListWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return Expanded(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon(
        //   Icons.person_add_sharp,
        //   color: scale.primaryScale.subtleBorder,
        //   size: 48,
        // ),
        Text(
          textAlign: TextAlign.center,
          translate('contact_list.invite_people'),
          //maxLines: 3,
          style: textTheme.bodyMedium?.copyWith(
            color: scale.primaryScale.subtleBorder,
          ),
        ),
      ],
    ));
  }
}
