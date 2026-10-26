import 'package:flutter/material.dart';

/// Beta.7 uses the red sampled from the user's pinned Apple Music reference.
/// Keep this independent of IP progress palettes and alternate player artwork.
abstract final class BetaAppearance {
  static const red = Color(0xFFDE3A3D);
  static const redOnDark = Color(0xFFFF777A);
  static Color accent(Brightness brightness) =>
      brightness == Brightness.dark ? redOnDark : red;

  static Color panel(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF291D20)
      : const Color(0xFFFCF0F0);
}
