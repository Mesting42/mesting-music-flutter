import 'package:flutter/material.dart';

enum MusicPageTransitionDirection { forward, backward }

const musicPageTransitionDuration = Duration(milliseconds: 340);
const musicPageReverseTransitionDuration = Duration(milliseconds: 320);
const musicPageHandoffProgress = .42;
const musicPageLayerOpacityFloor = 1.0;
const musicPageUsesRouteSnapshotting = false;
const musicPageHorizontalOffset = .045;
const musicPageMotionCurve = Curves.easeInOutCubic;
const messagesPageTransitionDuration = Duration(milliseconds: 360);
const messagesPageReverseTransitionDuration = Duration(milliseconds: 280);
const messagesPageHandoffProgress = .18;
const messagesPageHorizontalOffset = .032;
const messagesPageStartScale = .992;
// Keep this aligned with the profile route beneath the editor. A different
// threshold would briefly hide both page layers while the editor is popped.
const profileEditPageHandoffProgress = musicPageHandoffProgress;
const profileEditPageTransitionDuration = Duration(milliseconds: 320);
const profileEditPageReverseTransitionDuration = Duration(milliseconds: 260);
const profileEditPageHorizontalOffset = .032;
const profileEditPageStartScale = .996;
const profileEditPageReverseMotionCurve = Curves.easeInCubic;
const collectionRevealDuration = Duration(milliseconds: 380);
const collectionRevealReverseDuration = Duration(milliseconds: 340);
const collectionRevealStartScale = .985;
const collectionRevealVerticalOffset = .022;

/// Clips the moving page content while the shared theme background stays still.
class MusicPageTransitionSurface extends StatelessWidget {
  const MusicPageTransitionSurface({
    required this.position,
    required this.child,
    this.scale,
    this.scaleAlignment = Alignment.center,
    super.key,
  });

  final Animation<Offset> position;
  final Animation<double>? scale;
  final Alignment scaleAlignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget movingContent = SlideTransition(
      key: const ValueKey('music-page-transition-moving-content'),
      position: position,
      child: child,
    );
    if (scale case final scale?) {
      movingContent = ScaleTransition(
        alignment: scaleAlignment,
        scale: scale,
        child: movingContent,
      );
    }
    return SizedBox.expand(
      child: ClipRect(
        key: const ValueKey('music-page-transition-content-clip'),
        child: movingContent,
      ),
    );
  }
}

bool musicPageLayerIsVisible({
  required AnimationStatus primaryStatus,
  required double primaryValue,
  required AnimationStatus secondaryStatus,
  required double secondaryValue,
  double handoffProgress = musicPageHandoffProgress,
}) {
  if (primaryStatus == AnimationStatus.dismissed) return false;
  if (primaryStatus == AnimationStatus.forward) {
    return primaryValue >= handoffProgress;
  }
  if (primaryStatus == AnimationStatus.reverse) {
    return primaryValue > 1 - handoffProgress;
  }
  if (secondaryStatus == AnimationStatus.dismissed) return true;
  if (secondaryStatus == AnimationStatus.forward) {
    return secondaryValue < handoffProgress;
  }
  if (secondaryStatus == AnimationStatus.reverse) {
    return secondaryValue <= 1 - handoffProgress;
  }
  return false;
}

double musicPageLayerOpacity({
  required AnimationStatus primaryStatus,
  required double primaryValue,
  required AnimationStatus secondaryStatus,
  required double secondaryValue,
  double handoffProgress = musicPageHandoffProgress,
}) {
  if (primaryStatus == AnimationStatus.dismissed) return 0;
  if (primaryStatus == AnimationStatus.forward) {
    if (primaryValue < handoffProgress) return 0;
    final progress = ((primaryValue - handoffProgress) / (1 - handoffProgress))
        .clamp(0.0, 1.0);
    return musicPageLayerOpacityFloor +
        (1 - musicPageLayerOpacityFloor) *
            musicPageMotionCurve.transform(progress);
  }
  if (primaryStatus == AnimationStatus.reverse) {
    if (primaryValue <= 1 - handoffProgress) return 0;
    final progress = ((primaryValue - (1 - handoffProgress)) / handoffProgress)
        .clamp(0.0, 1.0);
    return musicPageLayerOpacityFloor +
        (1 - musicPageLayerOpacityFloor) *
            musicPageMotionCurve.transform(progress);
  }
  if (secondaryStatus == AnimationStatus.dismissed) return 1;
  if (secondaryStatus == AnimationStatus.forward) {
    if (secondaryValue >= handoffProgress) return 0;
    final progress = (secondaryValue / handoffProgress).clamp(0.0, 1.0);
    return musicPageLayerOpacityFloor +
        (1 - musicPageLayerOpacityFloor) *
            (1 - musicPageMotionCurve.transform(progress));
  }
  if (secondaryStatus == AnimationStatus.reverse) {
    final reverseHandoff = 1 - handoffProgress;
    if (secondaryValue > reverseHandoff) return 0;
    final progress = (1 - secondaryValue / reverseHandoff).clamp(0.0, 1.0);
    return musicPageLayerOpacityFloor +
        (1 - musicPageLayerOpacityFloor) *
            musicPageMotionCurve.transform(progress);
  }
  return 0;
}

/// Hands the page surface from the outgoing route to the incoming route.
///
/// Music pages are intentionally transparent so the selected theme artwork can
/// remain in the shell. The visible page remains fully opaque during handoff:
/// applying fractional opacity to a route containing backdrop filters creates
/// an offscreen layer and can flash a dark blurred frame on Android. [Offstage]
/// preserves the strict single-layer rule while hidden routes stay alive
/// without painting, hit testing, or exposing their semantics.
class MusicPageSingleLayerHandoff extends StatelessWidget {
  const MusicPageSingleLayerHandoff({
    required this.primaryAnimation,
    required this.secondaryAnimation,
    required this.child,
    this.handoffProgress = musicPageHandoffProgress,
    super.key,
  });

  final Animation<double> primaryAnimation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final double handoffProgress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([primaryAnimation, secondaryAnimation]),
      child: child,
      builder: (context, child) {
        final visible = musicPageLayerIsVisible(
          primaryStatus: primaryAnimation.status,
          primaryValue: primaryAnimation.value,
          secondaryStatus: secondaryAnimation.status,
          secondaryValue: secondaryAnimation.value,
          handoffProgress: handoffProgress,
        );
        final opacity = musicPageLayerOpacity(
          primaryStatus: primaryAnimation.status,
          primaryValue: primaryAnimation.value,
          secondaryStatus: secondaryAnimation.status,
          secondaryValue: secondaryAnimation.value,
          handoffProgress: handoffProgress,
        );
        return Offstage(
          key: const ValueKey('music-page-outgoing-layer'),
          offstage: !visible,
          child: IgnorePointer(
            ignoring:
                primaryAnimation.status != AnimationStatus.completed ||
                secondaryAnimation.status != AnimationStatus.dismissed,
            child: Opacity(
              key: const ValueKey('music-page-layer-opacity'),
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

@immutable
class MusicPageTransitionIntent {
  const MusicPageTransitionIntent(this.direction, {this.handoffProgress});

  const MusicPageTransitionIntent.forward({this.handoffProgress})
    : direction = MusicPageTransitionDirection.forward;

  const MusicPageTransitionIntent.backward({this.handoffProgress})
    : direction = MusicPageTransitionDirection.backward;

  /// Keeps a conversation opened from the messages list on that list's
  /// earlier handoff boundary. Matching both routes prevents them from
  /// painting together while the conversation is popped.
  const MusicPageTransitionIntent.messagesConversation()
    : direction = MusicPageTransitionDirection.forward,
      handoffProgress = messagesPageHandoffProgress;

  factory MusicPageTransitionIntent.betweenTabs(int from, int to) {
    return MusicPageTransitionIntent(
      to >= from
          ? MusicPageTransitionDirection.forward
          : MusicPageTransitionDirection.backward,
    );
  }

  final MusicPageTransitionDirection direction;
  final double? handoffProgress;

  double get horizontalOffset =>
      direction == MusicPageTransitionDirection.forward
      ? musicPageHorizontalOffset
      : -musicPageHorizontalOffset;
}
