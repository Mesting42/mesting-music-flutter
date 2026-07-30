import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/models/track.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../library/data/demo_library.dart';
import '../../library/library_providers.dart';
import '../../library/presentation/favorite_toggle_button.dart';
import 'playlist_editor_dialog.dart';

class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({required this.playlistId, super.key});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider(playlistId));
    final tracks = ref.watch(playlistTracksProvider(playlistId));

    return playlist.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('歌单读取失败')),
      data: (item) {
        if (item == null) {
          return Center(
            child: FilledButton(
              onPressed: () => context.go('/music/playlists'),
              child: const Text('歌单不存在，返回列表'),
            ),
          );
        }
        final trackList = tracks.value ?? const <Track>[];
        final cover =
            item.coverAsset ??
            (trackList.isEmpty ? null : trackList.first.coverAsset);
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: '返回歌单列表',
                      onPressed: () => context.go('/music/playlists'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _editPlaylist(context, ref, item);
                        } else if (action == 'delete') {
                          _deletePlaylist(context, ref, item.name);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('编辑歌单')),
                        PopupMenuItem(value: 'delete', child: Text('删除歌单')),
                      ],
                    ),
                  ],
                ),
                GlassCard(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: cover == null
                            ? Container(
                                width: 104,
                                height: 104,
                                color: const Color(0xFFFFE5E7),
                                child: const Icon(
                                  Icons.album_rounded,
                                  size: 44,
                                ),
                              )
                            : Image.asset(
                                cover,
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.description.isEmpty
                                  ? '${trackList.length} 首歌曲'
                                  : item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              children: [
                                FilledButton.icon(
                                  onPressed: trackList.isEmpty
                                      ? null
                                      : () => ref
                                            .read(audioHandlerProvider)
                                            .replaceQueue(trackList),
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('播放全部'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _showTrackPicker(context, ref, trackList),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('添加歌曲'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(8),
                    child: tracks.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          const Center(child: Text('歌曲读取失败')),
                      data: (items) => items.isEmpty
                          ? const Center(child: Text('点击“添加歌曲”开始整理歌单'))
                          : ReorderableListView.builder(
                              buildDefaultDragHandles: false,
                              itemCount: items.length,
                              onReorder: (oldIndex, newIndex) {
                                final reordered = List<Track>.of(items);
                                if (newIndex > oldIndex) newIndex -= 1;
                                final moved = reordered.removeAt(oldIndex);
                                reordered.insert(newIndex, moved);
                                ref
                                    .read(libraryRepositoryProvider)
                                    .reorderPlaylistTracks(
                                      playlistId,
                                      reordered
                                          .map((track) => track.id)
                                          .toList(),
                                    );
                              },
                              itemBuilder: (context, index) {
                                final track = items[index];
                                return ListTile(
                                  key: ValueKey(track.id),
                                  onTap: () => ref
                                      .read(audioHandlerProvider)
                                      .replaceQueue(items, initialIndex: index),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      track.coverAsset,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    track.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Text(track.artist),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FavoriteToggleButton(
                                        track: track,
                                        compact: true,
                                      ),
                                      IconButton(
                                        tooltip: '从歌单移除',
                                        onPressed: () => ref
                                            .read(libraryRepositoryProvider)
                                            .removeTrackFromPlaylist(
                                              playlistId,
                                              track.id,
                                            ),
                                        icon: const Icon(
                                          Icons.remove_circle_outline_rounded,
                                        ),
                                      ),
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Icon(
                                            Icons.drag_handle_rounded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editPlaylist(
    BuildContext context,
    WidgetRef ref,
    UserPlaylist playlist,
  ) async {
    final draft = await showPlaylistEditorDialog(
      context,
      initialName: playlist.name,
      initialDescription: playlist.description,
      initialCoverAsset: playlist.coverAsset,
    );
    if (draft == null) return;
    await ref
        .read(libraryRepositoryProvider)
        .updatePlaylist(
          id: playlistId,
          name: draft.name,
          description: draft.description,
          coverAsset: draft.coverAsset,
        );
    ref.invalidate(playlistProvider(playlistId));
  }

  Future<void> _deletePlaylist(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除歌单？'),
        content: Text('“$name”会被删除，歌曲文件和收藏不会受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(libraryRepositoryProvider).deletePlaylist(playlistId);
    if (context.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (context.mounted) context.go('/music/playlists');
    }
  }

  Future<void> _showTrackPicker(
    BuildContext context,
    WidgetRef ref,
    List<Track> currentTracks,
  ) async {
    final selected = currentTracks.map((track) => track.id).toSet();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.72,
            child: Column(
              children: [
                Text('添加歌曲', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: demoTracks.length,
                    itemBuilder: (context, index) {
                      final track = demoTracks[index];
                      final included = selected.contains(track.id);
                      return CheckboxListTile(
                        value: included,
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            track.coverAsset,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(track.title),
                        subtitle: Text(track.artist),
                        onChanged: (checked) async {
                          if (checked == true) {
                            await ref
                                .read(libraryRepositoryProvider)
                                .addTrackToPlaylist(playlistId, track);
                            selected.add(track.id);
                          } else {
                            await ref
                                .read(libraryRepositoryProvider)
                                .removeTrackFromPlaylist(playlistId, track.id);
                            selected.remove(track.id);
                          }
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 118),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('完成'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
