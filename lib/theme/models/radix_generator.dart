import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:radix_colors/radix_colors.dart';

import '../../tools/tools.dart';
import 'scale_color.dart';
import 'scale_scheme.dart';

enum RadixThemeColor {
  scarlet, // tomato + red + violet
  babydoll, // crimson + purple + pink
  vapor, // pink + cyan + plum
  gold, // yellow + amber + orange
  garden, // grass + orange + brown
  forest, // green + brown + amber
  arctic, // sky + teal + violet
  lapis, // blue + indigo + mint
  eggplant, // violet + purple + indigo
  lime, // lime + yellow + orange
  grim, // mauve + slate + sage
}

enum _RadixBaseColor {
  tomato,
  red,
  crimson,
  pink,
  plum,
  purple,
  violet,
  indigo,
  blue,
  sky,
  cyan,
  teal,
  mint,
  green,
  grass,
  lime,
  yellow,
  amber,
  orange,
  brown,
}

RadixColor _radixGraySteps(
    Brightness brightness, bool alpha, _RadixBaseColor baseColor) {
  switch (baseColor) {
    case _RadixBaseColor.tomato:
    case _RadixBaseColor.red:
    case _RadixBaseColor.crimson:
    case _RadixBaseColor.pink:
    case _RadixBaseColor.plum:
    case _RadixBaseColor.purple:
    case _RadixBaseColor.violet:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.mauveA
              : RadixColors.mauveA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.mauve
              : RadixColors.mauve);
    case _RadixBaseColor.indigo:
    case _RadixBaseColor.blue:
    case _RadixBaseColor.sky:
    case _RadixBaseColor.cyan:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.slateA
              : RadixColors.slateA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.slate
              : RadixColors.slate);
    case _RadixBaseColor.teal:
    case _RadixBaseColor.mint:
    case _RadixBaseColor.green:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.sageA
              : RadixColors.sageA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.sage
              : RadixColors.sage);
    case _RadixBaseColor.lime:
    case _RadixBaseColor.grass:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.oliveA
              : RadixColors.oliveA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.olive
              : RadixColors.olive);
    case _RadixBaseColor.yellow:
    case _RadixBaseColor.amber:
    case _RadixBaseColor.orange:
    case _RadixBaseColor.brown:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.sandA
              : RadixColors.sandA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.sand
              : RadixColors.sand);
  }
}

RadixColor _radixColorSteps(
    Brightness brightness, bool alpha, _RadixBaseColor baseColor) {
  switch (baseColor) {
    case _RadixBaseColor.tomato:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.tomatoA
              : RadixColors.tomatoA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.tomato
              : RadixColors.tomato);
    case _RadixBaseColor.red:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.redA
              : RadixColors.redA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.red
              : RadixColors.red);
    case _RadixBaseColor.crimson:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.crimsonA
              : RadixColors.crimsonA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.crimson
              : RadixColors.crimson);
    case _RadixBaseColor.pink:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.pinkA
              : RadixColors.pinkA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.pink
              : RadixColors.pink);
    case _RadixBaseColor.plum:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.plumA
              : RadixColors.plumA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.plum
              : RadixColors.plum);
    case _RadixBaseColor.purple:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.purpleA
              : RadixColors.purpleA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.purple
              : RadixColors.purple);
    case _RadixBaseColor.violet:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.violetA
              : RadixColors.violetA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.violet
              : RadixColors.violet);
    case _RadixBaseColor.indigo:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.indigoA
              : RadixColors.indigoA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.indigo
              : RadixColors.indigo);
    case _RadixBaseColor.blue:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.blueA
              : RadixColors.blueA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.blue
              : RadixColors.blue);
    case _RadixBaseColor.sky:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.skyA
              : RadixColors.skyA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.sky
              : RadixColors.sky);
    case _RadixBaseColor.cyan:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.cyanA
              : RadixColors.cyanA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.cyan
              : RadixColors.cyan);
    case _RadixBaseColor.teal:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.tealA
              : RadixColors.tealA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.teal
              : RadixColors.teal);
    case _RadixBaseColor.mint:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.mintA
              : RadixColors.mintA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.mint
              : RadixColors.mint);
    case _RadixBaseColor.green:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.greenA
              : RadixColors.greenA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.green
              : RadixColors.green);
    case _RadixBaseColor.grass:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.grassA
              : RadixColors.grassA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.grass
              : RadixColors.grass);
    case _RadixBaseColor.lime:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.limeA
              : RadixColors.limeA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.lime
              : RadixColors.lime);
    case _RadixBaseColor.yellow:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.yellowA
              : RadixColors.yellowA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.yellow
              : RadixColors.yellow);
    case _RadixBaseColor.amber:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.amberA
              : RadixColors.amberA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.amber
              : RadixColors.amber);
    case _RadixBaseColor.orange:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.orangeA
              : RadixColors.orangeA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.orange
              : RadixColors.orange);
    case _RadixBaseColor.brown:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.brownA
              : RadixColors.brownA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.brown
              : RadixColors.brown);
  }
}

extension ToScaleColor on RadixColor {
  ScaleColor toScale(RadixScaleExtra scaleExtra) => ScaleColor(
        appBackground: step1,
        subtleBackground: step2,
        elementBackground: step3,
        hoverElementBackground: step4,
        activeElementBackground: step5,
        subtleBorder: step6,
        border: step7,
        hoverBorder: step8,
        background: step9,
        hoverBackground: step10,
        subtleText: step11,
        appText: step12,
        foregroundText: scaleExtra.foregroundText,
      );
}

class RadixScaleExtra {
  RadixScaleExtra({required this.foregroundText});

  final Color foregroundText;
}

class RadixScheme {
  const RadixScheme({
    required this.primaryScale,
    required this.primaryExtra,
    required this.primaryAlphaScale,
    required this.primaryAlphaExtra,
    required this.secondaryScale,
    required this.secondaryExtra,
    required this.tertiaryScale,
    required this.tertiaryExtra,
    required this.grayScale,
    required this.grayExtra,
    required this.errorScale,
    required this.errorExtra,
  });

  final RadixColor primaryScale;
  final RadixScaleExtra primaryExtra;
  final RadixColor primaryAlphaScale;
  final RadixScaleExtra primaryAlphaExtra;
  final RadixColor secondaryScale;
  final RadixScaleExtra secondaryExtra;
  final RadixColor tertiaryScale;
  final RadixScaleExtra tertiaryExtra;
  final RadixColor grayScale;
  final RadixScaleExtra grayExtra;
  final RadixColor errorScale;
  final RadixScaleExtra errorExtra;

  ScaleScheme toScale() => ScaleScheme(
        primaryScale: primaryScale.toScale(primaryExtra),
        primaryAlphaScale: primaryAlphaScale.toScale(primaryAlphaExtra),
        secondaryScale: secondaryScale.toScale(secondaryExtra),
        tertiaryScale: tertiaryScale.toScale(tertiaryExtra),
        grayScale: grayScale.toScale(grayExtra),
        errorScale: errorScale.toScale(errorExtra),
      );
}

RadixScheme _radixScheme(Brightness brightness, RadixThemeColor themeColor) {
  late RadixScheme radixScheme;
  switch (themeColor) {
    // tomato + red + violet
    case RadixThemeColor.scarlet:
      radixScheme = RadixScheme(
        primaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.tomato),
        primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        primaryAlphaScale:
            _radixColorSteps(brightness, true, _RadixBaseColor.tomato),
        primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
        secondaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.red),
        secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        tertiaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.violet),
        tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.tomato),
        grayExtra: RadixScaleExtra(foregroundText: Colors.white),
        errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.yellow),
        errorExtra: RadixScaleExtra(foregroundText: Colors.black),
      );

    // crimson + purple + pink
    case RadixThemeColor.babydoll:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.crimson),
          primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.crimson),
          primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.purple),
          secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.pink),
          tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          grayScale:
              _radixGraySteps(brightness, false, _RadixBaseColor.crimson),
          grayExtra: RadixScaleExtra(foregroundText: Colors.white),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.orange),
          errorExtra: RadixScaleExtra(foregroundText: Colors.white));
    // pink + cyan + plum
    case RadixThemeColor.vapor:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.pink),
          primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.pink),
          primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.cyan),
          secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.plum),
          tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.pink),
          grayExtra: RadixScaleExtra(foregroundText: Colors.white),
          errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red),
          errorExtra: RadixScaleExtra(foregroundText: Colors.white));
    // yellow + amber + orange
    case RadixThemeColor.gold:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.yellow),
          primaryExtra: RadixScaleExtra(foregroundText: Colors.black),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.yellow),
          primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.black),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.amber),
          secondaryExtra: RadixScaleExtra(foregroundText: Colors.black),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.orange),
          tertiaryExtra: RadixScaleExtra(foregroundText: Colors.black),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.yellow),
          grayExtra: RadixScaleExtra(foregroundText: Colors.white),
          errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red),
          errorExtra: RadixScaleExtra(foregroundText: Colors.white));
    // grass + orange + brown
    case RadixThemeColor.garden:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.grass),
          primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.grass),
          primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.orange),
          secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.brown),
          tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.grass),
          grayExtra: RadixScaleExtra(foregroundText: Colors.white),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.tomato),
          errorExtra: RadixScaleExtra(foregroundText: Colors.white));
    // green + brown + amber
    case RadixThemeColor.forest:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.green),
          primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.green),
          primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.brown),
          secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.amber),
          tertiaryExtra: RadixScaleExtra(foregroundText: Colors.black),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.green),
          grayExtra: RadixScaleExtra(foregroundText: Colors.white),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.tomato),
          errorExtra: RadixScaleExtra(foregroundText: Colors.white));

    // sky + teal + violet
    case RadixThemeColor.arctic:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.sky),
          primaryExtra: RadixScaleExtra(foregroundText: Colors.black),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.sky),
          primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.black),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.teal),
          secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.violet),
          tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.sky),
          grayExtra: RadixScaleExtra(foregroundText: Colors.white),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.crimson),
          errorExtra: RadixScaleExtra(foregroundText: Colors.white));
    // blue + indigo + mint
    case RadixThemeColor.lapis:
      radixScheme = RadixScheme(
        primaryScale: _radixColorSteps(brightness, false, _RadixBaseColor.blue),
        primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        primaryAlphaScale:
            _radixColorSteps(brightness, true, _RadixBaseColor.blue),
        primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
        secondaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.indigo),
        secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        tertiaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.mint),
        tertiaryExtra: RadixScaleExtra(foregroundText: Colors.black),
        grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.blue),
        grayExtra: RadixScaleExtra(foregroundText: Colors.white),
        errorScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.crimson),
        errorExtra: RadixScaleExtra(foregroundText: Colors.white),
      );
    // violet + purple + indigo
    case RadixThemeColor.eggplant:
      radixScheme = RadixScheme(
        primaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.violet),
        primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        primaryAlphaScale:
            _radixColorSteps(brightness, true, _RadixBaseColor.violet),
        primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
        secondaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.purple),
        secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        tertiaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.indigo),
        tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.violet),
        grayExtra: RadixScaleExtra(foregroundText: Colors.white),
        errorScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.crimson),
        errorExtra: RadixScaleExtra(foregroundText: Colors.white),
      );
    // lime + yellow + orange
    case RadixThemeColor.lime:
      radixScheme = RadixScheme(
        primaryScale: _radixColorSteps(brightness, false, _RadixBaseColor.lime),
        primaryExtra: RadixScaleExtra(foregroundText: Colors.black),
        primaryAlphaScale:
            _radixColorSteps(brightness, true, _RadixBaseColor.lime),
        primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.black),
        secondaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.yellow),
        secondaryExtra: RadixScaleExtra(foregroundText: Colors.black),
        tertiaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.orange),
        tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.lime),
        grayExtra: RadixScaleExtra(foregroundText: Colors.white),
        errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red),
        errorExtra: RadixScaleExtra(foregroundText: Colors.white),
      );
    // mauve + slate + sage
    case RadixThemeColor.grim:
      radixScheme = RadixScheme(
        primaryScale:
            _radixGraySteps(brightness, false, _RadixBaseColor.tomato),
        primaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        primaryAlphaScale:
            _radixColorSteps(brightness, true, _RadixBaseColor.tomato),
        primaryAlphaExtra: RadixScaleExtra(foregroundText: Colors.white),
        secondaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.indigo),
        secondaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        tertiaryScale:
            _radixColorSteps(brightness, false, _RadixBaseColor.teal),
        tertiaryExtra: RadixScaleExtra(foregroundText: Colors.white),
        grayScale: brightness == Brightness.dark
            ? RadixColors.dark.gray
            : RadixColors.gray,
        grayExtra: RadixScaleExtra(foregroundText: Colors.white),
        errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red),
        errorExtra: RadixScaleExtra(foregroundText: Colors.white),
      );
  }
  return radixScheme;
}

ColorScheme _scaleToColorScheme(Brightness brightness, ScaleScheme scale) =>
    ColorScheme(
      brightness: brightness,
      primary: scale.primaryScale.background, // reviewed
      onPrimary: scale.primaryScale.foregroundText, // reviewed
      primaryContainer:
          Colors.red, // scale.primaryScale.hoverElementBackground,
      onPrimaryContainer: Colors.green, //scale.primaryScale.subtleText,
      secondary: scale.secondaryScale.background,
      onSecondary: scale.secondaryScale.foregroundText,
      secondaryContainer: scale.secondaryScale.hoverElementBackground,
      onSecondaryContainer: scale.secondaryScale.subtleText,
      tertiary: scale.tertiaryScale.background,
      onTertiary: scale.tertiaryScale.foregroundText,
      tertiaryContainer: scale.tertiaryScale.hoverElementBackground,
      onTertiaryContainer: scale.tertiaryScale.subtleText,
      error: scale.errorScale.background,
      onError: scale.errorScale.foregroundText,
      errorContainer: scale.errorScale.hoverElementBackground,
      onErrorContainer: scale.errorScale.subtleText,
      background: scale.grayScale.appBackground, // reviewed
      onBackground: scale.grayScale.appText, // reviewed
      surface: scale.primaryScale.background, // reviewed
      onSurface: scale.primaryScale.foregroundText, // reviewed
      surfaceVariant: scale.primaryScale.elementBackground,
      onSurfaceVariant:
          scale.primaryScale.foregroundText, // ?? reviewed a little
      outline: scale.primaryScale.border,
      outlineVariant: scale.primaryScale.subtleBorder,
      shadow: const Color(0xFF000000),
      scrim: scale.primaryScale.background,
      inverseSurface: scale.primaryScale.subtleText,
      onInverseSurface: scale.primaryScale.subtleBackground,
      inversePrimary: scale.primaryScale.hoverBackground,
      surfaceTint: scale.primaryAlphaScale.hoverElementBackground,
    );

ChatTheme makeChatTheme(ScaleScheme scale, TextTheme textTheme) =>
    DefaultChatTheme(
        primaryColor: scale.primaryScale.background,
        secondaryColor: scale.secondaryScale.background,
        backgroundColor: scale.grayScale.appBackground,
        inputBackgroundColor: Colors.blue,
        inputBorderRadius: BorderRadius.zero,
        inputTextDecoration: InputDecoration(
          filled: true,
          fillColor: scale.primaryScale.elementBackground,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
        inputContainerDecoration:
            BoxDecoration(color: scale.primaryScale.border),
        inputPadding: const EdgeInsets.all(9),
        inputTextColor: scale.primaryScale.appText,
        attachmentButtonIcon: const Icon(Icons.attach_file),
        sentMessageBodyTextStyle: TextStyle(
          color: scale.primaryScale.foregroundText,
          decorationColor: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        sentEmojiMessageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 64,
        ),
        receivedMessageBodyTextStyle: TextStyle(
          color: scale.primaryScale.foregroundText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        receivedEmojiMessageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 64,
        ));

TextTheme _makeTextTheme(Brightness brightness) {
  late final TextTheme textTheme;
  if (Platform.isIOS) {
    textTheme = (brightness == Brightness.light)
        ? Typography.blackCupertino
        : Typography.whiteCupertino;
  } else if (Platform.isMacOS) {
    textTheme = (brightness == Brightness.light)
        ? Typography.blackRedwoodCity
        : Typography.whiteRedwoodCity;
  } else if (Platform.isAndroid || Platform.isFuchsia) {
    textTheme = (brightness == Brightness.light)
        ? Typography.blackMountainView
        : Typography.whiteMountainView;
  } else if (Platform.isLinux) {
    textTheme = (brightness == Brightness.light)
        ? Typography.blackHelsinki
        : Typography.whiteHelsinki;
  } else if (Platform.isWindows) {
    textTheme = (brightness == Brightness.light)
        ? Typography.blackRedmond
        : Typography.whiteRedmond;
  } else {
    log.warning('unknown platform');
    textTheme = (brightness == Brightness.light)
        ? Typography.blackHelsinki
        : Typography.whiteHelsinki;
  }
  return textTheme;
}

ThemeData radixGenerator(Brightness brightness, RadixThemeColor themeColor) {
  final textTheme = _makeTextTheme(brightness);
  final radix = _radixScheme(brightness, themeColor);
  final scaleScheme = radix.toScale();
  final colorScheme = _scaleToColorScheme(brightness, scaleScheme);

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
          checkmarkColor: scaleScheme.primaryScale.background,
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
      focusColor: scaleScheme.primaryScale.activeElementBackground,
      hoverColor: scaleScheme.primaryScale.hoverElementBackground,
      inputDecorationTheme: themeData.inputDecorationTheme.copyWith(
          border: OutlineInputBorder(
              borderSide: BorderSide(color: scaleScheme.primaryScale.border),
              borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.all(8),
          labelStyle: TextStyle(
              color: scaleScheme.primaryScale.subtleText.withAlpha(127)),
          floatingLabelStyle:
              TextStyle(color: scaleScheme.primaryScale.subtleText),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: scaleScheme.primaryScale.hoverBorder, width: 2),
              borderRadius: BorderRadius.circular(8))),
      extensions: <ThemeExtension<dynamic>>[
        scaleScheme,
      ]);
}
