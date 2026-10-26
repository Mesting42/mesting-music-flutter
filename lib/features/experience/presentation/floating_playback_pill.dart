import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../../queue/presentation/queue_page.dart';
import '../../music_platform/presentation/platform_feedback.dart';
import '../../player/presentation/persistent_mini_player.dart'
    show MiniPlayerSwipeRegion;
import 'beta_bottom_bar.dart';

/// Official Apple Music example's GlassButton.custom play pill (MIT), with live
/// Mesting media/actions. The package owns press/spring/refraction, while the
/// existing audio service and swipe contract own playback. No second player.
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
    final foreground = Theme.of(context).colorScheme.onSurface;
    Future<void> action(Future<void> Function() operation) async {
      try {
        await operation();
      } catch (error) {
        if (context.mounted) showPlatformFailure(context, error);
      }
    }

    Widget control({
      required String label,
      required IconData icon,
      required VoidCallback onTap,
    }) => Semantics(
      label: label,
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: onTap,
        child: Icon(icon, size: 23, color: foreground),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 300;
        return MiniPlayerSwipeRegion(
          onPrevious: () => action(handler.skipToPrevious),
          onNext: () => action(handler.skipToNext),
          child: GlassButton.custom(
            key: const ValueKey('beta6-official-play-pill'),
            onTap: () => context.push('/player'),
            quality: GlassQuality.premium,
            useOwnLayer: true,
            width: double.infinity,
            height: 64,
            shape: const LiquidRoundedRectangle(borderRadius: 32),
            settings: betaMusicPillGlass(context),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TrackArtwork(track: track, width: 32, height: 32),
                  ),
                  const SizedBox(width: 10),
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
                            color: foreground,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (!compact ||
                            MediaQuery.textScalerOf(context).scale(12) <= 16)
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground.withValues(alpha: .7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  control(
                    label: playing ? '暂停' : '播放',
                    icon: playing
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    onTap: () => action(playing ? handler.pause : handler.play),
                  ),
                  if (constraints.maxWidth >= 240)
                    control(
                      label: '下一首',
                      icon: CupertinoIcons.forward_end_fill,
                      onTap: () => action(handler.skipToNext),
                    ),
                  if (!compact)
                    control(
                      label: '播放队列',
                      icon: CupertinoIcons.music_note_list,
                      onTap: () => showPlaybackQueueSheet(context),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
