import 'package:flutter/material.dart';

/// Local presentation transitions leave the shared transport and audio owner
/// mounted. AnimatedSwitcher retains outgoing content only for its exit, and
/// removes it when interrupted transitions finish.
class PlayerContentTransition extends StatelessWidget {
  const PlayerContentTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.direction = 1,
    super.key,
  });
  final Widget child;
  final Duration duration;
  final double direction;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration,
    reverseDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 280),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (content, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: Offset(
            (content.key == child.key ? 1 : -1) * direction * .045,
            .018,
          ),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween(begin: .985, end: 1.0).animate(animation),
          child: content,
        ),
      ),
    ),
    child: child,
  );
}
