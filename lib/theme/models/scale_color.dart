import 'dart:ui';

class ScaleColor {
  ScaleColor({
    required this.appBackground,
    required this.subtleBackground,
    required this.elementBackground,
    required this.hoverElementBackground,
    required this.activeElementBackground,
    required this.subtleBorder,
    required this.border,
    required this.hoverBorder,
    required this.primary,
    required this.hoverPrimary,
    required this.subtleText,
    required this.appText,
    required this.primaryText,
    required this.borderText,
    required this.dialogBorder,
    required this.calloutBackground,
    required this.calloutText,
  });

  Color appBackground;
  Color subtleBackground;
  Color elementBackground;
  Color hoverElementBackground;
  Color activeElementBackground;
  Color subtleBorder;
  Color border;
  Color hoverBorder;
  Color primary;
  Color hoverPrimary;
  Color subtleText;
  Color appText;
  Color primaryText;
  Color borderText;
  Color dialogBorder;
  Color calloutBackground;
  Color calloutText;

  ScaleColor copyWith({
    Color? appBackground,
    Color? subtleBackground,
    Color? elementBackground,
    Color? hoverElementBackground,
    Color? activeElementBackground,
    Color? subtleBorder,
    Color? border,
    Color? hoverBorder,
    Color? background,
    Color? hoverBackground,
    Color? subtleText,
    Color? appText,
    Color? foregroundText,
    Color? borderText,
    Color? dialogBorder,
    Color? calloutBackground,
    Color? calloutText,
  }) =>
      ScaleColor(
          appBackground: appBackground ?? this.appBackground,
          subtleBackground: subtleBackground ?? this.subtleBackground,
          elementBackground: elementBackground ?? this.elementBackground,
          hoverElementBackground:
              hoverElementBackground ?? this.hoverElementBackground,
          activeElementBackground:
              activeElementBackground ?? this.activeElementBackground,
          subtleBorder: subtleBorder ?? this.subtleBorder,
          border: border ?? this.border,
          hoverBorder: hoverBorder ?? this.hoverBorder,
          primary: background ?? this.primary,
          hoverPrimary: hoverBackground ?? this.hoverPrimary,
          subtleText: subtleText ?? this.subtleText,
          appText: appText ?? this.appText,
          primaryText: foregroundText ?? this.primaryText,
          borderText: borderText ?? this.borderText,
          dialogBorder: dialogBorder ?? this.dialogBorder,
          calloutBackground: calloutBackground ?? this.calloutBackground,
          calloutText: calloutText ?? this.calloutText);

  // ignore: prefer_constructors_over_static_methods
  static ScaleColor lerp(ScaleColor a, ScaleColor b, double t) => ScaleColor(
        appBackground: Color.lerp(a.appBackground, b.appBackground, t) ??
            const Color(0x00000000),
        subtleBackground:
            Color.lerp(a.subtleBackground, b.subtleBackground, t) ??
                const Color(0x00000000),
        elementBackground:
            Color.lerp(a.elementBackground, b.elementBackground, t) ??
                const Color(0x00000000),
        hoverElementBackground:
            Color.lerp(a.hoverElementBackground, b.hoverElementBackground, t) ??
                const Color(0x00000000),
        activeElementBackground: Color.lerp(
                a.activeElementBackground, b.activeElementBackground, t) ??
            const Color(0x00000000),
        subtleBorder: Color.lerp(a.subtleBorder, b.subtleBorder, t) ??
            const Color(0x00000000),
        border: Color.lerp(a.border, b.border, t) ?? const Color(0x00000000),
        hoverBorder: Color.lerp(a.hoverBorder, b.hoverBorder, t) ??
            const Color(0x00000000),
        primary: Color.lerp(a.primary, b.primary, t) ?? const Color(0x00000000),
        hoverPrimary: Color.lerp(a.hoverPrimary, b.hoverPrimary, t) ??
            const Color(0x00000000),
        subtleText: Color.lerp(a.subtleText, b.subtleText, t) ??
            const Color(0x00000000),
        appText: Color.lerp(a.appText, b.appText, t) ?? const Color(0x00000000),
        primaryText: Color.lerp(a.primaryText, b.primaryText, t) ??
            const Color(0x00000000),
        borderText: Color.lerp(a.borderText, b.borderText, t) ??
            const Color(0x00000000),
        dialogBorder: Color.lerp(a.dialogBorder, b.dialogBorder, t) ??
            const Color(0x00000000),
        calloutBackground:
            Color.lerp(a.calloutBackground, b.calloutBackground, t) ??
                const Color(0x00000000),
        calloutText: Color.lerp(a.calloutText, b.calloutText, t) ??
            const Color(0x00000000),
      );
}
