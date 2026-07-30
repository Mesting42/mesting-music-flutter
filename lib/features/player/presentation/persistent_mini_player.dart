import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/utils/duration_format.dart';

class PersistentMiniPlayer extends ConsumerWidget {
  const PersistentMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    final track = ref.watch(currentTrackProvider);
    final state = ref.watch(playbackStateProvider).value;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? track.duration;
    final playing = state?.playing ?? false;
    final progress = duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Material(
          color: Colors.white.withValues(alpha: 0.88),
          shape: StadiumBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
          ),
          elevation: 14,
          shadowColor: const Color(0x33202945),
          child: InkWell(
            onTap: () => context.push('/player'),
            child: SizedBox(
              height: 72,
              child: Stack(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      Hero(
                        tag: 'current-track-cover',
                        child: ClipOval(
                          child: Image.asset(
                            track.coverAsset,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${track.artist} · ${formatDuration(position)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.55),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: playing ? '暂停' : '播放',
                        onPressed: handler.togglePlayPause,
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        tooltip: '播放队列',
                        onPressed: () => context.go('/music/queue'),
                        icon: const Icon(Icons.queue_music_rounded),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 3,
                        color: const Color(0xFFFF5B67),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
