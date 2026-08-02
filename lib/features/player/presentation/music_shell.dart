import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/adaptive_layout.dart';
import '../../social/listen_together_providers.dart';
import '../../themes/music_theme_background.dart';
import 'music_navigation.dart';
import 'persistent_mini_player.dart';

bool musicShellUsesImmersiveProfileMediaOverlay(String location) {
  final path = Uri.parse(location).path;
  return path == '/profile/avatar' || path == '/profile/background';
}

class MusicShell extends ConsumerWidget {
  const MusicShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(listenTogetherControllerProvider);
    final searchOverlay = location.startsWith('/music/search');
    final settingsOverlay = location.startsWith('/music/settings');
    final fullPlayer = location.startsWith('/player');
    final conversationOverlay = location.startsWith('/social/chat/');
    final profileMediaOverlay = musicShellUsesImmersiveProfileMediaOverlay(
      location,
    );
    final pageWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final showMiniPlayer =
        !fullPlayer && !settingsOverlay && !conversationOverlay;
    final showNavigation =
        !searchOverlay &&
        !fullPlayer &&
        !settingsOverlay &&
        !conversationOverlay &&
        !profileMediaOverlay;
    final useNavigationRail =
        showNavigation && mestingUsesNavigationRailForWidth(pageWidth);
    final contentLeft = useNavigationRail ? musicNavigationRailWidth : 0.0;
    final childContent = fullPlayer || profileMediaOverlay
        ? child
        : MestingAdaptiveContentFrame(child: child);
    return MusicThemeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              left: contentLeft,
              top: 0,
              right: 0,
              bottom: 0,
              child: childContent,
            ),
            if (showMiniPlayer)
              Positioned(
                left: contentLeft + 12,
                right: 12,
                bottom: searchOverlay
                    ? bottomInset + 8
                    : useNavigationRail
                    ? bottomInset + 16
                    : musicBottomNavigationContentHeight + bottomInset,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: pageWidth >= MestingAdaptiveBreakpoints.medium
                          ? 720
                          : double.infinity,
                    ),
                    child: IgnorePointer(
                      ignoring: profileMediaOverlay,
                      child: AnimatedOpacity(
                        opacity: profileMediaOverlay ? 0 : 1,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        child: const PersistentMiniPlayer(),
                      ),
                    ),
                  ),
                ),
              ),
            if (useNavigationRail)
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: MusicNavigationRail(),
              ),
            if (showNavigation && !useNavigationRail)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: profileMediaOverlay,
                  child: AnimatedOpacity(
                    opacity: profileMediaOverlay ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: const MusicBottomNavigation(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
