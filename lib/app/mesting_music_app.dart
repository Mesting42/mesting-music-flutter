import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/themes/app_theme.dart';
import '../features/themes/theme_controller.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/presentation/first_launch_auth_coordinator.dart';
import '../features/legal/presentation/disclaimer_dialog.dart';
import '../features/lyrics/presentation/lyrics_overlay_coordinator.dart';
import '../features/app_update/presentation/app_update_coordinator.dart';
import '../core/audio/playback_providers.dart';
import '../core/database/app_database.dart';
import '../core/persistence/playback_persistence_controller.dart';
import '../features/library/library_providers.dart';
import '../features/recommendation/recommendation_providers.dart';
import '../features/search/search_providers.dart';
import '../features/social/presentation/social_attention_coordinator.dart';
import 'router/app_router.dart';

class MestingMusicApp extends ConsumerWidget {
  const MestingMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicTheme = ref.watch(effectiveMusicThemeProvider);
    final audioHandler = ref.read(audioHandlerProvider);
    final radioController = ref.watch(endlessRadioControllerProvider);
    final playbackPersistence = ref.read(playbackPersistenceControllerProvider);
    playbackPersistence.configureLibrarySynchronizer((ownerId) {
      final repository = ref.read(libraryRepositoryProvider);
      if (repository.ownerId != ownerId) return Future.value(false);
      return repository.synchronize();
    });
    audioHandler.configureRadioTrackLoader(radioController.loadMore);
    // Start secure local account restoration with the app rather than waiting
    // until the user opens the profile tab or side panel.
    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((session) {
        unawaited(
          playbackPersistence.activateOwner(
            session?.user.uid ?? legacyLibraryOwnerId,
          ),
        );
      });
    });
    ref.listen(hotMusicControllerProvider, (previous, next) {
      next.whenData((snapshot) {
        audioHandler.updateOnlineFallbackTracks(snapshot.recommendationTracks);
        unawaited(audioHandler.prefetchRadioTracks());
      });
    });
    ref.listen(favoriteTracksProvider, (previous, next) {
      if (next.hasValue && previous?.value != next.value) {
        audioHandler.invalidateRadioRecommendations();
        unawaited(audioHandler.prefetchRadioTracks());
      }
    });
    return MaterialApp.router(
      title: 'Mesting 音乐',
      debugShowCheckedModeBanner: false,
      theme: buildMestingTheme(musicTheme),
      routerConfig: appRouter,
      builder: (context, child) => FirstLaunchDisclaimerCoordinator(
        child: FirstLaunchAuthCoordinator(
          child: AppUpdateCoordinator(
            child: SocialAttentionCoordinator(
              child: LyricsOverlayCoordinator(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
