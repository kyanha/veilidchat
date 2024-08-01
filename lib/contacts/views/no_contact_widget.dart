import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../theme/models/scale_scheme.dart';

class NoContactWidget extends StatelessWidget {
  const NoContactWidget({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            color: scale.primaryScale.subtleBorder,
            size: 48,
          ),
          Text(
            textAlign: TextAlign.center,
            translate('contacts_dialog.no_contact_selected'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scale.primaryScale.subtleBorder,
                ),
          ),
        ],
      ),
    );
  }
}
