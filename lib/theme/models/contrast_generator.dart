import 'package:flutter/material.dart';

import 'radix_generator.dart';
import 'scale_color.dart';
import 'scale_input_decorator_theme.dart';
import 'scale_scheme.dart';

ScaleColor _contrastScaleColor(
    {required Brightness brightness,
    required Color frontColor,
    required Color backColor}) {
  final back = brightness == Brightness.light ? backColor : frontColor;
  final front = brightness == Brightness.light ? frontColor : backColor;

  return ScaleColor(
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
}

const kMonoSpaceFontDisplay = 'Source Code Pro';
const kMonoSpaceFontText = 'Source Code Pro';

TextTheme makeMonoSpaceTextTheme(Brightness brightness) =>
    (brightness == Brightness.light)
        ? const TextTheme(
            displayLarge: TextStyle(
                debugLabel: 'blackMonoSpace displayLarge',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.black54,
                decoration: TextDecoration.none),
            displayMedium: TextStyle(
                debugLabel: 'blackMonoSpace displayMedium',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.black54,
                decoration: TextDecoration.none),
            displaySmall: TextStyle(
                debugLabel: 'blackMonoSpace displaySmall',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.black54,
                decoration: TextDecoration.none),
            headlineLarge: TextStyle(
                debugLabel: 'blackMonoSpace headlineLarge',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.black54,
                decoration: TextDecoration.none),
            headlineMedium: TextStyle(
                debugLabel: 'blackMonoSpace headlineMedium',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.black54,
                decoration: TextDecoration.none),
            headlineSmall: TextStyle(
                debugLabel: 'blackMonoSpace headlineSmall',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.black87,
                decoration: TextDecoration.none),
            titleLarge: TextStyle(
                debugLabel: 'blackMonoSpace titleLarge',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.black87,
                decoration: TextDecoration.none),
            titleMedium: TextStyle(
                debugLabel: 'blackMonoSpace titleMedium',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black87,
                decoration: TextDecoration.none),
            titleSmall: TextStyle(
                debugLabel: 'blackMonoSpace titleSmall',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black,
                decoration: TextDecoration.none),
            bodyLarge: TextStyle(
                debugLabel: 'blackMonoSpace bodyLarge',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black87,
                decoration: TextDecoration.none),
            bodyMedium: TextStyle(
                debugLabel: 'blackMonoSpace bodyMedium',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black87,
                decoration: TextDecoration.none),
            bodySmall: TextStyle(
                debugLabel: 'blackMonoSpace bodySmall',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black54,
                decoration: TextDecoration.none),
            labelLarge: TextStyle(
                debugLabel: 'blackMonoSpace labelLarge',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black87,
                decoration: TextDecoration.none),
            labelMedium: TextStyle(
                debugLabel: 'blackMonoSpace labelMedium',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black,
                decoration: TextDecoration.none),
            labelSmall: TextStyle(
                debugLabel: 'blackMonoSpace labelSmall',
                fontFamily: kMonoSpaceFontText,
                color: Colors.black,
                decoration: TextDecoration.none),
          )
        : const TextTheme(
            displayLarge: TextStyle(
                debugLabel: 'whiteMonoSpace displayLarge',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.white70,
                decoration: TextDecoration.none),
            displayMedium: TextStyle(
                debugLabel: 'whiteMonoSpace displayMedium',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.white70,
                decoration: TextDecoration.none),
            displaySmall: TextStyle(
                debugLabel: 'whiteMonoSpace displaySmall',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.white70,
                decoration: TextDecoration.none),
            headlineLarge: TextStyle(
                debugLabel: 'whiteMonoSpace headlineLarge',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.white70,
                decoration: TextDecoration.none),
            headlineMedium: TextStyle(
                debugLabel: 'whiteMonoSpace headlineMedium',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.white70,
                decoration: TextDecoration.none),
            headlineSmall: TextStyle(
                debugLabel: 'whiteMonoSpace headlineSmall',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.white,
                decoration: TextDecoration.none),
            titleLarge: TextStyle(
                debugLabel: 'whiteMonoSpace titleLarge',
                fontFamily: kMonoSpaceFontDisplay,
                color: Colors.white,
                decoration: TextDecoration.none),
            titleMedium: TextStyle(
                debugLabel: 'whiteMonoSpace titleMedium',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white,
                decoration: TextDecoration.none),
            titleSmall: TextStyle(
                debugLabel: 'whiteMonoSpace titleSmall',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white,
                decoration: TextDecoration.none),
            bodyLarge: TextStyle(
                debugLabel: 'whiteMonoSpace bodyLarge',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white,
                decoration: TextDecoration.none),
            bodyMedium: TextStyle(
                debugLabel: 'whiteMonoSpace bodyMedium',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white,
                decoration: TextDecoration.none),
            bodySmall: TextStyle(
                debugLabel: 'whiteMonoSpace bodySmall',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white70,
                decoration: TextDecoration.none),
            labelLarge: TextStyle(
                debugLabel: 'whiteMonoSpace labelLarge',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white,
                decoration: TextDecoration.none),
            labelMedium: TextStyle(
                debugLabel: 'whiteMonoSpace labelMedium',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white,
                decoration: TextDecoration.none),
            labelSmall: TextStyle(
                debugLabel: 'whiteMonoSpace labelSmall',
                fontFamily: kMonoSpaceFontText,
                color: Colors.white,
                decoration: TextDecoration.none),
          );

ScaleScheme _contrastScaleScheme(
        {required Brightness brightness,
        required Color primaryFront,
        required Color primaryBack,
        required Color secondaryFront,
        required Color secondaryBack,
        required Color tertiaryFront,
        required Color tertiaryBack,
        required Color grayFront,
        required Color grayBack,
        required Color errorFront,
        required Color errorBack}) =>
    ScaleScheme(
        primaryScale: _contrastScaleColor(
            brightness: brightness,
            frontColor: primaryFront,
            backColor: primaryBack),
        primaryAlphaScale: _contrastScaleColor(
            brightness: brightness,
            frontColor: primaryFront,
            backColor: primaryBack),
        secondaryScale: _contrastScaleColor(
            brightness: brightness,
            frontColor: secondaryFront,
            backColor: secondaryBack),
        tertiaryScale: _contrastScaleColor(
            brightness: brightness,
            frontColor: tertiaryFront,
            backColor: tertiaryBack),
        grayScale: _contrastScaleColor(
            brightness: brightness, frontColor: grayFront, backColor: grayBack),
        errorScale: _contrastScaleColor(
            brightness: brightness,
            frontColor: errorFront,
            backColor: errorBack));

ThemeData contrastGenerator({
  required Brightness brightness,
  required ScaleConfig scaleConfig,
  required Color primaryFront,
  required Color primaryBack,
  required Color secondaryFront,
  required Color secondaryBack,
  required Color tertiaryFront,
  required Color tertiaryBack,
  required Color grayFront,
  required Color grayBack,
  required Color errorFront,
  required Color errorBack,
  TextTheme? customTextTheme,
}) {
  final textTheme = customTextTheme ?? makeRadixTextTheme(brightness);
  final scaleScheme = _contrastScaleScheme(
    brightness: brightness,
    primaryFront: primaryFront,
    primaryBack: primaryBack,
    secondaryFront: secondaryFront,
    secondaryBack: secondaryBack,
    tertiaryFront: tertiaryFront,
    tertiaryBack: tertiaryBack,
    grayFront: grayFront,
    grayBack: grayBack,
    errorFront: errorFront,
    errorBack: errorBack,
  );
  final colorScheme = scaleScheme.toColorScheme(
    brightness,
  );

  final themeData = ThemeData.from(
      colorScheme: colorScheme, textTheme: textTheme, useMaterial3: true);
  return themeData.copyWith(
      bottomSheetTheme: themeData.bottomSheetTheme.copyWith(
          elevation: 0,
          modalElevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16 * scaleConfig.borderRadiusScale),
                  topRight:
                      Radius.circular(16 * scaleConfig.borderRadiusScale)))),
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
                borderRadius:
                    BorderRadius.circular(8 * scaleConfig.borderRadiusScale))),
      ),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: scaleScheme.primaryScale.appText,
          selectionColor: scaleScheme.primaryScale.appText.withAlpha(0x7F),
          selectionHandleColor: scaleScheme.primaryScale.appText),
      inputDecorationTheme:
          ScaleInputDecoratorTheme(scaleScheme, scaleConfig, textTheme),
      extensions: <ThemeExtension<dynamic>>[
        scaleScheme,
        scaleConfig,
      ]);
}
