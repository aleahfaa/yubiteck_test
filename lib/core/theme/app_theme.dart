import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.black,
      onPrimary: AppColors.white,
      secondary: AppColors.grey700,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.black,
      error: AppColors.black,
      onError: AppColors.white,
      outline: AppColors.grey300,
    ),
    textTheme: AppTextTheme.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.grey200,
      thickness: 1,
      space: 1,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: AppColors.overlayLight,
    splashColor: AppColors.overlayLight,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.black,
    ),
    iconTheme: const IconThemeData(color: AppColors.black),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.white,
      onPrimary: AppColors.black,
      secondary: AppColors.grey300,
      onSecondary: AppColors.black,
      surface: AppColors.black,
      onSurface: AppColors.white,
      error: AppColors.white,
      onError: AppColors.black,
      outline: AppColors.grey700,
    ),
    textTheme: AppTextTheme.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.grey800,
      thickness: 1,
      space: 1,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: AppColors.overlayDark,
    splashColor: AppColors.overlayDark,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.white,
    ),
    iconTheme: const IconThemeData(color: AppColors.white),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.grey900,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.grey900,
      surfaceTintColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
