import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../theme.dart';

AlertStyle _alertStyle(BuildContext context) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;

  return AlertStyle(
    animationType: AnimationType.grow,
    //animationDuration: const Duration(milliseconds: 200),
    alertBorder: RoundedRectangleBorder(
        side: !scaleConfig.useVisualIndicators
            ? BorderSide.none
            : BorderSide(
                strokeAlign: BorderSide.strokeAlignCenter,
                color: scale.primaryScale.border,
                width: 2),
        borderRadius: BorderRadius.all(
            Radius.circular(12 * scaleConfig.borderRadiusScale))),
    // isButtonVisible: true,
    // isCloseButton: true,
    // isOverlayTapDismiss: true,
    backgroundColor: scale.primaryScale.subtleBackground,
    // overlayColor: Colors.black87,
    titleStyle: theme.textTheme.titleMedium!
        .copyWith(color: scale.primaryScale.appText),
    // titleTextAlign: TextAlign.center,
    descStyle:
        theme.textTheme.bodyMedium!.copyWith(color: scale.primaryScale.appText),
    // descTextAlign: TextAlign.center,
    // buttonAreaPadding: const EdgeInsets.all(20.0),
    // constraints: null,
    // buttonsDirection: ButtonsDirection.row,
    // alertElevation: null,
    // alertPadding: defaultAlertPadding,
    // alertAlignment: Alignment.center,
    // isTitleSelectable: false,
    // isDescSelectable: false,
    // titlePadding: null,
    //descPadding: const EdgeInsets.all(0.0),
  );
}

Color _buttonColor(BuildContext context, bool highlight) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;

  if (scaleConfig.useVisualIndicators && !scaleConfig.preferBorders) {
    return scale.secondaryScale.border;
  }

  return highlight
      ? scale.secondaryScale.elementBackground
      : scale.secondaryScale.hoverElementBackground;
}

TextStyle _buttonTextStyle(BuildContext context) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;

  if (scaleConfig.useVisualIndicators && !scaleConfig.preferBorders) {
    return theme.textTheme.bodyMedium!
        .copyWith(color: scale.secondaryScale.borderText);
  }

  return theme.textTheme.bodyMedium!
      .copyWith(color: scale.secondaryScale.appText);
}

BoxBorder _buttonBorder(BuildContext context) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;

  return Border.fromBorderSide(BorderSide(
      color: scale.secondaryScale.border,
      width: scaleConfig.preferBorders ? 2 : 0));
}

BorderRadius _buttonRadius(BuildContext context) {
  final theme = Theme.of(context);
  final scaleConfig = theme.extension<ScaleConfig>()!;

  return BorderRadius.circular(8 * scaleConfig.borderRadiusScale);
}

Future<void> showErrorModal(
    {required BuildContext context,
    required String title,
    required String text}) async {
  final theme = Theme.of(context);
  // final scale = theme.extension<ScaleScheme>()!;
  // final scaleConfig = theme.extension<ScaleConfig>()!;

  await Alert(
    context: context,
    style: _alertStyle(context),
    useRootNavigator: false,
    type: AlertType.error,
    //style: AlertStyle(),
    title: title,
    desc: text,
    buttons: [
      DialogButton(
        color: _buttonColor(context, false),
        highlightColor: _buttonColor(context, true),
        border: _buttonBorder(context),
        radius: _buttonRadius(context),
        width: 120,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          translate('button.ok'),
          style: _buttonTextStyle(context),
        ),
      )
    ],

    //backgroundColor: Colors.black,
    //titleColor: Colors.white,
    //textColor: Colors.white,
  ).show();
}

Future<void> showErrorStacktraceModal(
    {required BuildContext context,
    required Object error,
    StackTrace? stackTrace}) async {
  await showErrorModal(
    context: context,
    title: translate('toast.error'),
    text: 'Error: {e}\n StackTrace: {st}',
  );
}

Future<void> showWarningModal(
    {required BuildContext context,
    required String title,
    required String text}) async {
  final theme = Theme.of(context);
  // final scale = theme.extension<ScaleScheme>()!;
  // final scaleConfig = theme.extension<ScaleConfig>()!;

  await Alert(
    context: context,
    style: _alertStyle(context),
    useRootNavigator: false,
    type: AlertType.warning,
    //style: AlertStyle(),
    title: title,
    desc: text,
    buttons: [
      DialogButton(
        color: _buttonColor(context, false),
        highlightColor: _buttonColor(context, true),
        border: _buttonBorder(context),
        radius: _buttonRadius(context),
        width: 120,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          translate('button.ok'),
          style: _buttonTextStyle(context),
        ),
      )
    ],

    //backgroundColor: Colors.black,
    //titleColor: Colors.white,
    //textColor: Colors.white,
  ).show();
}

Future<void> showWarningWidgetModal(
    {required BuildContext context,
    required String title,
    required Widget child}) async {
  final theme = Theme.of(context);
  // final scale = theme.extension<ScaleScheme>()!;
  // final scaleConfig = theme.extension<ScaleConfig>()!;

  await Alert(
    context: context,
    style: _alertStyle(context),
    useRootNavigator: false,
    type: AlertType.warning,
    //style: AlertStyle(),
    title: title,
    content: child,
    buttons: [
      DialogButton(
        color: _buttonColor(context, false),
        highlightColor: _buttonColor(context, true),
        border: _buttonBorder(context),
        radius: _buttonRadius(context),
        width: 120,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          translate('button.ok'),
          style: _buttonTextStyle(context),
        ),
      )
    ],

    //backgroundColor: Colors.black,
    //titleColor: Colors.white,
    //textColor: Colors.white,
  ).show();
}

Future<bool> showConfirmModal(
    {required BuildContext context,
    required String title,
    required String text}) async {
  final theme = Theme.of(context);
  // final scale = theme.extension<ScaleScheme>()!;
  // final scaleConfig = theme.extension<ScaleConfig>()!;

  var confirm = false;

  await Alert(
    context: context,
    style: _alertStyle(context),
    useRootNavigator: false,
    type: AlertType.none,
    title: title,
    desc: text,
    buttons: [
      DialogButton(
        color: _buttonColor(context, false),
        highlightColor: _buttonColor(context, true),
        border: _buttonBorder(context),
        radius: _buttonRadius(context),
        width: 120,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          translate('button.no'),
          style: _buttonTextStyle(context),
        ),
      ),
      DialogButton(
        color: _buttonColor(context, false),
        highlightColor: _buttonColor(context, true),
        border: _buttonBorder(context),
        radius: _buttonRadius(context),
        width: 120,
        onPressed: () {
          confirm = true;
          Navigator.pop(context);
        },
        child: Text(
          translate('button.yes'),
          style: _buttonTextStyle(context),
        ),
      )
    ],

    //backgroundColor: Colors.black,
    //titleColor: Colors.white,
    //textColor: Colors.white,
  ).show();

  return confirm;
}
