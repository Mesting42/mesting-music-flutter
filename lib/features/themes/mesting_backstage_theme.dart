import 'package:flutter/material.dart';

import 'music_theme_tokens.dart';

@immutable
class MestingBackstageColors extends ThemeExtension<MestingBackstageColors> {
  const MestingBackstageColors({
    required this.brightness,
    required this.ink,
    required this.surface,
    required this.surfaceRaised,
    required this.bone,
    required this.boneMuted,
    required this.line,
    required this.cobalt,
    required this.signal,
    required this.mustard,
    required this.onAccent,
  });

  final Brightness brightness;
  final Color ink;
  final Color surface;
  final Color surfaceRaised;
  final Color bone;
  final Color boneMuted;
  final Color line;
  final Color cobalt;
  final Color signal;
  final Color mustard;
  final Color onAccent;

  bool get dark => brightness == Brightness.dark;

  @override
  MestingBackstageColors copyWith({
    Brightness? brightness,
    Color? ink,
    Color? surface,
    Color? surfaceRaised,
    Color? bone,
    Color? boneMuted,
    Color? line,
    Color? cobalt,
    Color? signal,
    Color? mustard,
    Color? onAccent,
  }) {
    return MestingBackstageColors(
      brightness: brightness ?? this.brightness,
      ink: ink ?? this.ink,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      bone: bone ?? this.bone,
      boneMuted: boneMuted ?? this.boneMuted,
      line: line ?? this.line,
      cobalt: cobalt ?? this.cobalt,
      signal: signal ?? this.signal,
      mustard: mustard ?? this.mustard,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  MestingBackstageColors lerp(
    covariant MestingBackstageColors? other,
    double t,
  ) {
    if (other == null) return this;
    return MestingBackstageColors(
      brightness: t < .5 ? brightness : other.brightness,
      ink: Color.lerp(ink, other.ink, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      bone: Color.lerp(bone, other.bone, t)!,
      boneMuted: Color.lerp(boneMuted, other.boneMuted, t)!,
      line: Color.lerp(line, other.line, t)!,
      cobalt: Color.lerp(cobalt, other.cobalt, t)!,
      signal: Color.lerp(signal, other.signal, t)!,
      mustard: Color.lerp(mustard, other.mustard, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

/// A deliberately authored page-local palette for Mesting's music-facing
/// screens. It keeps the backstage direction intact even when a decorative
/// theme preset is active elsewhere in the app.
abstract final class MestingBackstage {
  static const ink = Color(0xFF101110);
  static const surface = Color(0xFF171816);
  static const surfaceRaised = Color(0xFF20211E);
  static const bone = Color(0xFFF0E8DB);
  static const boneMuted = Color(0xFFBEB5A7);
  static const line = Color(0xFF494842);
  static const cobalt = Color(0xFF2057BE);
  static const signal = Color(0xFFE64232);
  static const mustard = Color(0xFFD5A62B);

  static const darkColors = MestingBackstageColors(
    brightness: Brightness.dark,
    ink: ink,
    surface: surface,
    surfaceRaised: surfaceRaised,
    bone: bone,
    boneMuted: boneMuted,
    line: line,
    cobalt: cobalt,
    signal: signal,
    mustard: mustard,
    onAccent: bone,
  );

  static const lightColors = MestingBackstageColors(
    brightness: Brightness.light,
    ink: Color(0xFFF5F1E8),
    surface: Color(0xFFFFFDF8),
    surfaceRaised: Color(0xFFECE6DA),
    bone: Color(0xFF191B1D),
    boneMuted: Color(0xFF62625E),
    line: Color(0xFFC9C1B4),
    cobalt: Color(0xFF2057BE),
    signal: Color(0xFFC63D32),
    mustard: Color(0xFF9A7014),
    onAccent: Color(0xFFFFF8ED),
  );

  static MestingBackstageColors forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? darkColors : lightColors;

  static MestingBackstageColors colorsOf(BuildContext context) {
    return Theme.of(context).extension<MestingBackstageColors>() ??
        forBrightness(Theme.of(context).brightness);
  }

  static ThemeData themeOf(BuildContext context) {
    final base = Theme.of(context);
    final colors = forBrightness(base.brightness);
    final scheme = colors.dark
        ? const ColorScheme.dark(
            primary: signal,
            onPrimary: bone,
            secondary: cobalt,
            onSecondary: bone,
            tertiary: mustard,
            onTertiary: ink,
            error: signal,
            onError: bone,
            surface: surface,
            onSurface: bone,
            surfaceContainerHighest: surfaceRaised,
            outline: line,
            outlineVariant: line,
            shadow: Colors.black,
            inverseSurface: bone,
            onInverseSurface: ink,
            inversePrimary: cobalt,
            surfaceTint: Colors.transparent,
            scrim: Colors.black,
          )
        : const ColorScheme.light(
            primary: Color(0xFFC63D32),
            onPrimary: Color(0xFFFFF8ED),
            secondary: cobalt,
            onSecondary: Color(0xFFFFF8ED),
            tertiary: Color(0xFF9A7014),
            onTertiary: Color(0xFFFFF8ED),
            error: Color(0xFFB3261E),
            onError: Colors.white,
            surface: Color(0xFFFFFDF8),
            onSurface: Color(0xFF191B1D),
            surfaceContainerHighest: Color(0xFFECE6DA),
            outline: Color(0xFF827B70),
            outlineVariant: Color(0xFFC9C1B4),
            shadow: Color(0x332E2A24),
            inverseSurface: Color(0xFF242522),
            onInverseSurface: Color(0xFFF8F2E7),
            inversePrimary: Color(0xFFFFB4A9),
            surfaceTint: Colors.transparent,
            scrim: Colors.black,
          );
    return base.copyWith(
      brightness: colors.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.ink,
      canvasColor: colors.ink,
      dividerColor: colors.line,
      extensions: <ThemeExtension<dynamic>>[
        colors,
        MusicThemeTokens(
          glass: colors.dark
              ? const Color(0xFF171816)
              : const Color(0xF7FFFDF8),
          glassStrong: colors.surfaceRaised,
          glassSubtle: colors.surface,
          border: colors.line.withValues(alpha: colors.dark ? .4 : .72),
          borderStrong: colors.line,
          textPrimary: colors.bone,
          textSecondary: colors.boneMuted,
          textMuted: colors.dark
              ? const Color(0xFF858178)
              : const Color(0xFF817B72),
          shadow: colors.dark
              ? const Color(0xA6000000)
              : const Color(0x332E2A24),
        ),
      ],
    );
  }
}
