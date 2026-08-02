import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/track.dart';
import '../../auth/presentation/auth_gate.dart';
import '../../themes/mesting_palette.dart';
import '../../themes/music_theme_tokens.dart';
import '../library_providers.dart';

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
    final favorite = ref.watch(favoriteTrackIdsProvider).contains(track.id);
    final tokens = context.musicThemeTokens;
    final dimension = compact ? 38.0 : 44.0;

    return Semantics(
      button: true,
      selected: favorite,
      label: favorite ? '已收藏《${track.title}》' : '收藏《${track.title}》',
      child: AnimatedContainer(
        key: ValueKey('favorite-button-${track.id}'),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: dimension,
        height: dimension,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: favorite
                ? [
                    _favoriteAccent.withValues(alpha: .22),
                    _favoriteAccent.withValues(alpha: .10),
                  ]
                : [tokens.glassStrong, tokens.glassSubtle],
          ),
          border: Border.all(
            color: favorite
                ? _favoriteAccent.withValues(alpha: .46)
                : tokens.border,
          ),
          boxShadow: favorite
              ? [
                  BoxShadow(
                    color: _favoriteAccent.withValues(alpha: .18),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: IconButton(
          tooltip: favorite ? '取消收藏' : '收藏歌曲',
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            minimumSize: Size.square(dimension),
            maximumSize: Size.square(dimension),
            foregroundColor: favorite ? _favoriteAccent : tokens.textSecondary,
            overlayColor: _favoriteAccent.withValues(alpha: .10),
          ),
          onPressed: () async {
            final allowed = await ensureAuthenticated(
              context,
              ref,
              reason: '登录后才能收藏歌曲，喜欢的音乐会跟随账号在不同设备间同步。',
              redirect: '/music',
            );
            if (!allowed || !context.mounted) return;
            await ref.read(libraryRepositoryProvider).toggleFavorite(track);
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
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(favorite),
              size: compact ? 21 : 23,
            ),
          ),
        ),
      ),
    );
  }
}
