import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';

/// Rounded, highly readable type as the concept doc asks for:
/// Fredoka for playful headings, Nunito for UI/body text.
class AppTheme {
  AppTheme._();

  static TextStyle heading(
    double size, {
    Color color = AppColors.navy,
    FontWeight weight = FontWeight.w600,
    double height = 1.15,
  }) => GoogleFonts.fredoka(fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle body(
    double size, {
    Color color = AppColors.text,
    FontWeight weight = FontWeight.w600,
    double height = 1.35,
  }) => GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color, height: height);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final text = GoogleFonts.nunitoTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.text, displayColor: AppColors.navy);

    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: heading(44, weight: FontWeight.w700),
        displayMedium: heading(36, weight: FontWeight.w700),
        headlineLarge: heading(30, weight: FontWeight.w700),
        headlineMedium: heading(26),
        headlineSmall: heading(22),
        titleLarge: heading(20),
        titleMedium: body(16, color: AppColors.navy, weight: FontWeight.w800),
        titleSmall: body(14, color: AppColors.navy, weight: FontWeight.w800),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.navy,
        titleTextStyle: heading(20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: body(15, color: AppColors.textMuted, weight: FontWeight.w500),
        labelStyle: body(15, color: AppColors.textMuted, weight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        contentTextStyle: body(14, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: body(15, weight: FontWeight.w800),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : null),
      ),
    );
  }
}
