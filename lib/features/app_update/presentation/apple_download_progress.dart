import 'package:flutter/material.dart';
import '../../themes/beta_appearance.dart';

/// The first frame starts at persisted progress, so reopening a download never
/// animates from zero. Only the capsule fill interpolates; labels always report
/// actual received bytes, and 100% does not claim that verification has passed.
class AppleDownloadProgress extends StatelessWidget {
  const AppleDownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    super.key,
  });
  final int receivedBytes, totalBytes;
  @override
  Widget build(BuildContext context) {
    final fraction = totalBytes > 0
        ? (receivedBytes / totalBytes).clamp(0.0, 1.0)
        : 0.0;
    final percent = '${(fraction * 100).round()}%';
    final bytes =
        '${(receivedBytes / 1048576).toStringAsFixed(1)} / ${(totalBytes / 1048576).toStringAsFixed(1)} MB';
    final scheme = Theme.of(context).colorScheme;
    final blue = BetaAppearance.accent(Theme.of(context).brightness);
    return Semantics(
      label: '更新下载进度',
      value: '$percent，$bytes',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: fraction, end: fraction),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 4,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned.fill(
                      child: ColoredBox(
                        color: scheme.onSurface.withValues(alpha: .12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: ColoredBox(
                        color: blue,
                        child: const SizedBox(height: 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            child: Row(
              children: [
                Expanded(child: Text(bytes)),
                const SizedBox(width: 16),
                Text(
                  percent,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
