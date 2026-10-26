import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../features/experience/presentation/beta_bottom_bar.dart';

/// The pill's actual optical material, shared by playback and editing menus.
/// Every popover owns one premium layer; nested surfaces would lose refraction.
class BetaGlassMenuSurface extends StatelessWidget {
  const BetaGlassMenuSurface({
    required this.child,
    this.radius = 24,
    super.key,
  });
  final Widget child;
  final double radius;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: GlassContainer(
      key: const ValueKey('beta13-glass-menu-surface'),
      quality: GlassQuality.premium,
      useOwnLayer: true,
      settings: betaMusicPillGlass(context),
      shape: LiquidRoundedRectangle(borderRadius: radius),
      child: Material(type: MaterialType.transparency, child: child),
    ),
  );
}

/// Positions from the measured trigger, then animates only the bounded menu.
/// The underlying capsule stays in place. Await route.completed so a selected
/// action opens its next surface only after the downward dismissal finishes.
Future<T?> showBetaGlassPopover<T>({
  required BuildContext context,
  required Rect anchor,
  required WidgetBuilder builder,
  double width = 300,
  String label = '关闭菜单',
}) async {
  final media = MediaQuery.of(context);
  final route = RawDialogRoute<T>(
    barrierDismissible: true,
    barrierLabel: label,
    barrierColor: Colors.black.withValues(alpha: .08),
    transitionDuration: media.disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 320),
    pageBuilder: (dialog, animation, _) => CustomSingleChildLayout(
      delegate: BetaMenuLayout(anchor: anchor, media: media, width: width),
      child: AnimatedBuilder(
        animation: animation,
        child: Theme(
          data: Theme.of(context),
          child: BetaGlassMenuSurface(child: builder(dialog)),
        ),
        builder: (_, child) {
          final p = Curves.easeOutCubic.transform(animation.value);
          return Opacity(
            opacity: p,
            child: Transform.translate(
              offset: Offset(0, (1 - p) * 30),
              child: Transform.scale(
                scale:
                    .7 +
                    .3 *
                        (animation.status == AnimationStatus.reverse
                            ? p
                            : Curves.easeOutBack.transform(animation.value)),
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
      ),
    ),
    transitionBuilder: (_, _, _, child) => child,
  );
  final value = await Navigator.of(context, rootNavigator: true).push<T>(route);
  await route.completed;
  return value;
}

/// Also used by selection toolbars, whose anchors are supplied by EditableText.
class BetaMenuLayout extends SingleChildLayoutDelegate {
  const BetaMenuLayout({
    required this.anchor,
    required this.media,
    required this.width,
  });
  final Rect anchor;
  final MediaQueryData media;
  final double width;
  double get top => media.padding.top + 12;
  double get bottom =>
      media.size.height -
      math.max(media.viewInsets.bottom, media.padding.bottom) -
      12;
  bool get above =>
      anchor.top - top >= bottom - anchor.bottom || anchor.top - top > 260;
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.min(width, constraints.maxWidth - 24),
        maxHeight: math.max(
          48,
          above ? anchor.top - top - 8 : bottom - anchor.bottom - 8,
        ),
      );
  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    (anchor.center.dx - childSize.width / 2).clamp(
      12.0,
      math.max(12, size.width - childSize.width - 12),
    ),
    (above ? anchor.top - childSize.height - 8 : anchor.bottom + 8).clamp(
      top,
      math.max(top, bottom - childSize.height),
    ),
  );
  @override
  bool shouldRelayout(BetaMenuLayout old) =>
      anchor != old.anchor || media != old.media || width != old.width;
}
