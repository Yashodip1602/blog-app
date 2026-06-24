import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color secondary;
  final LinearGradient primaryGradient;
  final LinearGradient backgroundGradient;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color glassBackground;
  final Color glassBorder;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.secondary,
    required this.primaryGradient,
    required this.backgroundGradient,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.glassBackground,
    required this.glassBorder,
  });

  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }

  static const AppColors dark = AppColors(
    background: Colors.black,
    surface: Color(0xFF121212),
    surfaceLight: Color(0xFF1E1E1E),
    primary: Color(0xFF6366F1), // Kept Indigo for branding/buttons
    secondary: Color(0xFFA855F7), // Kept Purple for gradients
    primaryGradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Colors.black,
        Color(0xFF0A0A0A),
        Color(0xFF121212),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFA0A0A0), // Neutral gray
    textHint: Color(0xFF6E6E6E), // Darker gray
    glassBackground: Color(0x1AFFFFFF), // 10% white
    glassBorder: Color(0x26FFFFFF), // 15% white
  );

  static const AppColors light = AppColors(
    background: Color(0xFFF8FAFC), // Slate 50
    surface: Color(0xFFFFFFFF), // White
    surfaceLight: Color(0xFFF1F5F9), // Slate 100
    primary: Color(0xFF4F46E5), // Deeper Indigo for contrast
    secondary: Color(0xFF9333EA), // Deeper Purple
    primaryGradient: LinearGradient(
      colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFFF8FAFC),
        Color(0xFFF1F5F9),
        Color(0xFFE2E8F0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    textPrimary: Color(0xFF0F172A), // Slate 900
    textSecondary: Color(0xFF475569), // Slate 600
    textHint: Color(0xFF94A3B8), // Slate 400
    glassBackground: Color(0x4DFFFFFF), // 30% white for better contrast
    glassBorder: Color(0x33000000), // 20% black border
  );
}
