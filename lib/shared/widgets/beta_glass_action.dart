import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../features/experience/presentation/beta_bottom_bar.dart';
import '../../core/haptics/app_haptics.dart';

/// Stable blue action glass. Adaptive body tint preserves background luminance,
/// which turns this blue almost cyan over light scrolling content. Clear body
/// uses alpha tint while retaining the renderer's specular, lens and refraction.
const betaBlueActionGlass = LiquidGlassSettings(
  glassColor: Color(0xF20063D8),
  bodyMode: GlassBodyMode.clear,
  thickness: 32,
  blur: 2,
  lightIntensity: .3,
  ambientStrength: .15,
  refractiveIndex: 1.25,
  chromaticAberration: .01,
  fresnelStrength: .12,
  saturation: 1.2,
);

/// Material owns optics and feedback; callers retain validation, saving and
/// navigation. Sibling surfaces must each own a layer to preserve refraction.
class BetaGlassAction extends StatelessWidget {
  const BetaGlassAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.blue = true,
    super.key,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    final foreground = blue
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      enabled: onPressed != null && !loading,
      label: label,
      child: Tooltip(
        message: label,
        child: RepaintBoundary(
          child: GlassButton.custom(
            onTap: () {
              if (loading || onPressed == null) return;
              appHaptic(context, AppHapticEvent.impact);
              onPressed!();
            },
            enabled: onPressed != null && !loading,
            width: 48,
            height: 48,
            useOwnLayer: true,
            quality: GlassQuality.premium,
            stretch: .15,
            shape: const LiquidRoundedRectangle(borderRadius: 24),
            settings: blue ? betaBlueActionGlass : betaMusicPillGlass(context),
            child: loading
                ? CupertinoActivityIndicator(color: foreground)
                : Icon(icon, color: foreground, size: blue ? 25 : 27),
          ),
        ),
      ),
    );
  }
}
