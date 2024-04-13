import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:bloc_tools/bloc_tools.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:quickalert/quickalert.dart';

import '../theme.dart';

extension BorderExt on Widget {
  DecoratedBox debugBorder() => DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
      child: this);
}

extension ModalProgressExt on Widget {
  BlurryModalProgressHUD withModalHUD(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return BlurryModalProgressHUD(
        inAsyncCall: isLoading,
        blurEffectIntensity: 4,
        progressIndicator: buildProgressIndicator(),
        color: scale.tertiaryScale.appBackground.withAlpha(64),
        child: this);
  }
}

Widget buildProgressIndicator() => Builder(builder: (context) {
      final theme = Theme.of(context);
      final scale = theme.extension<ScaleScheme>()!;
      return SpinKitFoldingCube(
        color: scale.tertiaryScale.primary,
        size: 80,
      );
    });

Widget waitingPage({String? text}) => Builder(builder: (context) {
      final theme = Theme.of(context);
      final scale = theme.extension<ScaleScheme>()!;
      return ColoredBox(
          color: scale.tertiaryScale.primaryText,
          child: Center(
              child: Column(children: [
            buildProgressIndicator().expanded(),
            if (text != null) Text(text)
          ])));
    });

Widget debugPage(String text) => Builder(
    builder: (context) => ColoredBox(
        color: Theme.of(context).colorScheme.error,
        child: Center(child: Text(text))));

Widget errorPage(Object err, StackTrace? st) => Builder(
    builder: (context) => ColoredBox(
        color: Theme.of(context).colorScheme.error,
        child: Center(child: ErrorWidget(err))));

Widget asyncValueBuilder<T>(
        AsyncValue<T> av, Widget Function(BuildContext, T) builder) =>
    av.when(
        loading: waitingPage,
        error: errorPage,
        data: (d) => Builder(builder: (context) => builder(context, d)));

extension AsyncValueBuilderExt<T> on AsyncValue<T> {
  Widget builder(Widget Function(BuildContext, T) builder) =>
      asyncValueBuilder<T>(this, builder);
  Widget buildNotData(
          {Widget Function()? loading,
          Widget Function(Object, StackTrace?)? error}) =>
      when(
          loading: () => (loading ?? waitingPage)(),
          error: (e, st) => (error ?? errorPage)(e, st),
          data: (d) => debugPage('AsyncValue should not be data here'));
}

extension BusyAsyncValueBuilderExt<T> on BlocBusyState<AsyncValue<T>> {
  Widget builder(Widget Function(BuildContext, T) builder) =>
      AbsorbPointer(absorbing: busy, child: state.builder(builder));
  Widget buildNotData(
          {Widget Function()? loading,
          Widget Function(Object, StackTrace?)? error}) =>
      AbsorbPointer(
          absorbing: busy,
          child: state.buildNotData(loading: loading, error: error));
}

class AsyncBlocBuilder<B extends StateStreamable<AsyncValue<S>>, S>
    extends BlocBuilder<B, AsyncValue<S>> {
  AsyncBlocBuilder({
    required BlocWidgetBuilder<S> builder,
    Widget Function()? loading,
    Widget Function(Object, StackTrace?)? error,
    super.key,
    super.bloc,
    super.buildWhen,
  }) : super(
            builder: (context, state) => state.when(
                loading: () => (loading ?? waitingPage)(),
                error: (e, st) => (error ?? errorPage)(e, st),
                data: (d) => builder(context, d)));
}

Future<void> showErrorModal(
    BuildContext context, String title, String text) async {
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.error,
    title: title,
    text: text,
    //backgroundColor: Colors.black,
    //titleColor: Colors.white,
    //textColor: Colors.white,
  );
}

void showErrorToast(BuildContext context, String message) {
  MotionToast.error(
    title: Text(translate('toast.error')),
    description: Text(message),
  ).show(context);
}

void showInfoToast(BuildContext context, String message) {
  MotionToast.info(
    title: Text(translate('toast.info')),
    description: Text(message),
  ).show(context);
}

// Widget insetBorder(
//     {required BuildContext context,
//     required bool enabled,
//     required Color color,
//     required Widget child}) {
//   if (!enabled) {
//     return child;
//   }

//   return Stack({
//     children: [] {
//       DecoratedBox(decoration: BoxDecoration()
//       child,
//     }
//   })
// }

Widget styledTitleContainer({
  required BuildContext context,
  required String title,
  required Widget child,
  Color? borderColor,
  Color? backgroundColor,
  Color? titleColor,
}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final textTheme = theme.textTheme;

  return DecoratedBox(
      decoration: ShapeDecoration(
          color: borderColor ?? scale.primaryScale.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          )),
      child: Column(children: [
        Text(
          title,
          style: textTheme.titleMedium!
              .copyWith(color: titleColor ?? scale.primaryScale.borderText),
        ).paddingLTRB(8, 8, 8, 4),
        DecoratedBox(
                decoration: ShapeDecoration(
                    color:
                        backgroundColor ?? scale.primaryScale.subtleBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    )),
                child: child)
            .paddingAll(4)
            .expanded()
      ]));
}

Widget styledBottomSheet({
  required BuildContext context,
  required String title,
  required Widget child,
  Color? borderColor,
  Color? backgroundColor,
  Color? titleColor,
}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final textTheme = theme.textTheme;

  return DecoratedBox(
      decoration: ShapeDecoration(
          color: borderColor ?? scale.primaryScale.dialogBorder,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          title,
          style: textTheme.titleMedium!
              .copyWith(color: titleColor ?? scale.primaryScale.borderText),
        ).paddingLTRB(8, 8, 8, 4),
        DecoratedBox(
                decoration: ShapeDecoration(
                    color:
                        backgroundColor ?? scale.primaryScale.subtleBackground,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)))),
                child: child)
            .paddingLTRB(4, 4, 4, 0)
      ]));
}

bool get isPlatformDark =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness ==
    Brightness.dark;
