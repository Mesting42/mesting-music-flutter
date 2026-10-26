import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/models/track.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../library/presentation/favorite_toggle_button.dart';
import '../../player/presentation/music_hub_top_bar.dart';
import '../../search/search_providers.dart';
import '../../playlists/presentation/add_to_playlist_sheet.dart';
import '../../library/library_providers.dart';
import 'platform_feedback.dart';
import '../music_platform_providers.dart';
import '../platform_catalog_providers.dart';
import '../../auth/account_capabilities.dart';
import 'platform_comments_page.dart';

/// The incumbent Mesting shell with live upstream content. Each section owns
/// its loading/error state; a failed playlist request cannot hide valid songs.
class PlatformDiscoveryPage extends ConsumerWidget {
  const PlatformDiscoveryPage({this.dailyOnly = false, super.key});
  final bool dailyOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(platformAccountProvider).value != null;
    final daily = ref.watch(platformDailyProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(platformDailyProvider);
        ref.invalidate(platformDiscoveryProvider);
        ref.invalidate(platformFeaturedProvider);
        ref.invalidate(hotMusicControllerProvider);
        // Each section renders its own error, including a failed refresh.
        await ref
            .read(platformDailyProvider.future)
            .then<void>((_) {}, onError: (Object _) {});
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
            title: dailyOnly ? '每日推荐' : '发现音乐',
            subtitle: signedIn ? '酷狗概念版 · 为你推荐' : '酷狗概念版 · 公共推荐',
            showBack: dailyOnly,
            onBack: dailyOnly
                ? () => context.canPop()
                      ? context.pop()
                      : context.go('/music/recommend')
                : null,
          ),
          const SizedBox(height: 24),
          _SectionTitle(signedIn ? '你的每日推荐' : '新歌推荐'),
          PlatformSongs(
            value: daily,
            retry: () => ref.invalidate(platformDailyProvider),
          ),
          if (!dailyOnly) ...[
            const SizedBox(height: 24),
            const _SectionTitle('精选歌单'),
            _FeaturedPlaylists(),
            const SizedBox(height: 24),
            const _SectionTitle('发现更多音乐'),
            PlatformSongs(
              value: ref.watch(platformDiscoveryProvider),
              retry: () => ref.invalidate(platformDiscoveryProvider),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('实时榜单'),
            ref
                .watch(hotMusicControllerProvider)
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stack) => _Retry(
                    retry: () => ref.invalidate(hotMusicControllerProvider),
                  ),
                  data: (snapshot) => snapshot.tracks.isEmpty
                      ? _Retry(
                          retry: () =>
                              ref.invalidate(hotMusicControllerProvider),
                        )
                      : _TrackList(tracks: snapshot.tracks),
                ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.retry, this.empty = false});
  final VoidCallback retry;
  final bool empty;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      children: [
        Text(empty ? '平台暂未返回内容' : '内容暂时未能加载，请重试'),
        TextButton.icon(
          onPressed: retry,
          icon: const Icon(Icons.refresh),
          label: const Text('重新加载'),
        ),
      ],
    ),
  );
}

class PlatformSongs extends StatelessWidget {
  const PlatformSongs({
    required this.value,
    required this.retry,
    this.playlistId,
    super.key,
  });
  final AsyncValue<List<Track>> value;
  final VoidCallback retry;
  final String? playlistId;
  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const LinearProgressIndicator(),
    error: (error, stack) => _Retry(retry: retry),
    data: (tracks) => tracks.isEmpty
        ? _Retry(retry: retry, empty: true)
        : _TrackList(tracks: tracks, playlistId: playlistId),
  );
}

class _TrackList extends ConsumerWidget {
  const _TrackList({required this.tracks, this.playlistId});
  final List<Track> tracks;
  final String? playlistId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      for (final track in tracks)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ArtworkImage(uri: track.coverAsset, width: 48, height: 48),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FavoriteToggleButton(track: track, compact: true),
              PopupMenuButton<String>(
                tooltip: '歌曲操作',
                icon: const Icon(Icons.more_horiz),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'add', child: Text('加入歌单')),
                  if (ref.read(showPlatformFeaturesProvider))
                    const PopupMenuItem(
                      value: 'comments',
                      child: Text('酷狗歌曲评论'),
                    ),
                  if (playlistId != null)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('从云端歌单移除'),
                    ),
                ],
                onSelected: (action) async {
                  if (!context.mounted) return;
                  if (action == 'add') {
                    await showAddToPlaylistSheet(context, ref, track);
                  }
                  if (action == 'comments' && context.mounted) {
                    await openPlatformSongComments(context, ref, track);
                  }
                  if (action == 'remove' && playlistId != null) {
                    try {
                      await ref
                          .read(libraryRepositoryProvider)
                          .removeTrackFromPlaylist(playlistId!, track.id);
                    } catch (error) {
                      if (context.mounted) showPlatformFailure(context, error);
                    }
                  }
                },
              ),
            ],
          ),
          onTap: () async {
            try {
              await ref
                  .read(audioHandlerProvider)
                  .playSingleTrack(track, playbackContext: tracks);
            } catch (error) {
              if (context.mounted) {
                showPlatformFailure(context, error);
              }
            }
          },
        ),
    ],
  );
}

class _FeaturedPlaylists extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(platformFeaturedProvider)
      .when(
        loading: () => const LinearProgressIndicator(),
        error: (error, stack) =>
            _Retry(retry: () => ref.invalidate(platformFeaturedProvider)),
        data: (rows) {
          final playlists = rows
              .where(
                (row) => '${row['global_collection_id'] ?? row['gid'] ?? ''}'
                    .isNotEmpty,
              )
              .toList();
          if (playlists.isEmpty) {
            return _Retry(
              retry: () => ref.invalidate(platformFeaturedProvider),
              empty: true,
            );
          }
          return Column(
            children: [
              for (final row in playlists)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ArtworkImage(
                      uri:
                          '${row['sizable_cover'] ?? row['imgurl'] ?? row['pic'] ?? ''}'
                              .replaceAll('{size}', '400'),
                      width: 56,
                      height: 56,
                    ),
                  ),
                  title: Text(
                    '${row['name'] ?? row['specialname'] ?? '精选歌单'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('酷狗概念版'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlatformPublicPlaylistPage(
                        id: '${row['global_collection_id'] ?? row['gid']}',
                        name: '${row['name'] ?? row['specialname'] ?? '精选歌单'}',
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

class PlatformPublicPlaylistPage extends ConsumerWidget {
  const PlatformPublicPlaylistPage({
    required this.id,
    required this.name,
    super.key,
  });
  final String id;
  final String name;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(
      title: Text(name),
      actions: [
        if (ref.watch(showPlatformFeaturesProvider))
          IconButton(
            tooltip: '酷狗歌单评论',
            icon: const Icon(Icons.comment_outlined),
            onPressed: () =>
                openPlatformPlaylistComments(context, ref, id: id, name: name),
          ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        PlatformSongs(
          value: ref.watch(platformPublicPlaylistProvider(id)),
          retry: () => ref.invalidate(platformPublicPlaylistProvider(id)),
        ),
      ],
    ),
  );
}
