import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/themes/app_theme.dart';
import '../features/themes/theme_controller.dart';
import '../features/auth/presentation/first_launch_auth_coordinator.dart';
import '../features/legal/presentation/disclaimer_dialog.dart';
import '../features/lyrics/presentation/lyrics_overlay_coordinator.dart';
import '../features/app_update/presentation/app_update_coordinator.dart';
import '../core/audio/playback_providers.dart';
import '../core/platform/distribution_channel.dart';
import '../features/music_platform/data/embedded_kugou_music_source.dart';
import '../features/music_platform/data/music_platform_api.dart';
import '../features/music_platform/music_platform_providers.dart';
import '../features/music_platform/platform_quality_providers.dart';
import '../features/music_platform/platform_recommendation_providers.dart';
import '../shared/models/track.dart';
import '../core/persistence/playback_persistence_controller.dart';
import '../features/library/library_providers.dart';
import '../features/recommendation/recommendation_providers.dart';
import '../features/search/search_providers.dart';
import '../features/social/presentation/social_attention_coordinator.dart';
import 'router/app_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Fire on first mount as well as switches; a guest may never emit a login
/// change, but still needs a playback owner for durable daily listening data.
final playbackOwnerBindingProvider = Provider<void>((ref) {
  final persistence = ref.watch(playbackPersistenceControllerProvider);
  ref.listen(activeLibraryOwnerProvider, (previous, ownerId) {
    unawaited(persistence.activateOwner(ownerId));
  }, fireImmediately: true);
});

class MestingMusicApp extends ConsumerWidget {
  const MestingMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicTheme = ref.watch(effectiveMusicThemeProvider);
    final audioHandler = ref.read(audioHandlerProvider);
    if (DistributionChannel.isBeta) {
      final source = ref.watch(kugouMusicSourceProvider);
      audioHandler.configureTrackPlaybackResolver((track) async {
        if (source is! EmbeddedKugouMusicSource ||
            track.source != TrackSource.kugou) {
          return track;
        }
        // Playback restored from disk must use the current platform account,
        // rather than a signed URL left over from a previous login/session.
        await ref.read(platformAccountProvider.future);
        final resolved = await source.resolveTrack(
          track,
          quality: ref.read(platformQualityProvider).preferred,
        );
        if (!resolved.isPlayable) {
          throw MusicPlatformException(resolved.availabilityMessage);
        }
        return resolved;
      });
    }
    if (DistributionChannel.isBeta) {
      ref.watch(platformRecommendationBindingProvider);
    }
    final radioController = DistributionChannel.isBeta
        ? null
        : ref.watch(endlessRadioControllerProvider);
    final playbackPersistence = ref.read(playbackPersistenceControllerProvider);
    playbackPersistence.configureLibrarySynchronizer((ownerId) {
      final repository = ref.read(libraryRepositoryProvider);
      if (repository.ownerId != ownerId) return Future.value(false);
      return repository.synchronize();
    });
    if (radioController != null) {
      audioHandler.configureRadioTrackLoader(radioController.loadMore);
    }
    // Start secure local account restoration with the app rather than waiting
    // until the user opens the profile tab or side panel.
    ref.watch(playbackOwnerBindingProvider);
    if (!DistributionChannel.isBeta) {
      ref.listen(hotMusicControllerProvider, (previous, next) {
        next.whenData((snapshot) {
          audioHandler.updateOnlineFallbackTracks(
            snapshot.recommendationTracks,
          );
          unawaited(audioHandler.prefetchRadioTracks());
        });
      });
    }
    if (!DistributionChannel.isBeta) {
      ref.listen(favoriteTracksProvider, (previous, next) {
        if (next.hasValue && previous?.value != next.value) {
          audioHandler.invalidateRadioRecommendations();
          unawaited(audioHandler.prefetchRadioTracks());
        }
      });
    }
    final application = MaterialApp.router(
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
    return DistributionChannel.isBeta
        ? LiquidGlassWidgets.wrap(
            brightnessResolver: Theme.maybeBrightnessOf,
            adaptiveQuality: true,
            child: application,
          )
        : application;
  }
}
