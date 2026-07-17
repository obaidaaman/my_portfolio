import 'package:flutter/material.dart';

/// Centralized design tokens.
///
/// Every color, spacing value, radius, and text style used in the app is
/// defined here and referenced everywhere else. Nothing in a widget file
/// should hard-code a hex color or a magic padding number — that's what
/// causes themes to drift over time. Change something here, it changes
/// everywhere.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF0B0B0C);
  static const Color surface = Color(0xFF141415);
  static const Color card = Color(0xFF1A1A1C);
  static const Color cardHover = Color(0xFF1F1F22);
  static const Color border = Color(0xFF2A2A2D);
  static const Color borderStrong = Color(0xFF3A3A3E);

  // One accent, used sparingly (labels, borders, icons) — never as a
  // large fill. Deliberately muted so it reads as "engineer" not "startup".
  static const Color accent = Color(0xFFA98A52);
  static const Color accentDim = Color(0xFF6E5936);

  static const Color text = Color(0xFFEAEAE8);
  static const Color textMuted = Color(0xFF9C9C9F);
  static const Color textDim = Color(0xFF56565A);
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double section = 88;
  static const double sectionMobile = 56;
  static const double pageMaxWidth = 1100;
  static const double horizontalPadDesktop = 80;
  static const double horizontalPadMobile = 24;
}

class AppRadius {
  AppRadius._();
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
}

class AppText {
  AppText._();

  // Serif display face — gives headings a printed, editorial feel rather
  // than the default "AI dashboard" sans-everywhere look.
  static TextStyle h1({Color color = AppColors.text}) => TextStyle(
        fontFamily: 'Georgia',
        fontSize: 46,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle h2({Color color = AppColors.text}) => TextStyle(
        fontFamily: 'Georgia',
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle h3({Color color = AppColors.text, double size = 18}) =>
      TextStyle(
        fontFamily: 'Georgia',
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle body({Color color = AppColors.text, double size = 15}) =>
      TextStyle(
        fontFamily: 'sans-serif',
        fontSize: size,
        color: color,
        height: 1.65,
      );

  // Reserved for labels, tags, meta, and data — never prose. This is what
  // signals "software engineer" rather than "marketing site".
  static TextStyle mono({
    Color color = AppColors.textMuted,
    double size = 12,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0.6,
  }) =>
      TextStyle(
        fontFamily: 'monospace',
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );
}

ThemeData buildAppTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'sans-serif'),
    splashFactory: NoSplash.splashFactory,
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      textStyle: AppText.mono(color: AppColors.text, size: 11),
    ),
  );
}