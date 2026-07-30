import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/playback_providers.dart';
import '../lyrics_providers.dart';

class LyricsPanel extends ConsumerStatefulWidget {
  const LyricsPanel({super.key});

  @override
  ConsumerState<LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends ConsumerState<LyricsPanel> {
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _followActiveLine(int index) {
    if (index < 0 || index == _lastActiveIndex) return;
    _lastActiveIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = ((index - 2).clamp(0, index) * 58.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final lyrics = ref.watch(lyricsProvider(track.lyricsAsset));

    return lyrics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('歌词暂时无法读取\n$error', textAlign: TextAlign.center),
        ),
      ),
      data: (document) {
        final activeIndex = document.activeIndexAt(position);
        _followActiveLine(activeIndex);
        if (document.lines.isEmpty) {
          return const Center(child: Text('这首歌暂时没有歌词'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.lyrics_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '同步歌词',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Text(
                    document.isSynced ? '逐句同步' : '普通文本',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 90,
                  horizontal: 18,
                ),
                itemExtent: 58,
                itemCount: document.lines.length,
                itemBuilder: (context, index) {
                  final line = document.lines[index];
                  final active = index == activeIndex;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: document.isSynced
                        ? () => ref.read(audioHandlerProvider).seek(line.time)
                        : null,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        color: active
                            ? const Color(0xFFE94354)
                            : Colors.black.withValues(alpha: 0.47),
                        fontSize: active ? 20 : 15,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                        height: 1.3,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          line.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
