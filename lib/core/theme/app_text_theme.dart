import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextTheme {
  static TextTheme _base(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        color: primary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: primary, fontSize: 15, height: 1.4),
      bodyMedium: TextStyle(color: secondary, fontSize: 13, height: 1.4),
      labelLarge: TextStyle(
        color: primary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      labelSmall: TextStyle(
        color: secondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  static TextTheme light = _base(AppColors.black, AppColors.grey600);
  static TextTheme dark = _base(AppColors.white, AppColors.grey400);
}
