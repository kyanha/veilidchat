import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PopControl extends StatelessWidget {
  const PopControl({
    required this.child,
    required this.dismissible,
    super.key,
  });

  void _doDismiss(NavigatorState navigator) {
    if (!dismissible) {
      return;
    }
    navigator.pop();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    final route = ModalRoute.of(context);
    if (route != null && route is PopControlDialogRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        route.barrierDismissible = dismissible;
      });
    }

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          _doDismiss(navigator);
        },
        child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('dismissible', dismissible));
  }

  final bool dismissible;
  final Widget child;
}

class PopControlDialogRoute<T> extends DialogRoute<T> {
  PopControlDialogRoute(
      {required super.context,
      required super.builder,
      super.themes,
      super.barrierColor = Colors.black54,
      super.barrierDismissible,
      super.barrierLabel,
      super.useSafeArea,
      super.settings,
      super.anchorPoint,
      super.traversalEdgeBehavior})
      : _barrierDismissible = barrierDismissible;

  @override
  bool get barrierDismissible => _barrierDismissible;

  set barrierDismissible(bool d) {
    _barrierDismissible = d;
    changedInternalState();
  }

  bool _barrierDismissible;
}

bool _debugIsActive(BuildContext context) {
  if (context is Element && !context.debugIsActive) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('This BuildContext is no longer valid.'),
      ErrorDescription(
          'The showPopControlDialog function context parameter is a '
          'BuildContext that is no longer valid.'),
      ErrorHint(
        'This can commonly occur when the showPopControlDialog function is '
        'called after awaiting a Future. '
        'In this situation the BuildContext might refer to a widget that has '
        'already been disposed during the await. '
        'Consider using a parent context instead.',
      ),
    ]);
  }
  return true;
}

Future<T?> showPopControlDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
}) {
  assert(_debugIsActive(context), 'debug is active check');
  assert(debugCheckHasMaterialLocalizations(context),
      'check has material localizations');

  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(PopControlDialogRoute<T>(
    context: context,
    builder: builder,
    barrierColor: barrierColor ?? Colors.black54,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    settings: routeSettings,
    themes: themes,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior:
        traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
  ));
}
