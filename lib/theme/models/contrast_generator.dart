import 'package:flutter/material.dart';

import 'radix_generator.dart';
import 'scale_color.dart';
import 'scale_input_decorator_theme.dart';
import 'scale_scheme.dart';

ScaleScheme _contrastScale(Brightness brightness) {
  final back = brightness == Brightness.light ? Colors.white : Colors.black;
  final front = brightness == Brightness.light ? Colors.black : Colors.white;

  final primaryScale = ScaleColor(
    appBackground: back,
    subtleBackground: back,
    elementBackground: back,
    hoverElementBackground: back,
    activeElementBackground: back,
    subtleBorder: front,
    border: front,
    hoverBorder: front,
    primary: back,
    hoverPrimary: back,
    subtleText: front,
    appText: front,
    primaryText: front,
    borderText: back,
    dialogBorder: front,
    calloutBackground: front,
    calloutText: back,
  );

  return ScaleScheme(
      primaryScale: primaryScale,
      primaryAlphaScale: primaryScale,
      secondaryScale: primaryScale,
      tertiaryScale: primaryScale,
      grayScale: primaryScale,
      errorScale: primaryScale);
}

ThemeData contrastGenerator(Brightness brightness) {
  final textTheme = makeRadixTextTheme(brightness);
  final scaleScheme = _contrastScale(brightness);
  final colorScheme = scaleScheme.toColorScheme(brightness);
  final scaleConfig = ScaleConfig(useVisualIndicators: true);

  final themeData = ThemeData.from(
      colorScheme: colorScheme, textTheme: textTheme, useMaterial3: true);
  return themeData.copyWith(
      bottomSheetTheme: themeData.bottomSheetTheme.copyWith(
          elevation: 0,
          modalElevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)))),
      canvasColor: scaleScheme.primaryScale.subtleBackground,
      chipTheme: themeData.chipTheme.copyWith(
          backgroundColor: scaleScheme.primaryScale.elementBackground,
          selectedColor: scaleScheme.primaryScale.activeElementBackground,
          surfaceTintColor: scaleScheme.primaryScale.hoverElementBackground,
          checkmarkColor: scaleScheme.primaryScale.border,
          side: BorderSide(color: scaleScheme.primaryScale.border)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: scaleScheme.primaryScale.elementBackground,
            foregroundColor: scaleScheme.primaryScale.appText,
            disabledBackgroundColor: scaleScheme.grayScale.elementBackground,
            disabledForegroundColor: scaleScheme.grayScale.appText,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: scaleScheme.primaryScale.border),
                borderRadius: BorderRadius.circular(8))),
      ),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: scaleScheme.primaryScale.appText,
          selectionColor: scaleScheme.primaryScale.appText.withAlpha(0x7F),
          selectionHandleColor: scaleScheme.primaryScale.appText),
      inputDecorationTheme: ScaleInputDecoratorTheme(scaleScheme, textTheme),
      extensions: <ThemeExtension<dynamic>>[
        scaleScheme,
        scaleConfig,
      ]);
}
