import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class StyledDialog extends StatelessWidget {
  const StyledDialog({required this.title, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;

    return AlertDialog(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        contentPadding: const EdgeInsets.all(4),
        backgroundColor: scale.primaryScale.dialogBorder,
        title: Text(
          title,
          style: textTheme.titleMedium!
              .copyWith(color: scale.primaryScale.borderText),
          textAlign: TextAlign.center,
        ),
        titlePadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        content: DecoratedBox(
            decoration: ShapeDecoration(
                color: scale.primaryScale.border,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: DecoratedBox(
                decoration: ShapeDecoration(
                    color: scale.primaryScale.appBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: child.paddingAll(0))));
  }

  static Future<T?> show<T>(
          {required BuildContext context,
          required String title,
          required Widget child}) async =>
      showDialog<T>(
          context: context,
          builder: (context) => StyledDialog(title: title, child: child));

  final String title;
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}
