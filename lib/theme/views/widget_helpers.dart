import 'dart:math';

import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:sliver_expandable/sliver_expandable.dart';

import '../theme.dart';

extension BorderExt on Widget {
  DecoratedBox debugBorder() => DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
      child: this);
}

extension SizeToFixExt on Widget {
  FittedBox fit({BoxFit? fit, Key? key}) => FittedBox(
        key: key,
        fit: fit ?? BoxFit.scaleDown,
        child: this,
      );
}

extension FocusExt<T> on Widget {
  Focus focus(
          {Key? key,
          FocusNode? focusNode,
          FocusNode? parentNode,
          bool autofocus = false,
          ValueChanged<bool>? onFocusChange,
          FocusOnKeyEventCallback? onKeyEvent,
          bool? canRequestFocus,
          bool? skipTraversal,
          bool? descendantsAreFocusable,
          bool? descendantsAreTraversable,
          bool includeSemantics = true,
          String? debugLabel}) =>
      Focus(
          key: key,
          focusNode: focusNode,
          parentNode: parentNode,
          autofocus: autofocus,
          onFocusChange: onFocusChange,
          onKeyEvent: onKeyEvent,
          canRequestFocus: canRequestFocus,
          skipTraversal: skipTraversal,
          descendantsAreFocusable: descendantsAreFocusable,
          descendantsAreTraversable: descendantsAreTraversable,
          includeSemantics: includeSemantics,
          debugLabel: debugLabel,
          child: this);
  Focus onFocusChange(void Function(bool) onFocusChange) =>
      Focus(onFocusChange: onFocusChange, child: this);
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

extension LabelExt on Widget {
  Widget decoratorLabel(BuildContext context, String label,
      {ScaleColor? scale}) {
    final theme = Theme.of(context);
    final scaleScheme = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;
    scale = scale ?? scaleScheme.primaryScale;

    final border = scale.border;
    final disabledBorder = scaleScheme.grayScale.border;
    final hoverBorder = scale.hoverBorder;
    final focusedErrorBorder = scaleScheme.errorScale.border;
    final errorBorder = scaleScheme.errorScale.primary;
    OutlineInputBorder makeBorder(Color color) => OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
          borderSide: BorderSide(color: color),
        );
    OutlineInputBorder makeFocusedBorder(Color color) => OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
          borderSide: BorderSide(width: 2, color: color),
        );
    return InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: TextStyle(color: hoverBorder),
          border: makeBorder(border),
          enabledBorder: makeBorder(border),
          disabledBorder: makeBorder(disabledBorder),
          focusedBorder: makeFocusedBorder(hoverBorder),
          errorBorder: makeBorder(errorBorder),
          focusedErrorBorder: makeFocusedBorder(focusedErrorBorder),
        ),
        child: this);
  }

  Widget noEditDecoratorLabel(BuildContext context, String label,
      {ScaleColor? scale}) {
    final theme = Theme.of(context);
    final scaleScheme = theme.extension<ScaleScheme>()!;
    // final scaleConfig = theme.extension<ScaleConfig>()!;
    scale = scale ?? scaleScheme.primaryScale;

    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
      Text(
        '$label:',
        style: theme.textTheme.titleLarge!.copyWith(color: scale.border),
      ).paddingLTRB(0, 0, 8, 8),
      this
    ]);
  }
}

Widget buildProgressIndicator() => Builder(builder: (context) {
      final theme = Theme.of(context);
      final scale = theme.extension<ScaleScheme>()!;
      return FittedBox(
          fit: BoxFit.scaleDown,
          child: SpinKitFoldingCube(
            color: scale.tertiaryScale.border,
            size: 80,
          ));
    });

Widget waitingPage({String? text, void Function()? onCancel}) =>
    Builder(builder: (context) {
      final theme = Theme.of(context);
      final scale = theme.extension<ScaleScheme>()!;
      return ColoredBox(
          color: scale.tertiaryScale.appBackground,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildProgressIndicator().paddingAll(24),
                if (text != null)
                  Text(text,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: scale.tertiaryScale.appText)),
                if (onCancel != null)
                  ElevatedButton(
                          onPressed: onCancel,
                          child: Text(translate('button.cancel'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall!.copyWith(
                                  color: scale.tertiaryScale.appText)))
                      .alignAtCenter(),
              ]));
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

SliverAppBar styledSliverAppBar(
    {required BuildContext context, required String title, Color? titleColor}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  //final scaleConfig = theme.extension<ScaleConfig>()!;
  final textTheme = theme.textTheme;

  return SliverAppBar(
    title: Text(
      title,
      style: textTheme.titleSmall!
          .copyWith(color: titleColor ?? scale.primaryScale.borderText),
    ),
    pinned: true,
  );
}

Widget styledHeaderSliver(
    {required BuildContext context,
    required String title,
    required Widget sliver,
    Color? borderColor,
    Color? innerColor,
    Color? titleColor,
    Color? backgroundColor,
    void Function()? onTap}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;
  final textTheme = theme.textTheme;

  return SliverStickyHeader(
    header: ColoredBox(
        color: backgroundColor ?? Colors.transparent,
        child: DecoratedBox(
          decoration: ShapeDecoration(
              color: borderColor ?? scale.primaryScale.border,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(12 * scaleConfig.borderRadiusScale),
                      topRight: Radius.circular(
                          12 * scaleConfig.borderRadiusScale)))),
          child: ListTile(
            onTap: onTap,
            title: Text(title,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall!.copyWith(
                    color: titleColor ?? scale.primaryScale.borderText)),
          ),
        )),
    sliver: DecoratedSliver(
        decoration: ShapeDecoration(
            color: borderColor ?? scale.primaryScale.border,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(8 * scaleConfig.borderRadiusScale),
                    bottomRight:
                        Radius.circular(8 * scaleConfig.borderRadiusScale)))),
        sliver: SliverPadding(
            padding: const EdgeInsets.all(4),
            sliver: DecoratedSliver(
                decoration: ShapeDecoration(
                    color: innerColor ?? scale.primaryScale.subtleBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8 * scaleConfig.borderRadiusScale))),
                sliver: SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: sliver,
                )))),
  );
}

Widget styledExpandingSliver(
    {required BuildContext context,
    required String title,
    required Widget sliver,
    required bool expanded,
    required Animation<double> animation,
    Color? borderColor,
    Color? innerColor,
    Color? titleColor,
    Color? backgroundColor,
    void Function()? onTap}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;
  final textTheme = theme.textTheme;

  return SliverStickyHeader(
      header: ColoredBox(
          color: backgroundColor ?? Colors.transparent,
          child: DecoratedBox(
            decoration: ShapeDecoration(
                color: borderColor ?? scale.primaryScale.border,
                shape: RoundedRectangleBorder(
                    borderRadius: expanded
                        ? BorderRadius.only(
                            topLeft: Radius.circular(
                                12 * scaleConfig.borderRadiusScale),
                            topRight: Radius.circular(
                                12 * scaleConfig.borderRadiusScale))
                        : BorderRadius.circular(
                            12 * scaleConfig.borderRadiusScale))),
            child: ListTile(
              onTap: onTap,
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall!.copyWith(
                      color: titleColor ?? scale.primaryScale.borderText)),
              trailing: AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Transform.rotate(
                  angle: (animation.value - 0.5) * pi,
                  child: child,
                ),
                child: Icon(Icons.chevron_left,
                    color: borderColor ?? scale.primaryScale.borderText),
              ),
            ),
          )),
      sliver: SliverExpandable(
        sliver: DecoratedSliver(
            decoration: ShapeDecoration(
                color: borderColor ?? scale.primaryScale.border,
                shape: RoundedRectangleBorder(
                    borderRadius: expanded
                        ? BorderRadius.only(
                            bottomLeft: Radius.circular(
                                8 * scaleConfig.borderRadiusScale),
                            bottomRight: Radius.circular(
                                8 * scaleConfig.borderRadiusScale))
                        : BorderRadius.circular(
                            8 * scaleConfig.borderRadiusScale))),
            sliver: SliverPadding(
                padding: const EdgeInsets.all(4),
                sliver: DecoratedSliver(
                    decoration: ShapeDecoration(
                        color:
                            innerColor ?? scale.primaryScale.subtleBackground,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8 * scaleConfig.borderRadiusScale))),
                    sliver: SliverPadding(
                      padding: const EdgeInsets.all(8),
                      sliver: sliver,
                    )))),
        animation: animation,
      ));
}

Widget styledHeader({required BuildContext context, required Widget child}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;
  // final textTheme = theme.textTheme;

  return DecoratedBox(
      decoration: ShapeDecoration(
          color: scale.primaryScale.border,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12 * scaleConfig.borderRadiusScale),
                  topRight:
                      Radius.circular(12 * scaleConfig.borderRadiusScale)))),
      child: child);
}

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
  final scaleConfig = theme.extension<ScaleConfig>()!;
  final textTheme = theme.textTheme;

  return DecoratedBox(
      decoration: ShapeDecoration(
          color: borderColor ?? scale.primaryScale.border,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12 * scaleConfig.borderRadiusScale),
          )),
      child: Column(children: [
        Text(
          title,
          style: textTheme.titleSmall!
              .copyWith(color: titleColor ?? scale.primaryScale.borderText),
        ).paddingLTRB(8, 6, 8, 2),
        DecoratedBox(
                decoration: ShapeDecoration(
                    color:
                        backgroundColor ?? scale.primaryScale.subtleBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12 * scaleConfig.borderRadiusScale),
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
  final scaleConfig = theme.extension<ScaleConfig>()!;
  final textTheme = theme.textTheme;

  return DecoratedBox(
      decoration: ShapeDecoration(
          color: borderColor ?? scale.primaryScale.dialogBorder,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16 * scaleConfig.borderRadiusScale),
                  topRight:
                      Radius.circular(16 * scaleConfig.borderRadiusScale)))),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                16 * scaleConfig.borderRadiusScale),
                            topRight: Radius.circular(
                                16 * scaleConfig.borderRadiusScale)))),
                child: child)
            .paddingLTRB(4, 4, 4, 0)
      ]));
}

bool get isPlatformDark =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness ==
    Brightness.dark;

const grayColorFilter = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

Widget clipBorder({
  required bool clipEnabled,
  required bool borderEnabled,
  required double borderRadius,
  required Color borderColor,
  required Widget child,
}) =>
    ClipRRect(
        borderRadius: clipEnabled
            ? BorderRadius.circular(borderRadius)
            : BorderRadius.zero,
        child: DecoratedBox(
            decoration: BoxDecoration(boxShadow: [
              if (borderEnabled) BoxShadow(color: borderColor, spreadRadius: 2)
            ]),
            child: ClipRRect(
              borderRadius: clipEnabled
                  ? BorderRadius.circular(borderRadius)
                  : BorderRadius.zero,
              child: child,
            )).paddingAll(clipEnabled && borderEnabled ? 2 : 0));
