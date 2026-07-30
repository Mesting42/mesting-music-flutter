import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../library/presentation/favorite_toggle_button.dart';
import '../../lyrics/presentation/lyrics_panel.dart';
import '../../themes/music_theme_background.dart';
import 'playback_controls.dart';
import 'vinyl_disc.dart';

class NowPlayingPage extends ConsumerStatefulWidget {
  const NowPlayingPage({super.key});

  @override
  ConsumerState<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends ConsumerState<NowPlayingPage> {
  final PageController _pageController = PageController();
  int _mobilePage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    final playing = ref.watch(playbackStateProvider).value?.playing ?? false;

    final vinylPanel = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440, maxHeight: 440),
              child: VinylDisc(coverAsset: track.coverAsset, playing: playing),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            track.title,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '${track.artist} · ${track.album}',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.52),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return MusicThemeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            tooltip: '返回音乐首页',
            onPressed: () => context.go('/music'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Column(
            children: [
              const Text(
                '正在播放',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                track.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [FavoriteToggleButton(track: track)],
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final content = wide
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                      child: Row(
                        children: [
                          Expanded(child: vinylPanel),
                          Expanded(
                            child: GlassCard(
                              padding: EdgeInsets.zero,
                              child: const LyricsPanel(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 4,
                          ),
                          child: SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(
                                value: 0,
                                icon: Icon(Icons.album_rounded),
                                label: Text('唱片'),
                              ),
                              ButtonSegment(
                                value: 1,
                                icon: Icon(Icons.lyrics_outlined),
                                label: Text('歌词'),
                              ),
                            ],
                            selected: {_mobilePage},
                            onSelectionChanged: (selection) {
                              final page = selection.first;
                              _pageController.animateToPage(
                                page,
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (page) =>
                                setState(() => _mobilePage = page),
                            children: [
                              vinylPanel,
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: LyricsPanel(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

              return Column(
                children: [
                  Expanded(child: content),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: GlassCard(
                      padding: EdgeInsets.fromLTRB(8, 12, 8, 14),
                      borderRadius: 28,
                      child: PlaybackControls(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
