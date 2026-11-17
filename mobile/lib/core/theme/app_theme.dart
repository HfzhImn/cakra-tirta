import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF101820);
  static const surface = Color(0xFF19232D);
  static const surfaceRaised = Color(0xFF202D37);
  static const border = Color(0xFF30404A);
  static const text = Color(0xFFF2F5F4);
  static const muted = Color(0xFFA3B0B4);
  static const teal = Color(0xFF67D6C2);
  static const amber = Color(0xFFF0C16B);
  static const coral = Color(0xFFE88378);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: Brightness.dark,
    surface: AppColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 15, height: 1.45),
      bodyMedium: TextStyle(fontSize: 13, height: 1.4),
      labelSmall: TextStyle(fontSize: 11, letterSpacing: 0.5),
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.teal.withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? AppColors.teal
              : AppColors.muted,
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.teal,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.teal,
      overlayColor: AppColors.teal.withValues(alpha: 0.12),
      valueIndicatorColor: AppColors.surfaceRaised,
    ),
  );
}
