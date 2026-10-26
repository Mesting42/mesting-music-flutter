import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_output_controller.dart';
import '../../../core/audio/media_volume_controller.dart';
import '../../../core/audio/playback_providers.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/beta_glass_popover.dart';
import '../../music_platform/presentation/platform_feedback.dart';

/// The app owns this presentation; Android owns the real device transfer.
/// Do not list paired devices as available routes or pretend a transfer worked.
Future<void> showPlayerOutputDialog(BuildContext context, WidgetRef ref) async {
  await ref.read(audioOutputProvider.notifier).refresh();
  if (!context.mounted) return;
  final switchDevice = await showBetaGlassDialog<bool>(
    context: context,
    builder: (_) => const PlayerOutputDialog(),
  );
  if (switchDevice != true || !context.mounted) return;
  try {
    await ref.read(audioOutputProvider.notifier).choose();
  } catch (error) {
    if (context.mounted) showPlatformFailure(context, error);
  }
}

class PlayerOutputDialog extends ConsumerStatefulWidget {
  const PlayerOutputDialog({super.key});
  @override
  ConsumerState<PlayerOutputDialog> createState() => _PlayerOutputDialogState();
}

class _PlayerOutputDialogState extends ConsumerState<PlayerOutputDialog> {
  double? _drag;
  @override
  Widget build(BuildContext context) {
    final output = ref.watch(audioOutputProvider);
    final volume = ref.watch(mediaVolumeProvider);
    final track = ref.watch(currentTrackProvider);
    final scheme = Theme.of(context).colorScheme;
    final ink = scheme.onSurface;
    final blue = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF78B4FF)
        : const Color(0xFF0069D5);
    return Dialog(
      key: const ValueKey('apple-output-picker'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: BetaGlassMenuSurface(
          radius: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '音频输出',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: '关闭',
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: ink.withValues(alpha: .6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ArtworkImage(
                              uri: track.coverAsset,
                              width: 58,
                              height: 58,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  track.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ink.withValues(alpha: .7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Icon(
                            output.headphones
                                ? Icons.earbuds_rounded
                                : CupertinoIcons.speaker_2,
                            size: 32,
                            color: blue,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  output.name,
                                  key: const ValueKey('output-current-device'),
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  output.available ? '当前播放设备' : '设备状态暂不可用',
                                  style: TextStyle(
                                    color: ink.withValues(alpha: .7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (output.available)
                            Icon(
                              CupertinoIcons.check_mark,
                              color: blue,
                              size: 21,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            '音量',
                            style: TextStyle(
                              color: ink.withValues(alpha: .7),
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            volume.available
                                ? '${((_drag ?? volume.value) * 100).round()}%'
                                : '暂不可调',
                            style: TextStyle(
                              color: ink.withValues(alpha: .7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.volume_down,
                            color: ink.withValues(alpha: .65),
                            size: 20,
                          ),
                          Expanded(
                            child: Semantics(
                              label: '系统媒体音量',
                              child: CupertinoSlider(
                                key: const ValueKey('output-volume-slider'),
                                value: _drag ?? volume.value,
                                activeColor: blue,
                                onChanged: !volume.available
                                    ? null
                                    : (value) {
                                        setState(() => _drag = value);
                                        ref
                                            .read(mediaVolumeProvider.notifier)
                                            .setVolume(value);
                                      },
                                onChangeEnd: !volume.available
                                    ? null
                                    : (value) async {
                                        await ref
                                            .read(mediaVolumeProvider.notifier)
                                            .setVolume(value);
                                        if (mounted) {
                                          setState(() => _drag = null);
                                        }
                                      },
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.volume_up,
                            color: ink.withValues(alpha: .65),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Keep the primary action visible even in a short landscape card.
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                child: CupertinoButton(
                  key: const ValueKey('output-open-system-picker'),
                  color: const Color(0xFF0069D5),
                  borderRadius: BorderRadius.circular(25),
                  onPressed: output.available
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  child: const Text(
                    '切换设备',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
