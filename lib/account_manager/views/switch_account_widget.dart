import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';

import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../account_manager.dart';

class SwitchAccountWidget extends StatelessWidget {
  const SwitchAccountWidget({
    super.key,
  });
  //

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;

    final accountRepo = AccountRepository.instance;
    final localAccounts = accountRepo.getLocalAccounts();
    for (final la in localAccounts) {
      //
    }

    return DecoratedBox(
      decoration: ShapeDecoration(
          color: scale.primaryScale.border,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Column(children: []),
    );
  }
}
