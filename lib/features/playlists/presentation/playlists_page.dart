import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../library/library_providers.dart';
import 'playlist_editor_dialog.dart';

class PlaylistsPage extends ConsumerWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: '返回音乐首页',
                  onPressed: () => context.go('/music'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MY COLLECTION',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.8,
                        ),
                      ),
                      Text(
                        '我的歌单',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _createPlaylist(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新建'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: playlists.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Center(child: Text('歌单读取失败')),
                data: (items) => items.isEmpty
                    ? _EmptyPlaylists(
                        onCreate: () => _createPlaylist(context, ref),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _PlaylistTile(playlist: items[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final draft = await showPlaylistEditorDialog(context);
    if (draft == null) return;
    final id = 'playlist_${DateTime.now().microsecondsSinceEpoch}';
    await ref
        .read(libraryRepositoryProvider)
        .createPlaylist(
          id: id,
          name: draft.name,
          description: draft.description,
          coverAsset: draft.coverAsset,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已创建歌单“${draft.name}”')));
    }
  }
}

class _EmptyPlaylists extends StatelessWidget {
  const _EmptyPlaylists({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_music_outlined, size: 54),
            const SizedBox(height: 14),
            Text('还没有个人歌单', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text('创建一个歌单，把喜欢的歌曲整理到一起'),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('创建第一个歌单'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  const _PlaylistTile({required this.playlist});

  final UserPlaylist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks =
        ref.watch(playlistTracksProvider(playlist.id)).value ?? const [];
    final cover =
        playlist.coverAsset ??
        (tracks.isEmpty ? null : tracks.first.coverAsset);
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        onTap: () => context.go('/music/playlists/${playlist.id}'),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: cover == null
              ? Container(
                  width: 58,
                  height: 58,
                  color: const Color(0xFFFFE5E7),
                  child: const Icon(Icons.album_rounded),
                )
              : Image.asset(cover, width: 58, height: 58, fit: BoxFit.cover),
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          playlist.description.isEmpty
              ? '${tracks.length} 首歌曲'
              : '${tracks.length} 首 · ${playlist.description}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
