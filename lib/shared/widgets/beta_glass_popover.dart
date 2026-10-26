import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../features/experience/presentation/beta_bottom_bar.dart';
import '../../core/haptics/app_haptics.dart';

const betaMenuOpenDuration = Duration(milliseconds: 400);
const betaMenuCloseDuration = Duration(milliseconds: 240);
const double betaMenuAnchorGap = 8;

/// The pill's actual optical material, shared by playback and editing menus.
/// Every popover owns one premium layer; nested surfaces would lose refraction.
class BetaGlassMenuSurface extends StatelessWidget {
  const BetaGlassMenuSurface({
    required this.child,
    this.radius = 24,
    this.visibility = 1,
    super.key,
  });
  final Widget child;
  final double radius;
  final double visibility;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: GlassContainer(
      key: const ValueKey('beta13-glass-menu-surface'),
      quality: GlassQuality.premium,
      useOwnLayer: true,
      settings: betaMusicPillGlass(context).copyWith(
        blur: betaMusicPillGlass(context).blur + 2,
        visibility: visibility,
      ),
      shape: LiquidRoundedRectangle(borderRadius: radius),
      clipBehavior: Clip.hardEdge,
      child: Material(type: MaterialType.transparency, child: child),
    ),
  );
}

/// One motion contract for editing and playback menus. The trigger-facing edge
/// stays anchored as the glass stretches into place with a small spring settle.
/// Dismissal uses a shorter, non-overshooting contraction toward the same edge.
class BetaGlassMenuTransition extends StatefulWidget {
  const BetaGlassMenuTransition({
    required this.animation,
    required this.origin,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Alignment origin;
  final Widget child;

  @override
  State<BetaGlassMenuTransition> createState() =>
      _BetaGlassMenuTransitionState();
}

class _BetaGlassMenuTransitionState extends State<BetaGlassMenuTransition> {
  late CurvedAnimation _stretch;
  late CurvedAnimation _reveal;

  void _bindAnimation() {
    _stretch = CurvedAnimation(
      parent: widget.animation,
      curve: const _MenuSpringCurve(),
      reverseCurve: Curves.easeInOutCubic,
    );
    _reveal = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0, .45, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _bindAnimation();
  }

  @override
  void didUpdateWidget(covariant BetaGlassMenuTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _stretch.dispose();
      _reveal.dispose();
      _bindAnimation();
    }
  }

  @override
  void dispose() {
    _stretch.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // A screen-sampling shader cannot share an ancestor's nonuniform scale
    // with its text: on Android its retained filter can sample a different
    // rectangle during composition. Animate the surface's REAL layout bounds
    // instead. The unscaled content is laid out once and clipped inside those
    // bounds, so every frame has matching optics, clipping and hit testing.
    return FadeTransition(
      opacity: reduceMotion ? kAlwaysCompleteAnimation : _reveal,
      child: BetaGlassMenuSurface(
        child: AnimatedBuilder(
          animation: widget.animation,
          child: widget.child,
          builder: (context, child) {
            final stretch = reduceMotion ? 1.0 : _stretch.value;
            return ClipRect(
              child: Align(
                alignment: widget.origin,
                widthFactor: .82 + .18 * stretch,
                heightFactor: .16 + .84 * stretch,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A lightly damped growth, calibrated to the supplied Music menu reference.
/// These are application parameters, not claims about Apple's private physics.
class _MenuSpringCurve extends Curve {
  const _MenuSpringCurve();
  @override
  double transformInternal(double t) =>
      1 - math.exp(-9 * t) * (math.cos(11 * t) + 9 / 11 * math.sin(11 * t));
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
  appHaptic(context, AppHapticEvent.impact);
  final media = MediaQuery.of(context);
  final layout = BetaMenuLayout(anchor: anchor, media: media, width: width);
  final route = _BetaGlassPopoverRoute<T>(
    label: label,
    reduceMotion: media.disableAnimations,
    pageBuilder: (dialog, animation, _) => CustomSingleChildLayout(
      delegate: layout,
      child: Theme(
        data: Theme.of(context),
        child: BetaGlassMenuTransition(
          animation: animation,
          origin: layout.motionOrigin,
          child: builder(dialog),
        ),
      ),
    ),
  );
  final value = await Navigator.of(context, rootNavigator: true).push<T>(route);
  await route.completed;
  return value;
}

class _BetaGlassPopoverRoute<T> extends RawDialogRoute<T> {
  _BetaGlassPopoverRoute({
    required super.pageBuilder,
    required String label,
    required this.reduceMotion,
  }) : super(
         barrierDismissible: true,
         barrierLabel: label,
         barrierColor: Colors.black.withValues(alpha: .08),
         transitionDuration: reduceMotion
             ? Duration.zero
             : betaMenuOpenDuration,
         transitionBuilder: (_, _, _, child) => child,
       );

  final bool reduceMotion;

  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : betaMenuCloseDuration;
}

/// Also used by selection toolbars, whose anchors are supplied by EditableText.
class BetaMenuLayout extends SingleChildLayoutDelegate {
  const BetaMenuLayout({
    required this.anchor,
    required this.media,
    required this.width,
    this.gap = betaMenuAnchorGap,
  });
  final Rect anchor;
  final MediaQueryData media;
  final double width;
  final double gap;
  double get top => media.padding.top + 12;
  double get bottom =>
      media.size.height -
      math.max(media.viewInsets.bottom, media.padding.bottom) -
      12;
  bool get above =>
      anchor.top - top >= bottom - anchor.bottom || anchor.top - top > 260;

  /// Match the real trigger even when the menu is clamped against screen edges.
  Alignment get motionOrigin {
    final menuWidth = math.max(1.0, math.min(width, media.size.width - 24));
    final left = (anchor.center.dx - menuWidth / 2).clamp(
      12.0,
      math.max(12.0, media.size.width - menuWidth - 12),
    );
    return Alignment(
      ((anchor.center.dx - left) / menuWidth * 2 - 1).clamp(-1.0, 1.0),
      above ? 1 : -1,
    );
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.min(width, constraints.maxWidth - 24),
        maxHeight: math.max(
          48,
          above ? anchor.top - top - gap : bottom - anchor.bottom - gap,
        ),
      );
  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    (anchor.center.dx - childSize.width / 2).clamp(
      12.0,
      math.max(12, size.width - childSize.width - 12),
    ),
    (above ? anchor.top - childSize.height - gap : anchor.bottom + gap).clamp(
      top,
      math.max(top, bottom - childSize.height),
    ),
  );
  @override
  bool shouldRelayout(BetaMenuLayout old) =>
      anchor != old.anchor ||
      media != old.media ||
      width != old.width ||
      gap != old.gap;
}
