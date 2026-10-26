import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/media_volume_controller.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/utils/duration_format.dart';
import '../../music_platform/music_platform_providers.dart';
import '../../music_platform/presentation/platform_account_page.dart';
import '../../music_platform/presentation/platform_comments_page.dart';
import '../../music_platform/presentation/platform_feedback.dart';
import '../../music_platform/presentation/platform_quality_button.dart';
import '../../player/presentation/ip_progress_decoration.dart';
import '../../player/presentation/shinchan_progress_walker.dart';
import '../../queue/presentation/queue_page.dart';
import '../../themes/theme_controller.dart';
import '../../themes/music_theme_preset.dart';

/// CONTRACT: Apple Music transport from the user's pinned reference. All five
/// Beta styles share this exact component: progress, naked white glyphs, system
/// media volume, then comments / quality / current queue. IP rail and character
/// preferences are independent decoration, never an alternate control layout.
class ApplePlayerControls extends ConsumerStatefulWidget {
  const ApplePlayerControls({super.key});
  @override
  ConsumerState<ApplePlayerControls> createState() =>
      _ApplePlayerControlsState();
}

class _ApplePlayerControlsState extends ConsumerState<ApplePlayerControls> {
  double? _scrub, _volumeDrag;
  String? _trackId;
  Future<void> _act(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      if (mounted) showPlatformFailure(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    if (_trackId != track.id) {
      _trackId = track.id;
      _scrub = null;
    }
    final handler = ref.watch(audioHandlerProvider);
    final playback = ref.watch(playbackStateProvider).value;
    final playing = playback?.playing ?? false;
    final busy = playback?.processingState == AudioProcessingState.loading;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? track.duration;
    final maximum = duration.inMilliseconds.toDouble().clamp(
      1.0,
      double.infinity,
    );
    final value = (_scrub ?? position.inMilliseconds.toDouble()).clamp(
      0.0,
      maximum,
    );
    final visual = ref.watch(themeVisualSettingsProvider);
    final preset = ref.watch(effectiveMusicThemeProvider);
    final railIp = decorationIp(visual.progressStyle, preset);
    final characterIp = decorationIp(visual.progressCharacter, preset);
    final classic = railIp == MusicThemeIp.classic;
    final volume = ref.watch(mediaVolumeProvider);
    return Padding(
      key: const ValueKey('apple-player-controls'),
      padding: const EdgeInsets.fromLTRB(26, 6, 26, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 42,
            child: LayoutBuilder(
              builder: (context, box) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: classic ? 5 : ipProgressTrackHeight,
                          trackShape: classic
                              ? const RoundedRectSliderTrackShape()
                              : IpProgressTrackShape(ip: railIp),
                          activeTrackColor: classic
                              ? const Color(0xD9FFFFFF)
                              : progressTrackColorForIp(railIp),
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          thumbShape: characterIp == MusicThemeIp.classic
                              ? RoundSliderThumbShape(
                                  enabledThumbRadius: _scrub == null ? 2.5 : 5,
                                )
                              : SliderComponentShape.noThumb,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: MergeSemantics(
                          key: const ValueKey('playback-seek-semantics'),
                          child: Semantics(
                            label: '播放进度',
                            child: Slider(
                              semanticFormatterCallback: (milliseconds) =>
                                  '${_spokenTime(Duration(milliseconds: milliseconds.round()))}，共${_spokenTime(duration)}',
                              key: const ValueKey('playback-seek-slider'),
                              padding: EdgeInsets.zero,
                              value: value,
                              max: maximum,
                              onChangeStart: duration > Duration.zero
                                  ? (v) => setState(() => _scrub = v)
                                  : null,
                              onChanged: duration > Duration.zero
                                  ? (v) => setState(() => _scrub = v)
                                  : null,
                              onChangeEnd: duration > Duration.zero
                                  ? (v) async {
                                      await _act(
                                        () => handler.seek(
                                          Duration(milliseconds: v.round()),
                                        ),
                                      );
                                      if (mounted && _trackId == track.id) {
                                        setState(() => _scrub = null);
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (characterIp == MusicThemeIp.shinchan)
                      Positioned(
                        left: progressCompanionLeft(
                          progress: value / maximum,
                          availableWidth: box.maxWidth,
                          companionWidth: 104,
                        ),
                        top: -61,
                        child: IgnorePointer(
                          child: ShinchanProgressWalker(
                            presetId: preset.id,
                            playing: playing,
                          ),
                        ),
                      ),
                    if (characterIp == MusicThemeIp.helloKitty ||
                        characterIp == MusicThemeIp.kuromi)
                      Positioned(
                        left: progressCompanionLeft(
                          progress: value / maximum,
                          availableWidth: box.maxWidth,
                          companionWidth: progressCompanionSize(
                            characterIp,
                          ).width,
                        ),
                        top: progressCompanionTop(characterIp) - 3,
                        child: IgnorePointer(
                          child: IpProgressCompanion(
                            ip: characterIp,
                            playing: playing,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(Duration(milliseconds: value.round())),
                key: const ValueKey('playback-elapsed-time'),
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                '-${formatDuration(Duration(milliseconds: (maximum - value).round()))}',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Transport(
                label: '上一首',
                icon: CupertinoIcons.backward_fill,
                size: 35,
                onPressed: () => _act(handler.skipToPrevious),
              ),
              SizedBox(
                width: 84,
                height: 74,
                child: busy
                    ? const Center(
                        child: CupertinoActivityIndicator(color: Colors.white),
                      )
                    : _Transport(
                        label: playing ? '暂停' : '播放',
                        icon: playing
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                        size: 49,
                        onPressed: () => _act(handler.togglePlayPause),
                      ),
              ),
              _Transport(
                label: '下一首',
                icon: CupertinoIcons.forward_fill,
                size: 35,
                onPressed: () => _act(handler.skipToNext),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                CupertinoIcons.volume_down,
                color: Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: Colors.white60,
                    inactiveTrackColor: Colors.white24,
                    disabledActiveTrackColor: Colors.white24,
                    disabledInactiveTrackColor: Colors.white12,
                    thumbShape: SliderComponentShape.noThumb,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: MergeSemantics(
                    key: const ValueKey('media-volume-semantics'),
                    child: Semantics(
                      label: '系统媒体音量',
                      child: Slider(
                        semanticFormatterCallback: (value) =>
                            '${(value * 100).round()}%',
                        key: const ValueKey('system-media-volume'),
                        padding: EdgeInsets.zero,
                        value: _volumeDrag ?? volume.value,
                        onChanged: volume.available
                            ? (v) {
                                setState(() => _volumeDrag = v);
                                ref
                                    .read(mediaVolumeProvider.notifier)
                                    .setVolume(v);
                              }
                            : null,
                        onChangeEnd: volume.available
                            ? (v) async {
                                await ref
                                    .read(mediaVolumeProvider.notifier)
                                    .setVolume(v);
                                if (mounted) setState(() => _volumeDrag = null);
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                CupertinoIcons.volume_up,
                color: Colors.white54,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Transport(
                label: '歌曲评论',
                icon: CupertinoIcons.text_bubble,
                size: 26,
                onPressed: () async {
                  if (ref.read(platformAccountProvider).value == null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PlatformAccountPage(),
                      ),
                    );
                    if (!context.mounted) return;
                  }
                  if (context.mounted) {
                    await openPlatformSongComments(context, ref, track);
                  }
                },
              ),
              const PlatformQualityButton(inline: true),
              _Transport(
                label: '播放队列',
                icon: CupertinoIcons.list_bullet,
                size: 27,
                onPressed: () => showPlaybackQueueSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Transport extends StatelessWidget {
  const _Transport({
    required this.label,
    required this.icon,
    required this.size,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final double size;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Tooltip(
      message: label,
      child: CupertinoButton(
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(48, 48),
        onPressed: onPressed,
        child: Icon(icon, size: size, color: Colors.white),
      ),
    ),
  );
}

String _spokenTime(Duration value) =>
    '${value.inMinutes}分${value.inSeconds.remainder(60)}秒';
