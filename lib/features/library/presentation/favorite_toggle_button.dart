import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/track.dart';
import '../../../shared/widgets/music_notice.dart';
import '../../../core/platform/distribution_channel.dart';
import '../../themes/beta_appearance.dart';
import 'library_access.dart';
import '../../themes/mesting_palette.dart';
import '../library_providers.dart';
import '../../music_platform/presentation/platform_feedback.dart';

const _favoriteAccent = MestingPalette.favorite;

class FavoriteToggleButton extends ConsumerWidget {
  const FavoriteToggleButton({
    required this.track,
    this.compact = false,
    super.key,
  });

  final Track track;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(
      favoriteTrackIdsProvider.select((ids) => ids.contains(track.id)),
    );
    const dimension = 48.0;

    return _FavoritePressFeedback(
      child: Semantics(
        button: true,
        selected: favorite,
        label: favorite ? '已收藏《${track.title}》' : '收藏《${track.title}》',
        child: SizedBox(
          key: ValueKey('favorite-button-${track.id}'),
          width: dimension,
          height: dimension,
          child: IconButton(
            tooltip: favorite ? '取消收藏' : '收藏歌曲',
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              // Keep a transparent 48dp target, including inside the player theme.
              backgroundColor: Colors.transparent,
              minimumSize: Size.square(dimension),
              maximumSize: Size.square(dimension),
              foregroundColor: favorite
                  ? (DistributionChannel.isBeta
                        ? BetaAppearance.accent(Theme.of(context).brightness)
                        : _favoriteAccent)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              overlayColor: Colors.transparent,
            ),
            onPressed: () async {
              final allowed = await ensureLibraryAccess(
                context,
                ref,
                reason: '登录后才能收藏歌曲，喜欢的音乐会跟随账号在不同设备间同步。',
                redirect: '/music',
              );
              if (!allowed || !context.mounted) return;
              try {
                await ref.read(libraryRepositoryProvider).toggleFavorite(track);
                if (context.mounted) {
                  showMusicNotice(
                    context,
                    icon: favorite
                        ? Icons.heart_broken_outlined
                        : Icons.favorite_rounded,
                    title: favorite ? '已取消喜欢' : '已添加到喜欢',
                    message: '',
                  );
                }
              } catch (error) {
                if (context.mounted) showPlatformFailure(context, error);
              }
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(favorite),
                size: compact ? 21 : 23,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bare glyphs still acknowledge the pointer immediately, while the existing
/// IconButton owns activation, keyboard access and the eventual cloud result.
class _FavoritePressFeedback extends StatefulWidget {
  const _FavoritePressFeedback({required this.child});
  final Widget child;
  @override
  State<_FavoritePressFeedback> createState() => _FavoritePressFeedbackState();
}

class _FavoritePressFeedbackState extends State<_FavoritePressFeedback> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => _pressed = true),
    onPointerUp: (_) => setState(() => _pressed = false),
    onPointerCancel: (_) => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? .88 : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}
