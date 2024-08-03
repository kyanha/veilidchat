import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    required this.title,
    required this.titleStyle,
    required this.foregroundColor,
    this.headerWidget,
    this.widthBox,
    this.callback,
    this.backgroundColor,
    this.backgroundHoverColor,
    this.backgroundFocusColor,
    this.borderColor,
    this.borderHoverColor,
    this.borderFocusColor,
    this.borderRadius,
    this.footerButtonIcon,
    this.footerButtonIconColor,
    this.footerButtonIconHoverColor,
    this.footerButtonIconFocusColor,
    this.footerCallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: callback,
        style: TextButton.styleFrom(foregroundColor: foregroundColor).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return backgroundHoverColor;
              }
              if (states.contains(WidgetState.focused)) {
                return backgroundFocusColor;
              }
              return backgroundColor;
            }),
            side: WidgetStateBorderSide.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return borderColor != null
                    ? BorderSide(width: 2, color: borderHoverColor!)
                    : null;
              }
              if (states.contains(WidgetState.focused)) {
                return borderColor != null
                    ? BorderSide(width: 2, color: borderFocusColor!)
                    : null;
              }
              return borderColor != null
                  ? BorderSide(width: 2, color: borderColor!)
                  : null;
            }),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 0)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (headerWidget != null) headerWidget!,
            if (widthBox != null) widthBox!,
            Expanded(
              child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: titleStyle,
                  ).paddingAll(8)),
            ),
            if (footerButtonIcon != null)
              IconButton(
                  color: footerButtonIconColor,
                  focusColor: footerButtonIconFocusColor,
                  hoverColor: footerButtonIconHoverColor,
                  icon: Icon(
                    footerButtonIcon,
                    size: 24,
                  ),
                  onPressed: footerCallback),
          ],
        ).paddingAll(2),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextStyle?>('textStyle', titleStyle))
      ..add(ObjectFlagProperty<void Function()?>.has('callback', callback))
      ..add(DiagnosticsProperty<Color>('foregroundColor', foregroundColor))
      ..add(StringProperty('title', title))
      ..add(
          DiagnosticsProperty<IconData?>('footerButtonIcon', footerButtonIcon))
      ..add(ObjectFlagProperty<void Function()?>.has(
          'footerCallback', footerCallback))
      ..add(ColorProperty('footerButtonIconColor', footerButtonIconColor))
      ..add(ColorProperty(
          'footerButtonIconHoverColor', footerButtonIconHoverColor))
      ..add(ColorProperty(
          'footerButtonIconFocusColor', footerButtonIconFocusColor))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('backgroundHoverColor', backgroundHoverColor))
      ..add(ColorProperty('backgroundFocusColor', backgroundFocusColor))
      ..add(ColorProperty('borderColor', borderColor))
      ..add(DoubleProperty('borderRadius', borderRadius))
      ..add(ColorProperty('borderHoverColor', borderHoverColor))
      ..add(ColorProperty('borderFocusColor', borderFocusColor));
  }

  ////////////////////////////////////////////////////////////////////////////

  final String title;
  final Widget? headerWidget;
  final Widget? widthBox;
  final TextStyle titleStyle;
  final Color foregroundColor;
  final void Function()? callback;
  final IconData? footerButtonIcon;
  final void Function()? footerCallback;
  final Color? backgroundColor;
  final Color? backgroundHoverColor;
  final Color? backgroundFocusColor;
  final Color? borderColor;
  final double? borderRadius;
  final Color? borderHoverColor;
  final Color? borderFocusColor;
  final Color? footerButtonIconColor;
  final Color? footerButtonIconHoverColor;
  final Color? footerButtonIconFocusColor;
}
