import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';

import '../../../core/audio/playback_mode.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/utils/duration_format.dart';

class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({super.key});

  IconData _modeIcon(PlaybackMode mode) => switch (mode) {
    PlaybackMode.list => Icons.repeat_rounded,
    PlaybackMode.single => Icons.repeat_one_rounded,
    PlaybackMode.random => Icons.shuffle_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    final state = ref.watch(playbackStateProvider).value;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? Duration.zero;
    final mode = ref.watch(playbackModeProvider).value ?? PlaybackMode.list;
    final playing = state?.playing ?? false;
    final busy =
        state?.processingState == AudioProcessingState.loading ||
        state?.processingState == AudioProcessingState.buffering;
    final maxMilliseconds = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final positionMilliseconds = position.inMilliseconds.toDouble().clamp(
      0.0,
      maxMilliseconds,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: positionMilliseconds,
          max: maxMilliseconds,
          onChanged: (value) {
            handler.seek(Duration(milliseconds: value.round()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Text(
                formatDuration(position),
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Text(
                formatDuration(duration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: mode.label,
              onPressed: handler.cyclePlaybackMode,
              icon: Icon(_modeIcon(mode)),
            ),
            IconButton(
              tooltip: '上一首',
              onPressed: handler.skipToPrevious,
              icon: const Icon(Icons.skip_previous_rounded, size: 34),
            ),
            FilledButton(
              onPressed: busy ? null : handler.togglePlayPause,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(19),
                backgroundColor: const Color(0xFFFF5B67),
                foregroundColor: Colors.white,
              ),
              child: busy
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 34,
                    ),
            ),
            IconButton(
              tooltip: '下一首',
              onPressed: handler.skipToNext,
              icon: const Icon(Icons.skip_next_rounded, size: 34),
            ),
            IconButton(
              tooltip: '播放队列',
              onPressed: () => context.go('/music/queue'),
              icon: const Icon(Icons.queue_music_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
