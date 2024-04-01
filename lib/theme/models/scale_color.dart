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
    required this.background,
    required this.hoverBackground,
    required this.subtleText,
    required this.text,
  });

  Color appBackground;
  Color subtleBackground;
  Color elementBackground;
  Color hoverElementBackground;
  Color activeElementBackground;
  Color subtleBorder;
  Color border;
  Color hoverBorder;
  Color background;
  Color hoverBackground;
  Color subtleText;
  Color text;

  ScaleColor copyWith(
          {Color? appBackground,
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
          Color? text}) =>
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
        background: background ?? this.background,
        hoverBackground: hoverBackground ?? this.hoverBackground,
        subtleText: subtleText ?? this.subtleText,
        text: text ?? this.text,
      );

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
        background: Color.lerp(a.background, b.background, t) ??
            const Color(0x00000000),
        hoverBackground: Color.lerp(a.hoverBackground, b.hoverBackground, t) ??
            const Color(0x00000000),
        subtleText: Color.lerp(a.subtleText, b.subtleText, t) ??
            const Color(0x00000000),
        text: Color.lerp(a.text, b.text, t) ?? const Color(0x00000000),
      );
}
