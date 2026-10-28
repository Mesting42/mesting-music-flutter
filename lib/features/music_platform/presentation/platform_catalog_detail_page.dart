import '../platform_backend_providers.dart';
import '../domain/platform_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/track.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/automatic_song_paging.dart';
import '../../experience/presentation/editorial_widgets.dart';
import '../music_platform_providers.dart';
import '../data/platform_catalog.dart';
import '../data/platform_category_search.dart';
import '../data/music_platform_api.dart';
import 'platform_design.dart';

/// Read-only real catalogue details; selected songs use the shared audio owner
/// and account-guarded library actions. No surrounding list is an implicit queue.
class PlatformCatalogDetailPage extends ConsumerStatefulWidget {
  const PlatformCatalogDetailPage({required this.hit, super.key});
  final PlatformSearchHit hit;
  @override
  ConsumerState<PlatformCatalogDetailPage> createState() =>
      _PlatformCatalogDetailPageState();
}

class _PlatformCatalogDetailPageState
    extends ConsumerState<PlatformCatalogDetailPage> {
  final _tracks = <Track>[];
  bool _busy = false, _more = true;
  int _page = 0;
  String? _error;
  Future<List<Track>>? _neteaseTracks;
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    if (_busy || !_more) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(musicPlatformApiProvider);
    final identity = ref.read(platformAccountProvider).value;
    try {
      final hit = widget.hit;
      if (hit.kind == PlatformSearchKind.playlists && hit.globalId.isEmpty) {
        throw const MusicPlatformException('平台未返回可打开的歌单标识，请返回后重试');
      }
      final List<Track> fresh;
      final int rowCount;
      if (identity?.platform == MusicPlatform.netease) {
        final all = await (_neteaseTracks ??= ref
            .read(neteaseMusicRepositoryProvider)
            .categoryTracks(hit));
        fresh = all.skip(_page * 30).take(30).toList();
        rowCount = fresh.length;
      } else {
        final payload = await api.get(
          switch (hit.kind) {
            PlatformSearchKind.artists => '/artist/audios',
            PlatformSearchKind.albums => '/album/songs',
            _ => '/playlist/track/all',
          },
          query: {
            if (hit.kind == PlatformSearchKind.artists) 'id': hit.id,
            if (hit.kind == PlatformSearchKind.albums) 'album_id': hit.id,
            if (hit.kind == PlatformSearchKind.playlists)
              'global_collection_id': hit.globalId,
            'page': '${_page + 1}',
            'pagesize': '30',
          },
          expectedSession: identity,
        );
        final rows = PlatformCatalog.rows(payload);
        fresh = PlatformCatalog.tracks(rows);
        rowCount = rows.length;
      }
      if (!mounted ||
          ref.read(platformAccountProvider).value?.ownerId !=
              identity?.ownerId ||
          ref.read(platformAccountProvider).value?.token != identity?.token) {
        return;
      }
      setState(() {
        final ids = _tracks.map((t) => t.id).toSet();
        final added = fresh.where((t) => ids.add(t.id)).toList();
        _tracks.addAll(added);
        _page++;
        _more = rowCount >= 30 && added.isNotEmpty;
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is MusicPlatformException
              ? error.message
              : '加载未完成，请重试',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PlatformPageFrame(
    title: widget.hit.title,
    child: AutomaticSongPaging(
      enabled: _more && !_busy && _error == null,
      onLoadMore: _load,
      child: ListView.builder(
        key: PageStorageKey('catalog-${widget.hit.kind.name}-${widget.hit.id}'),
        padding: const EdgeInsets.only(bottom: 190),
        itemCount: _tracks.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      widget.hit.kind == PlatformSearchKind.artists ? 50 : 14,
                    ),
                    child: ArtworkImage(
                      uri: widget.hit.cover,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(child: Text(widget.hit.subtitle)),
                ],
              ),
            );
          }
          if (index <= _tracks.length) {
            return EditorialTrackRow(
              track: _tracks[index - 1],
              contextTracks: _tracks,
            );
          }
          if (_busy) return const PlatformFeedbackState(loading: true);
          if (_error != null) {
            return TextButton(onPressed: _load, child: Text(_error!));
          }
          return _tracks.isEmpty
              ? const EditorialEmpty('平台暂未返回歌曲')
              : const SizedBox(height: 20);
        },
      ),
    ),
  );
}
