import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/models/track.dart';
import '../../../shared/widgets/music_notice.dart';
import '../../themes/beta_appearance.dart';
import '../domain/platform_audio_quality.dart';
import '../platform_quality_providers.dart';
import 'platform_feedback.dart';

/// All player styles share this picker and the same quality controller. The
/// preferred tier is independent of the actual tier returned by the platform.
Future<void> showPlatformQualityPicker(
  BuildContext context,
  WidgetRef ref,
) async {
  final track = ref.read(currentTrackProvider);
  final state = ref.read(platformQualityProvider);
  final supported = track.source == TrackSource.kugou;
  final actual = PlatformAudioQuality.fromCode(track.playbackQuality);
  final dark = Theme.of(context).brightness == Brightness.dark;
  final ink = dark ? Colors.white : const Color(0xFF202024);
  final accent = BetaAppearance.accent(Theme.of(context).brightness);
  final selected = await showDialog<PlatformAudioQuality>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => Dialog(
      key: const ValueKey('apple-quality-picker'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: dark ? const Color(0xE52A2A2D) : const Color(0xEBF7F7FA),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: dark ? Colors.white12 : Colors.white70),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '音质选择',
                    style: TextStyle(
                      color: ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final quality in PlatformAudioQuality.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Material(
                        color: state.preferred == quality
                            ? accent.withValues(alpha: .18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                        child: ListTile(
                          key: ValueKey('quality-option-${quality.code}'),
                          minVerticalPadding: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          title: Text(
                            quality.label,
                            style: TextStyle(
                              color: state.preferred == quality ? accent : ink,
                              fontSize: 17,
                              fontWeight: state.preferred == quality
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: state.preferred == quality
                              ? Icon(
                                  CupertinoIcons.check_mark,
                                  color: accent,
                                  size: 20,
                                )
                              : null,
                          onTap: supported && !state.switching
                              ? () => Navigator.pop(dialogContext, quality)
                              : null,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    !supported
                        ? '当前音源不支持在线音质切换'
                        : '当前：${track.isPreview ? "试听" : actual?.label ?? "待平台确认"}\n音质取决于歌曲资源与账号权限。',
                    style: TextStyle(
                      color: ink.withValues(alpha: .65),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  if (selected == null || !context.mounted) return;
  try {
    final applied = await ref
        .read(platformQualityProvider.notifier)
        .select(selected);
    if (!context.mounted) return;
    final updated = ref.read(currentTrackProvider);
    final delivered = PlatformAudioQuality.fromCode(updated.playbackQuality);
    final message = !applied
        ? '已保存音质偏好'
        : updated.isPreview
        ? '平台当前提供试听片段'
        : delivered == null
        ? '已切换音源，音质待平台确认'
        : delivered != selected
        ? '已切换为${delivered.label}，所选档位暂不可用'
        : '已切换为${delivered.label}';
    showMusicNotice(
      context,
      icon: CupertinoIcons.waveform,
      title: message,
      message: '',
    );
  } catch (error) {
    if (context.mounted) showPlatformFailure(context, error);
  }
}

class PlatformQualityButton extends ConsumerWidget {
  const PlatformQualityButton({this.inline = false, super.key});
  final bool inline;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);
    final state = ref.watch(platformQualityProvider);
    final actual = PlatformAudioQuality.fromCode(track.playbackQuality);
    final label = state.switching
        ? '切换中'
        : track.isPreview
        ? '试听'
        : actual?.label ?? '音质';
    return CupertinoButton(
      key: const ValueKey('player-quality-button'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: const Size(64, 48),
      onPressed: state.switching
          ? null
          : () => showPlatformQualityPicker(context, ref),
      child: inline
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.waveform,
                  size: 25,
                  color: Colors.white70,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.music_note,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
    );
  }
}
