import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/models/track.dart';
import '../domain/platform_audio_quality.dart';
import '../platform_quality_providers.dart';
import 'platform_feedback.dart';

/// One entry and dialog for cover, lyrics, vinyl and every alternate player.
/// Preferred and delivered tiers are distinct, including a server downgrade.
class PlatformQualityButton extends ConsumerWidget {
  const PlatformQualityButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);
    final state = ref.watch(platformQualityProvider);
    final supported = track.source == TrackSource.kugou;
    final actual = PlatformAudioQuality.fromCode(track.playbackQuality);
    final label = track.isPreview ? '试听' : actual?.label ?? '音质';
    return FilledButton.tonalIcon(
      key: const ValueKey('player-quality-button'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(88, 44),
        backgroundColor: const Color(0xCC34383F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: state.switching
          ? null
          : () async {
              final selected = await showDialog<PlatformAudioQuality>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('音质选择'),
                  children: [
                    if (!supported)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text('当前音源不支持在线音质切换。'),
                      ),
                    for (final quality in PlatformAudioQuality.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 3,
                        ),
                        child: ListTile(
                          selected: state.preferred == quality,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          shape: const StadiumBorder(),
                          title: Text(
                            quality.label,
                            textAlign: TextAlign.center,
                          ),
                          trailing: state.preferred == quality
                              ? const Icon(Icons.check_rounded)
                              : const SizedBox(width: 24),
                          onTap: supported
                              ? () => Navigator.pop(context, quality)
                              : null,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                      child: Text(
                        '当前：${track.isPreview ? "试听" : actual?.label ?? "待平台确认"}。音质以曲目和账号可用资源为准。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
              if (selected == null) return;
              try {
                final applied = await ref
                    .read(platformQualityProvider.notifier)
                    .select(selected);
                if (!context.mounted) return;
                final updated = ref.read(currentTrackProvider);
                final delivered = PlatformAudioQuality.fromCode(
                  updated.playbackQuality,
                );
                final message = !applied
                    ? '已保存偏好，当前播放操作已变化'
                    : updated.isPreview
                    ? '平台当前提供试听片段'
                    : delivered == null
                    ? '已切换音源，实际音质待平台确认'
                    : delivered != selected
                    ? '已切换为${delivered.label}，所选档位暂不可用'
                    : '已切换为${delivered.label}';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              } catch (error) {
                if (context.mounted) showPlatformFailure(context, error);
              }
            },
      icon: state.switching
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.music_note_rounded, size: 18),
      label: Text(state.switching ? '切换中' : label),
    );
  }
}
