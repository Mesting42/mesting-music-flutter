import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/adaptive_layout.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../data/curated_playlists.dart';
import '../domain/curated_playlist.dart';
import '../../themes/music_theme_preset.dart';
import '../../themes/theme_controller.dart';
import '../../themes/music_theme_tokens.dart';
import '../../themes/mesting_backstage_theme.dart';
import '../../player/presentation/music_hub_top_bar.dart';

const double discoverPageBottomClearance = 168;

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final backstage = MestingBackstage.forBrightness(
      Theme.of(context).brightness,
    );
    final pageWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = pageWidth - 36;
    final columns = availableWidth >= 760 ? 3 : 2;
    final bottomClearance = mestingUsesNavigationRailForWidth(pageWidth)
        ? 112.0
        : discoverPageBottomClearance;
    return Theme(
      data: MestingBackstage.themeOf(context),
      child: ColoredBox(
        color: backstage.ink,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                sliver: SliverToBoxAdapter(
                  child: MusicHubTopBar(
                    title: '发现歌单',
                    subtitle: '城市频段 · ON AIR 07',
                    brandOnly: true,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverToBoxAdapter(
                  child: _DiscoverFrequencyHero(
                    playlist: curatedPlaylists.first,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: const SliverToBoxAdapter(child: _DiscoverSignalRail()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              ..._playlistSectionSlivers(
                title: '精选歌单',
                subtitle: '编辑把一段现场剪成可以随身带走的频率',
                playlists: curatedPlaylistsFor(
                  CuratedPlaylistCategory.featured,
                ),
                columns: columns,
              ),
              ..._playlistSectionSlivers(
                title: '宝藏歌单',
                subtitle: '藏在城市缝隙里的独立声场',
                playlists: curatedPlaylistsFor(
                  CuratedPlaylistCategory.treasure,
                ),
                columns: columns,
              ),
              ..._playlistSectionSlivers(
                title: '编辑推荐',
                subtitle: '适合不同场景的音乐电台',
                playlists: curatedPlaylistsFor(CuratedPlaylistCategory.editor),
                columns: columns,
              ),
              ..._playlistSectionSlivers(
                title: '全部发现',
                subtitle: '更多在线音乐主题',
                playlists: curatedPlaylistsFor(CuratedPlaylistCategory.explore),
                columns: columns,
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: ValueKey('discover-bottom-clearance'),
                  height: bottomClearance,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverFrequencyHero extends StatelessWidget {
  const _DiscoverFrequencyHero({required this.playlist});

  final CuratedPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final backstage = MestingBackstage.colorsOf(context);
    return Semantics(
      button: true,
      label: '打开${playlist.name}',
      child: Material(
        color: backstage.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: backstage.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/music/discover/${playlist.id}'),
          child: SizedBox(
            height: 238,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: -78,
                  top: -62,
                  child: Container(
                    width: 294,
                    height: 294,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: backstage.cobalt.withValues(alpha: .78),
                        width: 25,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _FrequencyTicksPainter(
                        color: backstage.bone.withValues(alpha: .78),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 22,
                  top: 67,
                  width: 112,
                  height: 112,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: ArtworkImage(
                      uri: playlist.coverAsset,
                      width: 112,
                      height: 112,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '发现歌单',
                        style: TextStyle(
                          color: backstage.cobalt,
                          fontSize: 42,
                          height: .85,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '城市频段',
                        style: TextStyle(
                          color: backstage.bone,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 23,
                  right: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今晚，听点不一样',
                        style: TextStyle(
                          color: backstage.bone,
                          fontSize: 15,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${playlist.name} · Mesting精选',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 18,
                  child: Text(
                    'CITY RADIO / LIVE 101.3',
                    style: TextStyle(
                      color: backstage.signal,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: backstage.signal,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: backstage.onAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrequencyTicksPainter extends CustomPainter {
  const _FrequencyTicksPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    for (var index = 0; index < 18; index++) {
      final angle = -2.45 + index * .16;
      final start = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final endRadius = index.isEven ? radius - 12 : radius - 7;
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FrequencyTicksPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DiscoverSignalRail extends StatelessWidget {
  const _DiscoverSignalRail();

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final backstage = MestingBackstage.colorsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '正在播放的城市',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final city in const ['上海', '成都', '深圳'])
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: city == '成都'
                            ? backstage.signal
                            : tokens.textMuted,
                        border: Border.all(
                          color: tokens.textPrimary.withValues(alpha: .72),
                          width: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      city,
                      style: TextStyle(
                        color: city == '成都'
                            ? backstage.signal
                            : tokens.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (city != '深圳')
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 1,
                          color: tokens.border,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

List<Widget> _playlistSectionSlivers({
  required String title,
  required String subtitle,
  required List<CuratedPlaylist> playlists,
  required int columns,
}) {
  return [
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final backstage = MestingBackstage.colorsOf(context);
                return Text(
                  title,
                  style: TextStyle(
                    color: backstage.bone,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.45,
                  ),
                );
              },
            ),
            const SizedBox(height: 3),
            Builder(
              builder: (context) => Text(
                subtitle,
                style: TextStyle(color: context.musicThemeTokens.textSecondary),
              ),
            ),
            const SizedBox(height: 11),
          ],
        ),
      ),
    ),
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 11,
          crossAxisSpacing: 11,
          childAspectRatio: 0.86,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _PlaylistCard(playlist: playlists[index]),
          childCount: playlists.length,
          addRepaintBoundaries: true,
        ),
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 26)),
  ];
}

class _PlaylistCard extends ConsumerWidget {
  const _PlaylistCard({required this.playlist});

  final CuratedPlaylist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.musicThemeTokens;
    final backstage = MestingBackstage.colorsOf(context);
    final themePreset = ref.watch(effectiveMusicThemeProvider);
    final cover = themedPlaylistCover(
      preset: themePreset,
      index: curatedPlaylists.indexOf(playlist),
      fallback: playlist.coverAsset,
    );
    return _BackstagePlaylistSurface(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/music/discover/${playlist.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: LayoutBuilder(
                  builder: (context, constraints) => ArtworkImage(
                    uri: cover,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 9, 6, 2),
              child: Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: backstage.bone,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'STATION · 在线电台',
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackstagePlaylistSurface extends StatelessWidget {
  const _BackstagePlaylistSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(11));
    final backstage = MestingBackstage.colorsOf(context);
    return Material(
      color: backstage.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: backstage.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(6), child: child),
    );
  }
}
