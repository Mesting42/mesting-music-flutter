import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/themes/startup_style.dart';

/// Pure presentation: no timer, decoder, audio, navigation or readiness gate.
/// Keep the user's complete original artwork, including its typography. The
/// bootstrap replaces this surface as soon as real dependencies are ready.
class StartupImageSurface extends StatelessWidget {
  const StartupImageSurface({required this.style, super.key})
    : assert(
        style == StartupStyle.staticOne || style == StartupStyle.staticTwo,
      );
  final StartupStyle style;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
    child: IgnorePointer(
      child: ColoredBox(
        color: style == StartupStyle.staticOne
            ? const Color(0xFFEC4B43)
            : const Color(0xFFE55449),
        child: SizedBox.expand(
          child: Image.asset(
            style.posterAsset!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
          ),
        ),
      ),
    ),
  );
}
