import 'package:flutter/material.dart';

import 'mesting_palette.dart';
import 'music_theme_preset.dart';
import 'music_theme_tokens.dart';

ThemeData buildMestingTheme(MusicThemePreset preset) {
  final seed = preset.accent;
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: preset.dark ? Brightness.dark : Brightness.light,
    surface: preset.dark
        ? MestingPalette.darkSurface
        : MestingPalette.lightSurface,
  );
  final tokens = MusicThemeTokens.forBrightness(scheme.brightness);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [tokens],
    scaffoldBackgroundColor: Colors.transparent,
    fontFamilyFallback: const ['Noto Sans SC', 'Microsoft YaHei', 'sans-serif'],
    textTheme: TextTheme(
      displaySmall: TextStyle(
        color: tokens.textPrimary,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.4,
        height: 1.08,
      ),
      headlineMedium: TextStyle(
        color: tokens.textPrimary,
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(
        color: tokens.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: tokens.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(color: tokens.textPrimary, height: 1.55),
      bodyMedium: TextStyle(color: tokens.textPrimary),
      bodySmall: TextStyle(color: tokens.textSecondary),
      labelLarge: TextStyle(color: tokens.textPrimary),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: tokens.glassSubtle,
        foregroundColor: tokens.textPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.glassSubtle,
      hintStyle: TextStyle(color: tokens.textMuted),
      labelStyle: TextStyle(color: tokens.textSecondary),
      prefixIconColor: tokens.textSecondary,
      suffixIconColor: tokens.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: tokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: tokens.border),
      ),
    ),
    dividerColor: tokens.border,
    listTileTheme: ListTileThemeData(
      textColor: tokens.textPrimary,
      iconColor: tokens.textSecondary,
      subtitleTextStyle: TextStyle(color: tokens.textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: tokens.glassSubtle,
      side: BorderSide(color: tokens.border),
      labelStyle: TextStyle(color: tokens.textPrimary),
      secondaryLabelStyle: TextStyle(color: tokens.textPrimary),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: seed,
      thumbColor: seed,
      overlayColor: seed.withValues(alpha: 0.14),
      trackHeight: 4,
    ),
  );
}
