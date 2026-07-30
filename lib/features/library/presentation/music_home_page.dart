import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../themes/theme_controller.dart';
import '../data/demo_library.dart';
import '../library_providers.dart';
import 'favorite_toggle_button.dart';

class MusicHomePage extends ConsumerWidget {
  const MusicHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final handler = ref.watch(audioHandlerProvider);
    final track = ref.watch(currentTrackProvider);
    final currentItem = ref.watch(currentMediaItemProvider).value;
    final playing = ref.watch(playbackStateProvider).value?.playing ?? false;
    final selectedTheme = ref.watch(musicThemeProvider);
    final favorites = ref.watch(favoriteTracksProvider).value ?? const [];
    final playlists = ref.watch(playlistsProvider).value ?? const [];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MESTING MUSIC',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 2.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('今天想听什么？', style: theme.textTheme.headlineMedium),
                  ],
                ),
              ),
              IconButton(
                tooltip: '我的歌单',
                onPressed: () => context.go('/music/playlists'),
                icon: const Icon(Icons.library_music_rounded),
              ),
              IconButton(
                tooltip: '播放队列',
                onPressed: () => context.go('/music/queue'),
                icon: const Icon(Icons.queue_music_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GlassCard(
            padding: EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 560;
                final copy = Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFF5B67,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          child: Text(
                            'DAILY RECORD · 今日唱片',
                            style: TextStyle(
                              color: Color(0xFFE94354),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(track.title, style: theme.textTheme.displaySmall),
                      const SizedBox(height: 8),
                      Text(
                        '${track.artist} · ${track.album}',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: () => handler.playTrack(track.id),
                        icon: Icon(
                          playing
                              ? Icons.graphic_eq_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(playing ? '正在播放' : '立即播放'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(138, 48),
                          backgroundColor: const Color(0xFFFF5B67),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                final art = Padding(
                  padding: const EdgeInsets.all(18),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFF4B405F), Color(0xFF15121E)],
                            ),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.62,
                          heightFactor: 0.62,
                          child: ClipOval(
                            child: Image.asset(
                              track.coverAsset,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const FractionallySizedBox(
                          widthFactor: 0.08,
                          heightFactor: 0.08,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFFBF3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                if (compact) {
                  return Column(
                    children: [
                      SizedBox(height: 230, child: art),
                      copy,
                    ],
                  );
                }
                return SizedBox(
                  height: 330,
                  child: Row(
                    children: [
                      Expanded(child: copy),
                      Expanded(child: art),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          Text('音乐空间', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '主题背景',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '第一阶段先确定经典与春日部晴空两套视觉基线',
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.52)),
                ),
                const SizedBox(height: 14),
                SegmentedButton<MusicThemeStyle>(
                  segments: const [
                    ButtonSegment(
                      value: MusicThemeStyle.classic,
                      icon: Icon(Icons.album_rounded),
                      label: Text('经典'),
                    ),
                    ButtonSegment(
                      value: MusicThemeStyle.shinchan,
                      icon: Icon(Icons.sunny),
                      label: Text('春日部'),
                    ),
                  ],
                  selected: {selectedTheme},
                  onSelectionChanged: (selection) {
                    ref
                        .read(musicThemeProvider.notifier)
                        .select(selection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              onTap: () => context.go('/music/playlists'),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFE5E7),
                child: Icon(Icons.library_music_rounded),
              ),
              title: const Text(
                '我的歌单',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                playlists.isEmpty
                    ? '创建歌单，整理你的音乐收藏'
                    : '已有 ${playlists.length} 个歌单',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Text('我的收藏', style: theme.textTheme.titleLarge)),
              Text(
                '${favorites.length} 首',
                style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: favorites.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.black.withValues(alpha: 0.3),
                            size: 34,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '还没有收藏，点歌曲旁的爱心即可保存',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favorites.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final favoriteTrack = favorites[index];
                      return ListTile(
                        onTap: () => handler.replaceQueue(
                          favorites,
                          initialIndex: index,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            favoriteTrack.coverAsset,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          favoriteTrack.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(favoriteTrack.artist),
                        trailing: FavoriteToggleButton(
                          track: favoriteTrack,
                          compact: true,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Text('本地音乐', style: theme.textTheme.titleLarge)),
              Text(
                '${demoTracks.length} 首',
                style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: demoTracks.length,
              separatorBuilder: (context, index) => Divider(
                height: 8,
                indent: 72,
                color: Colors.black.withValues(alpha: 0.06),
              ),
              itemBuilder: (context, index) {
                final localTrack = demoTracks[index];
                final active = currentItem?.id == localTrack.id;
                return ListTile(
                  onTap: () =>
                      handler.replaceQueue(demoTracks, initialIndex: index),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: active
                      ? const Color(0xFFFF5B67).withValues(alpha: 0.08)
                      : Colors.transparent,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      localTrack.coverAsset,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    localTrack.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: active ? const Color(0xFFE94354) : null,
                    ),
                  ),
                  subtitle: Text('${localTrack.artist} · 本地高音质'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FavoriteToggleButton(track: localTrack, compact: true),
                      IconButton(
                        tooltip: active && playing ? '暂停' : '播放',
                        onPressed: active
                            ? handler.togglePlayPause
                            : () => handler.replaceQueue(
                                demoTracks,
                                initialIndex: index,
                              ),
                        icon: Icon(
                          active && playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ],
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
