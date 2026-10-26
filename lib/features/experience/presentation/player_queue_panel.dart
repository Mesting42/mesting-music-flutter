import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/playback_mode.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../music_platform/presentation/platform_feedback.dart';

/// The player owns presentation, the existing audio handler owns all edits.
/// No duplicate queue or second player is created when this panel is opened.
class PlayerQueuePanel extends ConsumerWidget {
  const PlayerQueuePanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    final items =
        ref.watch(upcomingQueueProvider).value ?? handler.upcomingQueue;
    final order =
        ref.watch(playbackOrderProvider).value ?? handler.playbackOrder;
    Future<void> act(Future<void> Function() operation) async {
      try {
        await operation();
      } catch (error) {
        if (context.mounted) showPlatformFailure(context, error);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '待播列表',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _OrderButton(
                key: const ValueKey('player-shuffle'),
                label: '随机播放',
                active: order.shuffle,
                icon: CupertinoIcons.shuffle,
                onTap: () => unawaited(
                  act(() => handler.setShuffleEnabled(!order.shuffle)),
                ),
              ),
              const SizedBox(width: 8),
              _OrderButton(
                key: const ValueKey('player-repeat'),
                label: switch (order.repeat) {
                  PlaybackRepeat.off => '循环已关闭',
                  PlaybackRepeat.all => '列表循环',
                  PlaybackRepeat.one => '单曲循环',
                },
                active: order.repeat != PlaybackRepeat.off,
                icon: order.repeat == PlaybackRepeat.one
                    ? CupertinoIcons.repeat_1
                    : CupertinoIcons.repeat,
                onTap: () => unawaited(act(handler.cycleRepeat)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${items.length} 首待播放',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      '暂无待播歌曲',
                      style: TextStyle(color: Colors.white60),
                    ),
                  )
                : ReorderableListView.builder(
                    key: const ValueKey('player-inline-queue'),
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.only(bottom: 16),
                    proxyDecorator: (child, _, animation) => Material(
                      color: const Color(0xF02A3440),
                      borderRadius: BorderRadius.circular(14),
                      child: child,
                    ),
                    onReorder: (oldIndex, newIndex) => unawaited(
                      act(() => handler.reorderUpcoming(oldIndex, newIndex)),
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final track = handler.trackForId(item.id);
                      return Dismissible(
                        key: ValueKey('pending-${item.id}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => unawaited(
                          act(() async {
                            await handler.removeFromUpcomingQueue(item.id);
                          }),
                        ),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 18),
                          color: const Color(0x88F04F58),
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          minVerticalPadding: 10,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ArtworkImage(
                              uri:
                                  track?.coverAsset ??
                                  item.artUri?.toString() ??
                                  '',
                              width: 46,
                              height: 46,
                            ),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            item.artist ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () =>
                              unawaited(act(() => handler.playTrack(item.id))),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: const SizedBox(
                              width: 44,
                              height: 48,
                              child: Icon(
                                CupertinoIcons.line_horizontal_3,
                                color: Colors.white54,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderButton extends StatelessWidget {
  const _OrderButton({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
    super.key,
  });
  final String label;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    toggled: active,
    button: true,
    label: label,
    child: Tooltip(
      message: label,
      child: CupertinoButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        minimumSize: const Size(48, 48),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 38,
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: .2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.white, size: 23),
        ),
      ),
    ),
  );
}
