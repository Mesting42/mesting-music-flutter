import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/playback_mode.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../library/data/demo_library.dart';

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider).value ?? const [];
    final currentItem = ref.watch(currentMediaItemProvider).value;
    final mode = ref.watch(playbackModeProvider).value ?? PlaybackMode.list;
    final handler = ref.watch(audioHandlerProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: '返回音乐首页',
                  onPressed: () => context.go('/music'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOW PLAYING',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.8,
                        ),
                      ),
                      Text(
                        '播放队列',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.repeat_rounded, size: 18),
                  label: Text(mode.label),
                  onPressed: handler.cyclePlaybackMode,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(10),
                child: queue.isEmpty
                    ? const Center(child: Text('播放队列还是空的'))
                    : ListView.separated(
                        itemCount: queue.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final item = queue[index];
                          final track = trackForMediaItemId(item.id);
                          final active = currentItem?.id == item.id;
                          return Material(
                            color: active
                                ? const Color(
                                    0xFFFF5B67,
                                  ).withValues(alpha: 0.11)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            child: ListTile(
                              onTap: () => handler.playTrack(item.id),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.asset(
                                  track.coverAsset,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: active
                                      ? const Color(0xFFE94354)
                                      : null,
                                ),
                              ),
                              subtitle: Text(item.artist ?? '未知歌手'),
                              trailing: active
                                  ? const Icon(
                                      Icons.graphic_eq_rounded,
                                      color: Color(0xFFE94354),
                                    )
                                  : Text('${index + 1}'.padLeft(2, '0')),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
