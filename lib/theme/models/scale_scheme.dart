import 'dart:ui';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';

import 'scale_color.dart';

enum ScaleKind { primary, primaryAlpha, secondary, tertiary, gray, error }

class ScaleScheme extends ThemeExtension<ScaleScheme> {
  ScaleScheme({
    required this.primaryScale,
    required this.primaryAlphaScale,
    required this.secondaryScale,
    required this.tertiaryScale,
    required this.grayScale,
    required this.errorScale,
  });

  final ScaleColor primaryScale;
  final ScaleColor primaryAlphaScale;
  final ScaleColor secondaryScale;
  final ScaleColor tertiaryScale;
  final ScaleColor grayScale;
  final ScaleColor errorScale;

  ScaleColor scale(ScaleKind kind) {
    switch (kind) {
      case ScaleKind.primary:
        return primaryScale;
      case ScaleKind.primaryAlpha:
        return primaryAlphaScale;
      case ScaleKind.secondary:
        return secondaryScale;
      case ScaleKind.tertiary:
        return tertiaryScale;
      case ScaleKind.gray:
        return grayScale;
      case ScaleKind.error:
        return errorScale;
    }
  }

  @override
  ScaleScheme copyWith(
          {ScaleColor? primaryScale,
          ScaleColor? primaryAlphaScale,
          ScaleColor? secondaryScale,
          ScaleColor? tertiaryScale,
          ScaleColor? grayScale,
          ScaleColor? errorScale}) =>
      ScaleScheme(
        primaryScale: primaryScale ?? this.primaryScale,
        primaryAlphaScale: primaryAlphaScale ?? this.primaryAlphaScale,
        secondaryScale: secondaryScale ?? this.secondaryScale,
        tertiaryScale: tertiaryScale ?? this.tertiaryScale,
        grayScale: grayScale ?? this.grayScale,
        errorScale: errorScale ?? this.errorScale,
      );

  @override
  ScaleScheme lerp(ScaleScheme? other, double t) {
    if (other is! ScaleScheme) {
      return this;
    }
    return ScaleScheme(
      primaryScale: ScaleColor.lerp(primaryScale, other.primaryScale, t),
      primaryAlphaScale:
          ScaleColor.lerp(primaryAlphaScale, other.primaryAlphaScale, t),
      secondaryScale: ScaleColor.lerp(secondaryScale, other.secondaryScale, t),
      tertiaryScale: ScaleColor.lerp(tertiaryScale, other.tertiaryScale, t),
      grayScale: ScaleColor.lerp(grayScale, other.grayScale, t),
      errorScale: ScaleColor.lerp(errorScale, other.errorScale, t),
    );
  }

  ColorScheme toColorScheme(Brightness brightness) => ColorScheme(
        brightness: brightness,
        primary: primaryScale.primary, // reviewed
        onPrimary: primaryScale.primaryText, // reviewed
        // primaryContainer: primaryScale.hoverElementBackground,
        // onPrimaryContainer: primaryScale.subtleText,
        secondary: secondaryScale.primary,
        onSecondary: secondaryScale.primaryText,
        // secondaryContainer: secondaryScale.hoverElementBackground,
        // onSecondaryContainer: secondaryScale.subtleText,
        tertiary: tertiaryScale.primary,
        onTertiary: tertiaryScale.primaryText,
        // tertiaryContainer: tertiaryScale.hoverElementBackground,
        // onTertiaryContainer: tertiaryScale.subtleText,
        error: errorScale.primary,
        onError: errorScale.primaryText,
        // errorContainer: errorScale.hoverElementBackground,
        // onErrorContainer: errorScale.subtleText,
        background: grayScale.appBackground, // reviewed
        onBackground: grayScale.appText, // reviewed
        surface: primaryScale.appBackground, // reviewed
        onSurface: primaryScale.appText, // reviewed
        surfaceVariant: secondaryScale.appBackground,
        onSurfaceVariant: secondaryScale.appText,
        outline: primaryScale.border,
        outlineVariant: secondaryScale.border,
        shadow: primaryScale.primary.darken(80),
        //scrim: primaryScale.background,
        // inverseSurface: primaryScale.subtleText,
        // onInverseSurface: primaryScale.subtleBackground,
        // inversePrimary: primaryScale.hoverBackground,
        // surfaceTint: primaryAlphaScale.hoverElementBackground,
      );
}

class ScaleConfig extends ThemeExtension<ScaleConfig> {
  ScaleConfig({
    required this.useVisualIndicators,
    required this.preferBorders,
    required this.borderRadiusScale,
  });

  final bool useVisualIndicators;
  final bool preferBorders;
  final double borderRadiusScale;

  @override
  ScaleConfig copyWith({
    bool? useVisualIndicators,
    bool? preferBorders,
    double? borderRadiusScale,
  }) =>
      ScaleConfig(
        useVisualIndicators: useVisualIndicators ?? this.useVisualIndicators,
        preferBorders: preferBorders ?? this.preferBorders,
        borderRadiusScale: borderRadiusScale ?? this.borderRadiusScale,
      );

  @override
  ScaleConfig lerp(ScaleConfig? other, double t) {
    if (other is! ScaleConfig) {
      return this;
    }
    return ScaleConfig(
        useVisualIndicators:
            t < .5 ? useVisualIndicators : other.useVisualIndicators,
        preferBorders: t < .5 ? preferBorders : other.preferBorders,
        borderRadiusScale:
            lerpDouble(borderRadiusScale, other.borderRadiusScale, t) ?? 1);
  }
}
