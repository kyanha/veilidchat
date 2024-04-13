import 'package:flutter/material.dart';

import 'scale_scheme.dart';

class ScaleInputDecoratorTheme extends InputDecorationTheme {
  ScaleInputDecoratorTheme(this._scaleScheme, this._textTheme)
      : super(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: _scaleScheme.primaryScale.border),
                borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(8),
            labelStyle: TextStyle(
                color: _scaleScheme.primaryScale.subtleText.withAlpha(127)),
            floatingLabelStyle:
                TextStyle(color: _scaleScheme.primaryScale.subtleText),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: _scaleScheme.primaryScale.hoverBorder, width: 2),
                borderRadius: BorderRadius.circular(8)));

  final ScaleScheme _scaleScheme;
  final TextTheme _textTheme;

  @override
  TextStyle? get hintStyle => MaterialStateTextStyle.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return TextStyle(color: _scaleScheme.grayScale.border);
        }
        return TextStyle(color: _scaleScheme.primaryScale.border);
      });

  @override
  Color? get fillColor => MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return _scaleScheme.grayScale.primary.withOpacity(0.04);
        }
        return _scaleScheme.primaryScale.primary.withOpacity(0.04);
      });

  @override
  BorderSide? get activeIndicatorBorder =>
      MaterialStateBorderSide.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return BorderSide(
              color: _scaleScheme.grayScale.border.withAlpha(0x7F));
        }
        if (states.contains(MaterialState.error)) {
          if (states.contains(MaterialState.hovered)) {
            return BorderSide(color: _scaleScheme.errorScale.hoverBorder);
          }
          if (states.contains(MaterialState.focused)) {
            return BorderSide(color: _scaleScheme.errorScale.border, width: 2);
          }
          return BorderSide(color: _scaleScheme.errorScale.subtleBorder);
        }
        if (states.contains(MaterialState.hovered)) {
          return BorderSide(color: _scaleScheme.secondaryScale.hoverBorder);
        }
        if (states.contains(MaterialState.focused)) {
          return BorderSide(
              color: _scaleScheme.secondaryScale.border, width: 2);
        }
        return BorderSide(color: _scaleScheme.secondaryScale.subtleBorder);
      });

  @override
  BorderSide? get outlineBorder =>
      MaterialStateBorderSide.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return BorderSide(
              color: _scaleScheme.grayScale.border.withAlpha(0x7F));
        }
        if (states.contains(MaterialState.error)) {
          if (states.contains(MaterialState.hovered)) {
            return BorderSide(color: _scaleScheme.errorScale.hoverBorder);
          }
          if (states.contains(MaterialState.focused)) {
            return BorderSide(color: _scaleScheme.errorScale.border, width: 2);
          }
          return BorderSide(color: _scaleScheme.errorScale.subtleBorder);
        }
        if (states.contains(MaterialState.hovered)) {
          return BorderSide(color: _scaleScheme.primaryScale.hoverBorder);
        }
        if (states.contains(MaterialState.focused)) {
          return BorderSide(color: _scaleScheme.primaryScale.border, width: 2);
        }
        return BorderSide(color: _scaleScheme.primaryScale.subtleBorder);
      });

  @override
  Color? get iconColor => _scaleScheme.primaryScale.primary;

  @override
  Color? get prefixIconColor => MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return _scaleScheme.primaryScale.primary.withAlpha(0x3F);
        }
        if (states.contains(MaterialState.error)) {
          return _scaleScheme.errorScale.primary;
        }
        return _scaleScheme.primaryScale.primary;
      });

  @override
  Color? get suffixIconColor => MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return _scaleScheme.primaryScale.primary.withAlpha(0x3F);
        }
        if (states.contains(MaterialState.error)) {
          return _scaleScheme.errorScale.primary;
        }
        return _scaleScheme.primaryScale.primary;
      });

  @override
  TextStyle? get labelStyle => MaterialStateTextStyle.resolveWith((states) {
        final textStyle = _textTheme.bodyLarge ?? const TextStyle();
        if (states.contains(MaterialState.disabled)) {
          return textStyle.copyWith(
              color: _scaleScheme.grayScale.border.withAlpha(0x7F));
        }
        if (states.contains(MaterialState.error)) {
          if (states.contains(MaterialState.hovered)) {
            return textStyle.copyWith(
                color: _scaleScheme.errorScale.hoverBorder);
          }
          if (states.contains(MaterialState.focused)) {
            return textStyle.copyWith(
                color: _scaleScheme.errorScale.hoverBorder);
          }
          return textStyle.copyWith(
              color: _scaleScheme.errorScale.subtleBorder);
        }
        if (states.contains(MaterialState.hovered)) {
          return textStyle.copyWith(
              color: _scaleScheme.primaryScale.hoverBorder);
        }
        if (states.contains(MaterialState.focused)) {
          return textStyle.copyWith(
              color: _scaleScheme.primaryScale.hoverBorder);
        }
        return textStyle.copyWith(color: _scaleScheme.primaryScale.border);
      });

  @override
  TextStyle? get floatingLabelStyle => labelStyle;

  @override
  TextStyle? get helperStyle => MaterialStateTextStyle.resolveWith((states) {
        final textStyle = _textTheme.bodySmall ?? const TextStyle();
        if (states.contains(MaterialState.disabled)) {
          return textStyle.copyWith(
              color: _scaleScheme.grayScale.border.withAlpha(0x7F));
        }
        return textStyle.copyWith(
            color: _scaleScheme.secondaryScale.border.withAlpha(0x7F));
      });

  @override
  TextStyle? get errorStyle => MaterialStateTextStyle.resolveWith((states) {
        final textStyle = _textTheme.bodySmall ?? const TextStyle();
        return textStyle.copyWith(color: _scaleScheme.errorScale.primary);
      });
}
