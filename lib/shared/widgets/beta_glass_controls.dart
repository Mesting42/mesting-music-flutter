import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../features/experience/presentation/beta_bottom_bar.dart';
import '../../features/themes/beta_appearance.dart';
import 'beta_glass_action.dart';
import '../../core/haptics/app_haptics.dart';

/// Floating controls share the navigation's optical material. Each surface
/// owns its layer: nesting glass would disable the child's refraction.
class BetaGlassButton extends StatelessWidget {
  const BetaGlassButton({
    required this.child,
    required this.onPressed,
    this.loading = false,
    this.interactionEnabled = true,
    this.hapticFeedback = true,
    this.label,
    this.height = 52,
    this.width,
    this.accent = false,
    this.blue = false,
    this.fontSize = 15,
    this.horizontalPadding = 18,
    super.key,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final bool loading, accent, blue, interactionEnabled, hapticFeedback;
  final String? label;
  final double height;
  final double fontSize;
  final double horizontalPadding;
  final double? width;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    enabled: interactionEnabled && onPressed != null && !loading,
    // Blocking a sibling request is an interaction state, not a new optical
    // material. Keep the same glass layer instead of inserting disabled opacity.
    child: ExcludeFocus(
      excluding: !interactionEnabled,
      child: IgnorePointer(
        ignoring: !interactionEnabled,
        child: RepaintBoundary(
          child: GlassButton.custom(
            onTap: () {
              if (!interactionEnabled || loading || onPressed == null) return;
              if (hapticFeedback) {
                appHaptic(
                  context,
                  blue ? AppHapticEvent.impact : AppHapticEvent.selection,
                );
              }
              onPressed!();
            },
            enabled: onPressed != null && !loading,
            height: height,
            width: width,
            useOwnLayer: true,
            quality: GlassQuality.premium,
            stretch: .12,
            // A scrolling ListView must cancel a blue button's press sheen.
            // The library's default raw-pointer mode keeps its white ambient
            // lift for the whole drag, washing white labels out while scrolling.
            persistPressOnDrag: !blue,
            ambientBaseLight: blue ? .06 : null,
            glowColor: blue ? const Color(0xFF6CA7FF) : null,
            glowOpacity: blue ? .12 : null,
            settings: blue ? betaBlueActionGlass : betaMusicPillGlass(context),
            shape: LiquidRoundedRectangle(borderRadius: height / 2),
            child: Padding(
              padding: width == height
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: loading
                  ? BetaActivityIndicator(color: blue ? Colors.white : null)
                  : DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: blue
                            ? Colors.white
                            : accent
                            ? BetaAppearance.accent(
                                Theme.of(context).brightness,
                              )
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      child: child,
                    ),
            ),
          ),
        ),
      ),
    ),
  );
}

class BetaGlassBackButton extends StatelessWidget {
  const BetaGlassBackButton({this.onPressed, super.key});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: '返回',
    child: BetaGlassButton(
      label: '返回',
      width: 48,
      height: 48,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      child: const Icon(CupertinoIcons.chevron_back, size: 22),
    ),
  );
}

/// The segmented Cupertino spinner is also used by comment sending. Keeping
/// one wrapper makes sizing/semantics consistent across every waiting state.
class BetaActivityIndicator extends StatelessWidget {
  const BetaActivityIndicator({
    this.color,
    this.radius = 10,
    this.label = '正在加载',
    super.key,
  });
  final Color? color;
  final double radius;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    liveRegion: true,
    child: CupertinoActivityIndicator(color: color, radius: radius),
  );
}

class BetaGlassField extends StatelessWidget {
  const BetaGlassField({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: GlassContainer(
      useOwnLayer: true,
      quality: GlassQuality.premium,
      settings: betaMusicPillGlass(context),
      shape: const LiquidRoundedRectangle(borderRadius: 24),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: child,
        ),
      ),
    ),
  );
}
