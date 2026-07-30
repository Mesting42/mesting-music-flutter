import 'package:flutter/material.dart';

import '../../themes/music_theme_background.dart';
import 'persistent_mini_player.dart';

class MusicShell extends StatelessWidget {
  const MusicShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MusicThemeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: child),
            const Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: SafeArea(top: false, child: PersistentMiniPlayer()),
            ),
          ],
        ),
      ),
    );
  }
}
