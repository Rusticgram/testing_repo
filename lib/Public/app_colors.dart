import 'package:flutter/material.dart';

class AppColors {
  // Core Palette
  static const Color primaryColor = Color(0xFF5B4239);
  static const Color secondaryColor = Color(0xFFEAE4CE);
  static const Color lightBrown = Color(0xFFFFF9E5);
  static const Color titleColor = Color(0xFF1E293B);
  static const Color body3Color = Color(0xFF475569);
  static const Color body6Color = Color(0xFF646871);
  static const Color body7Color = Color(0xFF14304A);

  // Utility Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFD9D9D9);
  static const Color redColor = Color(0xFFFC6600);
  static const Color greenColor = Color(0xFF3CCF4E);

  // UI Elements
  static const Color dividerColor = Color(0xFFBDBEC2);
  static const Color fillColor = Color(0xFFF8F6EF);
  static const Color fill1Color = Color(0xFFF1EDDE);
  static const Color labelColor = Color(0xFF4E535C);
  static const Color label1Color = Color(0xFF555454);
  static const Color iconColor = Color(0xFF292D32);

  // Hint Text (with alpha blending)
  static Color darkGrey = Colors.grey.shade600;
  static Color hint1Color = const Color(0xFF383D48).withAlpha((0.4 * 255).toInt());
  static Color hint2Color = const Color(0xFF000000).withAlpha((0.4 * 255).toInt());
}
