import 'package:flutter/material.dart';

import 'nawa_colors.dart';
import 'nawa_radius.dart';
import 'nawa_spacing.dart';
import 'nawa_typography.dart';

/// Builds the centralized Nawa light theme.
class NawaTheme {
  const NawaTheme._();

  static ThemeData light({String languageCode = 'en'}) {
    final textTheme = NawaTypography.textTheme(languageCode);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NawaColors.primary,
      brightness: Brightness.light,
      primary: NawaColors.primary,
      surface: NawaColors.surface,
      error: NawaColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NawaColors.background,
      fontFamily: NawaTypography.fontFamilyFor(languageCode),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: NawaColors.surface,
        foregroundColor: NawaColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: NawaColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NawaRadius.lg),
          side: const BorderSide(color: NawaColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NawaColors.primary,
          foregroundColor: NawaColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NawaRadius.md)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NawaColors.primary,
          side: const BorderSide(color: NawaColors.border),
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NawaRadius.md)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NawaColors.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NawaColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: NawaSpacing.lg, vertical: NawaSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NawaRadius.md),
          borderSide: const BorderSide(color: NawaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NawaRadius.md),
          borderSide: const BorderSide(color: NawaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NawaRadius.md),
          borderSide: const BorderSide(color: NawaColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NawaRadius.md),
          borderSide: const BorderSide(color: NawaColors.error),
        ),
        hintStyle: textTheme.bodyMedium,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NawaColors.surface,
        selectedItemColor: NawaColors.primary,
        unselectedItemColor: NawaColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: NawaColors.border, thickness: 1),
    );
  }
}
