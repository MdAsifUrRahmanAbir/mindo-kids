import 'package:flutter/material.dart';

/// Palette taken from the UI demo (soft lavender canvas, deep navy text,
/// purple primary) blended with the Mindo Kids brand colours
/// (blue, yellow, green, purple, coral).
///
/// Per-world / per-badge colours are NOT here — they come from Firestore.
class AppColors {
  AppColors._();

  // Canvas
  static const Color background = Color(0xFFF4F2FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFEDEAFF);
  static const Color border = Color(0xFFE6E2F8);

  // Text
  static const Color navy = Color(0xFF261B5C);
  static const Color text = Color(0xFF2E2A4F);
  static const Color textMuted = Color(0xFF7C7898);

  // Brand / actions
  static const Color primary = Color(0xFF6C4CF1);
  static const Color primaryLight = Color(0xFF8E74FF);
  static const Color primarySoft = Color(0xFFE7E1FF);

  static const Color brandBlue = Color(0xFF1F63D8);
  static const Color brandYellow = Color(0xFFFFC21A);
  static const Color brandGreen = Color(0xFF35B24A);
  static const Color brandPurple = Color(0xFF7B3FBF);
  static const Color brandCoral = Color(0xFFE8455F);

  // Feedback
  static const Color success = Color(0xFF3CC37A);
  static const Color successSoft = Color(0xFFDDF7E9);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorSoft = Color(0xFFFFE3E3);
  static const Color highlight = Color(0xFFFFE9A8);
  static const Color star = Color(0xFFFFC21A);
  static const Color streak = Color(0xFFFF7A45);

  /// Fallback card colours when a world has no colour set in Firestore.
  static const List<Color> cardFallbacks = [
    Color(0xFF8E7CF8),
    Color(0xFF6FD3A0),
    Color(0xFFFF8E8E),
    Color(0xFFFFD45C),
    Color(0xFF6CB8FF),
    Color(0xFFFFA86B),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8063FF), Color(0xFF6243EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
