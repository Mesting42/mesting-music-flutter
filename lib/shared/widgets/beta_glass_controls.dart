import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../features/experience/presentation/beta_bottom_bar.dart';
import '../../features/themes/beta_appearance.dart';

/// Floating controls share the navigation's optical material. Each surface
/// owns its layer: nesting glass would disable the child's refraction.
class BetaGlassButton extends StatelessWidget {
  const BetaGlassButton({
    required this.child,
    required this.onPressed,
    this.loading = false,
    this.label,
    this.height = 52,
    this.width,
    this.accent = false,
    super.key,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final bool loading, accent;
  final String? label;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    enabled: onPressed != null && !loading,
    child: RepaintBoundary(
      child: GlassButton.custom(
        onTap: onPressed ?? () {},
        enabled: onPressed != null && !loading,
        height: height,
        width: width,
        useOwnLayer: true,
        quality: GlassQuality.premium,
        stretch: .12,
        settings: betaMusicPillGlass(context),
        shape: LiquidRoundedRectangle(borderRadius: height / 2),
        child: Padding(
          padding: width == height
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 18),
          child: loading
              ? const BetaActivityIndicator()
              : DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accent
                        ? BetaAppearance.accent(Theme.of(context).brightness)
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  child: child,
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
