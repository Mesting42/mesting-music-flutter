import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_controller.dart';

class MusicThemeBackground extends ConsumerWidget {
  const MusicThemeBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(musicThemeProvider);
    final isShinchan = style == MusicThemeStyle.shinchan;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isShinchan
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFBDEBFF), Color(0xFFFFF7D8)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF6E9),
                  Color(0xFFFFE2E5),
                  Color(0xFFE5E4FF),
                ],
              ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isShinchan)
            Image.asset(
              'assets/images/themes/shinchan_sunny.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.25, 0),
              opacity: const AlwaysStoppedAnimation(0.58),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  const Color(0xFFF9F5F0).withValues(alpha: 0.68),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
