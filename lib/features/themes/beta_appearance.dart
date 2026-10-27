import 'package:flutter/material.dart';

/// Beta semantic colors. Functional tint, favorites and completion have separate
/// owners so changing navigation never recolors artwork or selected hearts.
/// Light tints are deepened for small text on grouped neutral surfaces.
abstract final class BetaAppearance {
  static const blue = Color(0xFF0066D9);
  static const blueOnDark = Color(0xFF0091FF);
  static const artworkCoral = Color(0xFFDE3A3D);
  static Color accent(Brightness brightness) =>
      brightness == Brightness.dark ? blueOnDark : blue;

  static Color favorite(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFFFF375F)
      : const Color(0xFFFF2D55);

  static Color success(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF30D158)
      : const Color(0xFF007A2B);

  static Color successSurface(Brightness brightness) =>
      brightness == Brightness.dark
      ? const Color(0xFF153523)
      : const Color(0xFFE9F6ED);

  static Color panel(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF1C1C1E)
      : const Color(0xFFF2F2F7);
}
