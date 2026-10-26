import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/audio/playback_providers.dart';
import '../../library/presentation/music_home_page.dart';
import '../../library/library_providers.dart';
import '../../player/presentation/music_hub_top_bar.dart';
import '../data/platform_library_repository.dart';
import 'platform_discovery_page.dart';
import 'platform_feedback.dart';
import 'platform_comments_page.dart';
import 'platform_design.dart';

Future<String?> _name(BuildContext context, {String initial = ''}) async {
  final controller = TextEditingController(text: initial);
  try {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(initial.isEmpty ? '新建酷狗云端歌单' : '修改歌单名称'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(labelText: '歌单名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(dialogContext, name);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  } finally {
    // The route's closing animation may still read the controller this frame.
    Future<void>.delayed(const Duration(seconds: 1), controller.dispose);
  }
}

Future<void> createPlatformPlaylist(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(libraryRepositoryProvider);
  if (repository is! PlatformLibraryRepository) return;
  final name = await _name(context);
  if (name == null) return;
  try {
    await repository.createPlaylist(id: '', name: name);
  } catch (error) {
    if (context.mounted) showPlatformFailure(context, error);
  }
}

class PlatformLibraryPage extends ConsumerWidget {
  const PlatformLibraryPage({required this.favorites, super.key});
  final bool favorites;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(libraryRepositoryProvider);
    return PlatformStyle(
      child: RefreshIndicator(
        onRefresh: () async {
          await repository.synchronize(forcePull: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + 12,
            16,
            140,
          ),
          children: [
            MusicHubTopBar(
              title: favorites ? '我的喜欢' : '我的歌单',
              subtitle: '酷狗云端曲库',
              showBack: true,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/profile'),
            ),
            const SizedBox(height: 20),
            if (favorites)
              ref
                  .watch(favoriteTracksProvider)
                  .when(
                    loading: () => const PlatformFeedbackState(loading: true),
                    error: (error, stack) => PlatformFeedbackState(
                      message: '云端收藏暂时无法加载',
                      retry: () => repository.synchronize(forcePull: true),
                    ),
                    data: (tracks) => FavoriteCollectionView(
                      tracks: tracks,
                      currentTrackId: ref
                          .watch(currentMediaItemProvider)
                          .value
                          ?.id,
                      playing:
                          ref.watch(playbackStateProvider).value?.playing ??
                          false,
                      onPlayAll: tracks.isEmpty
                          ? null
                          : () => ref
                                .read(audioHandlerProvider)
                                .replaceQueue(tracks),
                      onPlayTrack: (track) => ref
                          .read(audioHandlerProvider)
                          .playSingleTrack(track, playbackContext: tracks),
                      onAddTrack: (track) => ref
                          .read(audioHandlerProvider)
                          .appendToUpcomingQueue(track),
                      onExplore: () => context.push('/music/search'),
                    ),
                  )
            else ...[
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () => createPlatformPlaylist(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('新建歌单'),
                ),
              ),
              ref
                  .watch(playlistsProvider)
                  .when(
                    loading: () => const PlatformFeedbackState(loading: true),
                    error: (error, stack) => TextButton.icon(
                      onPressed: () => repository.synchronize(forcePull: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('云端歌单加载失败，点击重试'),
                    ),
                    data: (items) => items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('酷狗账号中还没有歌单'),
                          )
                        : MyPlaylistsCollectionView(playlists: items),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class PlatformCloudPlaylistPage extends ConsumerWidget {
  const PlatformCloudPlaylistPage({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(libraryRepositoryProvider);
    if (repository is! PlatformLibraryRepository) {
      return Center(
        child: TextButton(
          onPressed: () => context.go('/profile'),
          child: const Text('当前账号已退出，返回我的'),
        ),
      );
    }
    final playlist = ref.watch(playlistProvider(id));
    return PlatformPageFrame(
      title: playlist.value?.name ?? '酷狗云端歌单',
      subtitle: '酷狗云端歌单',
      actions: [
        IconButton(
          tooltip: '酷狗歌单评论',
          icon: const Icon(Icons.comment_outlined),
          onPressed: () async {
            try {
              final commentId = await repository.commentId(id);
              if (context.mounted) {
                openPlatformPlaylistComments(
                  context,
                  ref,
                  id: commentId,
                  name: playlist.value?.name ?? '歌单',
                );
              }
            } catch (error) {
              if (context.mounted) showPlatformFailure(context, error);
            }
          },
        ),
        if (playlist.value != null && repository.canManage(id))
          PopupMenuButton<String>(
            onSelected: (action) =>
                _manage(context, ref, repository, playlist.value!, action),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('修改名称')),
              PopupMenuItem(value: 'delete', child: Text('删除歌单')),
            ],
          ),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          await repository.synchronize(forcePull: true);
          ref.invalidate(playlistProvider(id));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
          children: [
            PlatformSongs(
              value: ref.watch(playlistTracksProvider(id)),
              retry: () => repository.synchronize(forcePull: true),
              playlistId: repository.canManage(id) ? id : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manage(
    BuildContext context,
    WidgetRef ref,
    PlatformLibraryRepository repository,
    UserPlaylist playlist,
    String action,
  ) async {
    try {
      if (action == 'rename') {
        final name = await _name(context, initial: playlist.name);
        if (name == null) return;
        await repository.updatePlaylist(
          id: id,
          name: name,
          description: playlist.description,
          coverAsset: null,
        );
        ref.invalidate(playlistProvider(id));
      } else {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('删除酷狗云端歌单？'),
            content: Text('将从酷狗账号中删除「${playlist.name}」。此操作会同步到酷狗。'),
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
        await repository.deletePlaylist(id);
        if (context.mounted) context.go('/music?view=playlists');
      }
    } catch (error) {
      if (context.mounted) showPlatformFailure(context, error);
    }
  }
}
