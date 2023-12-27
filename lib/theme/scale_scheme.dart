import 'package:flutter/material.dart';

import 'scale_color.dart';

class ScaleScheme extends ThemeExtension<ScaleScheme> {
  ScaleScheme(
      {required this.primaryScale,
      required this.primaryAlphaScale,
      required this.secondaryScale,
      required this.tertiaryScale,
      required this.grayScale,
      required this.errorScale});

  final ScaleColor primaryScale;
  final ScaleColor primaryAlphaScale;
  final ScaleColor secondaryScale;
  final ScaleColor tertiaryScale;
  final ScaleColor grayScale;
  final ScaleColor errorScale;

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
}
