import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/theme.dart';
import '../../tools/tools.dart';
import '../cubit/cubit.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
  });

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final accountData = context.watch<AccountRecordCubit>().state.data;
    if (accountData == null) {
      return waitingPage(context);
    }
    final account = accountData.value;

    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;

    return DecoratedBox(
      decoration: ShapeDecoration(
          color: scale.primaryScale.border,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Column(children: [
        Text(
          account.profile.name,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.left,
        ).paddingAll(4),
        if (account.profile.pronouns.isNotEmpty)
          Text(account.profile.pronouns, style: textTheme.bodyMedium)
              .paddingLTRB(4, 0, 4, 4),
      ]),
    );
  }
}
