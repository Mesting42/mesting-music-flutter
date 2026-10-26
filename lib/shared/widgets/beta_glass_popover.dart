import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../features/experience/presentation/beta_bottom_bar.dart';

const betaMenuOpenDuration = Duration(milliseconds: 360);
const betaMenuCloseDuration = Duration(milliseconds: 220);
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
        blur: betaMusicPillGlass(context).blur + 1,
        visibility: visibility,
      ),
      shape: LiquidRoundedRectangle(borderRadius: radius),
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

  void _bindAnimation() {
    _stretch = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutBack,
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
      _bindAnimation();
    }
  }

  @override
  void dispose() {
    _stretch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: widget.animation,
      child: widget.child,
      builder: (context, child) {
        final value = reduceMotion
            ? 1.0
            : widget.animation.value.clamp(0.0, 1.0);
        final reveal = Curves.easeOutCubic.transform(value);
        // CurvedAnimation retains the active curve when a gesture reverses
        // mid-flight. Switching curves by status would visibly jump in size.
        final stretch = reduceMotion ? 1.0 : _stretch.value;
        return Transform.translate(
          offset: Offset(0, widget.origin.y * (1 - reveal) * 14),
          child: Transform.scale(
            scaleX: .9 + .1 * stretch,
            scaleY: .74 + .26 * stretch,
            alignment: widget.origin,
            child: BetaGlassMenuSurface(
              radius: 24 + (1 - reveal) * 12,
              visibility: reveal,
              child: Opacity(opacity: reveal, child: child),
            ),
          ),
        );
      },
    );
  }
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
