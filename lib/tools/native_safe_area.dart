import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class NativeSafeArea extends StatelessWidget {
  const NativeSafeArea({
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    super.key,
  });

  /// Whether to avoid system intrusions on the left.
  final bool left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar.
  final bool top;

  /// Whether to avoid system intrusions on the right.
  final bool right;

  /// Whether to avoid system intrusions on the bottom side of the screen.
  final bool bottom;

  /// This minimum padding to apply.
  ///
  /// The greater of the minimum insets and the media padding will be applied.
  final EdgeInsets minimum;

  /// Specifies whether the [SafeArea] should maintain the bottom
  /// [MediaQueryData.viewPadding] instead of the bottom
  /// [MediaQueryData.padding], defaults to false.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// SafeArea, the padding can be maintained below the obstruction rather than
  /// being consumed. This can be helpful in cases where your layout contains
  /// flexible widgets, which could visibly move when opening a software
  /// keyboard due to the change in the padding value. Setting this to true will
  /// avoid the UI shift.
  final bool maintainBottomViewPadding;

  /// The widget below this widget in the tree.
  ///
  /// The padding on the [MediaQuery] for the [child] will be suitably adjusted
  /// to zero out any sides that were avoided by this widget.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final nativeOrientation =
        NativeDeviceOrientationReader.orientation(context);

    late final bool realLeft;
    late final bool realRight;
    late final bool realTop;
    late final bool realBottom;

    switch (nativeOrientation) {
      case NativeDeviceOrientation.unknown:
      case NativeDeviceOrientation.portraitUp:
        realLeft = left;
        realRight = right;
        realTop = top;
        realBottom = bottom;
      case NativeDeviceOrientation.portraitDown:
        realLeft = right;
        realRight = left;
        realTop = bottom;
        realBottom = top;
      case NativeDeviceOrientation.landscapeRight:
        realLeft = bottom;
        realRight = top;
        realTop = left;
        realBottom = right;
      case NativeDeviceOrientation.landscapeLeft:
        realLeft = top;
        realRight = bottom;
        realTop = right;
        realBottom = left;
    }

    return SafeArea(
        left: realLeft,
        right: realRight,
        top: realTop,
        bottom: realBottom,
        minimum: minimum,
        maintainBottomViewPadding: maintainBottomViewPadding,
        child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('left', left))
      ..add(DiagnosticsProperty<bool>('top', top))
      ..add(DiagnosticsProperty<bool>('right', right))
      ..add(DiagnosticsProperty<bool>('bottom', bottom))
      ..add(DiagnosticsProperty<EdgeInsets>('minimum', minimum))
      ..add(DiagnosticsProperty<bool>(
          'maintainBottomViewPadding', maintainBottomViewPadding));
  }
}
