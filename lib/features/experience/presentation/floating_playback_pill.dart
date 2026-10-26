import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/mesting_glass.dart';
import '../../themes/music_theme_tokens.dart';
import '../../queue/presentation/queue_page.dart';
import '../../music_platform/presentation/platform_feedback.dart';
import '../../player/presentation/persistent_mini_player.dart'
    show MiniPlayerSwipeRegion;

/// Playback observes the existing service, so navigation never creates another
/// player, queue, notification, or independent favorite state.
class FloatingPlaybackPill extends ConsumerWidget {
  const FloatingPlaybackPill({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(currentMediaItemProvider).value == null) {
      return const SizedBox.shrink();
    }
    final track = ref.watch(currentTrackProvider);
    final playing = ref.watch(playbackStateProvider).value?.playing ?? false;
    final handler = ref.watch(audioHandlerProvider);
    Future<void> action(Future<void> Function() operation) async {
      try {
        await operation();
      } catch (error) {
        if (context.mounted) showPlatformFailure(context, error);
      }
    }

    return MiniPlayerSwipeRegion(
      onPrevious: () => action(handler.skipToPrevious),
      onNext: () => action(handler.skipToNext),
      child: MestingGlass(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/player'),
            borderRadius: BorderRadius.circular(32),
            child: SizedBox(
              key: const ValueKey('beta5-playback-pill'),
              height:
                  64 +
                  (MediaQuery.textScalerOf(context).scale(27) - 27).clamp(
                    0.0,
                    45.0,
                  ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ArtworkImage(
                        uri: track.coverAsset,
                        width: 44,
                        height: 44,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.musicThemeTokens.textPrimary,
                            ),
                          ),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: context.musicThemeTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: playing ? '暂停' : '播放',
                      onPressed: () =>
                          action(playing ? handler.pause : handler.play),
                      icon: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 31,
                      ),
                    ),
                    IconButton(
                      tooltip: '下一首',
                      onPressed: () => action(handler.skipToNext),
                      icon: const Icon(Icons.skip_next_rounded, size: 29),
                    ),
                    IconButton(
                      tooltip: '播放队列',
                      onPressed: () => showPlaybackQueueSheet(context),
                      icon: const Icon(Icons.queue_music_rounded, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
