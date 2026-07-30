import 'package:flutter/material.dart';

ThemeData buildMestingTheme() {
  const seed = Color(0xFFFF5B67);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: const Color(0xFFFFFBF5),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamilyFallback: const ['Noto Sans SC', 'Microsoft YaHei', 'sans-serif'],
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.4,
        height: 1.08,
      ),
      headlineMedium: TextStyle(fontWeight: FontWeight.w900),
      titleLarge: TextStyle(fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(height: 1.55),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.76),
        foregroundColor: const Color(0xFF2A2540),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: seed,
      thumbColor: seed,
      overlayColor: Color(0x22FF5B67),
      trackHeight: 4,
    ),
  );
}
