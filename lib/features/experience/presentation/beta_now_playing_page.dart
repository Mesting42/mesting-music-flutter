import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/audio/playback_mode.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/music_notice.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../../library/presentation/favorite_toggle_button.dart';
import '../../player/player_visual_style.dart';
import '../../player/presentation/player_visual_stages.dart';
import '../../playlists/presentation/add_to_playlist_sheet.dart';
import '../../themes/beta_appearance.dart';
import '../../music_platform/platform_recommendation_providers.dart';
import 'apple_player_controls.dart';
import 'immersive_lyrics.dart';
import 'player_pull_to_dismiss.dart';
import 'player_more_menu.dart';

/// THESIS: Artwork and lyrics lead; shared Apple transport recedes below them.
/// PALETTE: Cover-derived blur, a dark readability veil, white transport, red
/// selection. CLASSIC retains its grey turntable; other stages retain motion.
/// GEOMETRY: One bounded column, generous artwork, compact song identity.
/// BEHAVIOR: One audio handler; short windows scroll without squeezing controls.
/// ACCESS: TextScaler, native button targets, reduced motion, semantic actions.
class BetaNowPlayingPage extends ConsumerStatefulWidget {
  const BetaNowPlayingPage({this.lyricsInitially = false, super.key});
  final bool lyricsInitially;
  @override
  ConsumerState<BetaNowPlayingPage> createState() => _BetaNowPlayingPageState();
}

class _BetaNowPlayingPageState extends ConsumerState<BetaNowPlayingPage> {
  late bool _lyrics = widget.lyricsInitially;
  void _dismissPlayer() =>
      context.canPop() ? context.pop() : context.go('/music/recommend');
  void _close() {
    if (_lyrics) {
      setState(() => _lyrics = false);
      return;
    }
    context.canPop() ? context.pop() : context.go('/music/recommend');
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    final style = ref.watch(playerVisualStyleProvider);
    final playing = ref.watch(playbackStateProvider).value?.playing ?? false;
    final classic = style == PlayerVisualStyle.classic && !_lyrics;
    final theme = Theme.of(context);
    final darkTheme = theme.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BetaAppearance.red,
        brightness: Brightness.dark,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: classic
              ? const Color(0x66000000)
              : Colors.transparent,
          minimumSize: const Size(48, 48),
        ),
      ),
    );
    return Theme(
      data: darkTheme,
      child: Builder(
        builder: (context) => PlayerPullToDismiss(
          onDismiss: _dismissPlayer,
          child: PopScope(
            canPop: !_lyrics,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && _lyrics) setState(() => _lyrics = false);
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF17191F),
              body: Stack(
                children: [
                  Positioned.fill(
                    child: classic
                        ? const ColoredBox(color: Color(0xFFAAA9AA))
                        : RepaintBoundary(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 65,
                                sigmaY: 65,
                              ),
                              child: Transform.scale(
                                scale: 1.4,
                                child: TrackArtwork(
                                  track: track,
                                  width: 1000,
                                  height: 1400,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (style != PlayerVisualStyle.cover && !classic && !_lyrics)
                    Positioned.fill(child: PlayerStyleAtmosphere(style: style)),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: classic
                              ? const [
                                  Color(0x08000000),
                                  Color(0x66000000),
                                  Color(0xE817191D),
                                ]
                              : const [
                                  Color(0x6616191B),
                                  Color(0x8816191B),
                                  Color(0xF216191D),
                                ],
                          stops: const [0, .58, 1],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, bounds) {
                        final scaled =
                            (MediaQuery.textScalerOf(context).scale(24) - 24)
                                .clamp(0.0, 96.0);
                        final minimum = 700.0 + scaled * 2;
                        final content = Center(
                          child: SizedBox(
                            width: 560,
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                PlayerDismissHandle(onTap: _dismissPlayer),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        tooltip: _lyrics ? '返回封面' : '收起播放器',
                                        onPressed: _close,
                                        icon: const Icon(
                                          CupertinoIcons.chevron_down,
                                          size: 23,
                                        ),
                                      ),
                                      const Spacer(),
                                      _more(context),
                                    ],
                                  ),
                                ),
                                if (_lyrics)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      26,
                                      7,
                                      26,
                                      4,
                                    ),
                                    child: Row(
                                      children: [
                                        Semantics(
                                          button: true,
                                          label: '返回封面',
                                          child: GestureDetector(
                                            onTap: () =>
                                                setState(() => _lyrics = false),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: TrackArtwork(
                                                track: track,
                                                width: 58,
                                                height: 58,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _Identity(
                                            title: track.title,
                                            artist: track.artist,
                                            small: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 300),
                                    child: _lyrics
                                        ? const ImmersiveLyrics(
                                            key: ValueKey('immersive-lyrics'),
                                          )
                                        : Padding(
                                            key: const ValueKey(
                                              'immersive-cover',
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                              26,
                                              12,
                                              26,
                                              20,
                                            ),
                                            child: Semantics(
                                              button: true,
                                              label: '查看歌词',
                                              child: GestureDetector(
                                                onTap: () => setState(
                                                  () => _lyrics = true,
                                                ),
                                                child: PlayerArtworkStage(
                                                  style: style,
                                                  track: track,
                                                  playing: playing,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                if (!_lyrics)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      26,
                                      0,
                                      26,
                                      5,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _Identity(
                                            title: track.title,
                                            artist: track.artist,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        FavoriteToggleButton(track: track),
                                      ],
                                    ),
                                  ),
                                const ApplePlayerControls(),
                              ],
                            ),
                          ),
                        );
                        return bounds.maxHeight < minimum
                            ? SingleChildScrollView(
                                child: SizedBox(
                                  height: minimum,
                                  child: content,
                                ),
                              )
                            : content;
                      },
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

  Widget _more(BuildContext context) {
    final handler = ref.read(audioHandlerProvider);
    final mode = ref.watch(playbackModeProvider).value ?? PlaybackMode.list;
    final current = ref.watch(playerVisualStyleProvider);
    final recommendation = ref.read(platformRecommendationSessionProvider);
    final track = ref.read(currentTrackProvider);
    return PlayerMoreMenu(
      onSelected: (value) async {
        if (value == 'fm-dislike') {
          await recommendation.dislike(track);
          return;
        }
        if (value == 'lyrics') {
          setState(() => _lyrics = !_lyrics);
          return;
        }
        if (value == 'playlist') {
          await showAddToPlaylistSheet(
            context,
            ref,
            ref.read(currentTrackProvider),
          );
          return;
        }
        if (value == 'mode') {
          await handler.setPlaybackMode(mode.next);
          if (context.mounted) {
            showMusicNotice(
              context,
              icon: CupertinoIcons.repeat,
              title: mode.next.label,
              message: '',
            );
          }
          return;
        }
        final style = PlayerVisualStyle.values.firstWhere(
          (style) => style.name == value,
        );
        await ref.read(playerVisualStyleProvider.notifier).select(style);
        if (context.mounted) {
          showMusicNotice(
            context,
            icon: CupertinoIcons.music_note,
            title: '已切换为${style.displayName}',
            message: '',
          );
        }
      },
      groups: [
        [
          PlayerMenuAction(
            'lyrics',
            _lyrics ? '查看封面' : '查看歌词',
            CupertinoIcons.text_alignleft,
          ),
          PlayerMenuAction(
            'mode',
            '播放模式 · ${mode.label}',
            mode == PlaybackMode.random
                ? CupertinoIcons.shuffle
                : mode == PlaybackMode.single
                ? CupertinoIcons.repeat_1
                : CupertinoIcons.repeat,
          ),
          const PlayerMenuAction(
            'playlist',
            '添加到歌单',
            CupertinoIcons.music_note_list,
          ),
          if (recommendation.ownsFmTrack(track.id))
            const PlayerMenuAction(
              'fm-dislike',
              '不喜欢这首',
              CupertinoIcons.hand_thumbsdown,
            ),
        ],
        [
          for (final style in PlayerVisualStyle.values)
            PlayerMenuAction(style.name, style.displayName, switch (style) {
              PlayerVisualStyle.cover => CupertinoIcons.photo,
              PlayerVisualStyle.classic => CupertinoIcons.circle,
              PlayerVisualStyle.aurora => CupertinoIcons.sparkles,
              PlayerVisualStyle.cassette => CupertinoIcons.circle_grid_hex,
              PlayerVisualStyle.lyricStage => CupertinoIcons.waveform,
            }, selected: current == style),
        ],
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.title,
    required this.artist,
    this.small = false,
  });
  final String title, artist;
  final bool small;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        maxLines: small ? 1 : 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 18 : 26,
          height: 1.16,
          fontWeight: FontWeight.w700,
          letterSpacing: -.4,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontSize: small ? 14 : 17),
      ),
    ],
  );
}
