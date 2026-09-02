import 'package:flutter/material.dart';

import 'nawa_colors.dart';

/// Nawa typography tokens.
///
/// Font family names are configured ahead of the actual font files being
/// added under `assets/fonts/`. Until those files are added and declared
/// in `pubspec.yaml`, Flutter falls back to the platform default font.
class NawaTypography {
  const NawaTypography._();

  static const String fontFamilyEn = 'Poppins';
  static const String fontFamilyAr = 'Tajawal';

  /// Returns the brand font family for the given locale language code.
  static String fontFamilyFor(String languageCode) {
    return languageCode == 'ar' ? fontFamilyAr : fontFamilyEn;
  }

  static TextTheme textTheme(String languageCode) {
    final family = fontFamilyFor(languageCode);
    return TextTheme(
      displayLarge: TextStyle(fontFamily: family, fontSize: 40, fontWeight: FontWeight.w700, color: NawaColors.textPrimary),
      displayMedium: TextStyle(fontFamily: family, fontSize: 32, fontWeight: FontWeight.w700, color: NawaColors.textPrimary),
      headlineLarge: TextStyle(fontFamily: family, fontSize: 28, fontWeight: FontWeight.w600, color: NawaColors.textPrimary),
      headlineMedium: TextStyle(fontFamily: family, fontSize: 24, fontWeight: FontWeight.w600, color: NawaColors.textPrimary),
      titleLarge: TextStyle(fontFamily: family, fontSize: 20, fontWeight: FontWeight.w600, color: NawaColors.textPrimary),
      titleMedium: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600, color: NawaColors.textPrimary),
      bodyLarge: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400, color: NawaColors.textPrimary),
      bodyMedium: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400, color: NawaColors.textSecondary),
      bodySmall: TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400, color: NawaColors.textMuted),
      labelLarge: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600, color: NawaColors.textPrimary),
    );
  }
}
