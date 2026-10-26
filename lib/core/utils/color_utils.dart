import 'package:flutter/material.dart';

/// Parses "#RRGGBB", "RRGGBB" or "#AARRGGBB" (as stored by the admin panel).
Color hexToColor(String? hex, {Color fallback = const Color(0xFF8E7CF8)}) {
  if (hex == null) return fallback;
  var h = hex.trim().replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return fallback;
  final value = int.tryParse(h, radix: 16);
  return value == null ? fallback : Color(value);
}

extension ColorShade on Color {
  /// Lighter tint for soft backgrounds.
  Color tint(double amount) => Color.lerp(this, Colors.white, amount.clamp(0.0, 1.0))!;

  /// Darker shade for text/icons on top of a tint.
  Color shade(double amount) => Color.lerp(this, Colors.black, amount.clamp(0.0, 1.0))!;
}
