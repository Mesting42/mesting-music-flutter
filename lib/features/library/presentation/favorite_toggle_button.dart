import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/track.dart';
import '../library_providers.dart';

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
    return IconButton(
      tooltip: favorite ? '取消收藏' : '收藏歌曲',
      visualDensity: compact ? VisualDensity.compact : null,
      onPressed: () async {
        await ref
            .read(libraryRepositoryProvider)
            .setFavorite(track, favorite: !favorite);
      },
      icon: Icon(
        favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: favorite ? const Color(0xFFE94354) : null,
      ),
    );
  }
}
