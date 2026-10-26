import '../../../shared/models/track.dart';
import 'music_platform_api.dart';
import 'platform_catalog.dart';
import 'platform_artwork.dart';

enum PlatformExploreKind {
  theme('主题歌单', '/theme/playlist'),
  // Labels come from the scene catalogue. /scene/music returns recommended
  // tracks; it does not define the catalogue of named scene categories.
  scene('场景音乐', '/scene/lists'),
  playlist('热门歌单', '/top/playlist'),
  rank('排行榜', '/rank/list'),
  album('新碟上架', '/top/album');

  const PlatformExploreKind(this.label, this.path);
  final String label, path;
}

class PlatformExploreItem {
  const PlatformExploreItem({
    required this.id,
    required this.title,
    required this.cover,
    required this.kind,
    this.rankCid = '',
  });
  final String id, title, cover, rankCid;
  final PlatformExploreKind kind;
}

/// Mirrors md3Music's MusicExploreSections and provider field parsing. No
/// personalized local ranking is applied to public discovery catalogues.
class PlatformExploreRepository {
  const PlatformExploreRepository(this.api);
  final MusicPlatformApi api;
  Future<List<PlatformExploreItem>> list(
    PlatformExploreKind kind, {
    int page = 1,
  }) async {
    final payload = await api.get(
      kind.path,
      query: {
        if (kind == PlatformExploreKind.rank) 'withsong': '1',
        if (kind == PlatformExploreKind.playlist ||
            kind == PlatformExploreKind.album)
          'page': '$page',
      },
    );
    var rows = PlatformCatalog.rows(payload);
    if (kind == PlatformExploreKind.scene) rows = _sceneRows(payload);
    final data = MusicPlatformApi.objectMap(payload['data']);
    if (kind == PlatformExploreKind.rank && rows.isEmpty) {
      rows = PlatformCatalog.rows(data['ranks']);
    }
    if (kind == PlatformExploreKind.album && rows.isEmpty) {
      rows = [
        for (final key in ['chn', 'eur', 'jpn', 'kor'])
          ...PlatformCatalog.rows(data[key]),
      ];
      if (rows.isEmpty) rows = PlatformCatalog.rows(data['albums']);
    }
    return rows
        .map((row) {
          String text(List<String> keys) {
            for (final key in keys) {
              if ('${row[key] ?? ''}'.isNotEmpty) return '${row[key]}';
            }
            return '';
          }

          return PlatformExploreItem(
            id: text(switch (kind) {
              PlatformExploreKind.playlist => [
                'global_collection_id',
                'gid',
                'specialid',
                'id',
              ],
              PlatformExploreKind.album => [
                'albumid',
                'album_id',
                'AlbumID',
                'id',
              ],
              PlatformExploreKind.rank => [
                'rankid',
                'rank_id',
                'id',
                'classify',
              ],
              _ => ['id', 'theme_id', 'scene_id'],
            }),
            title: text([
              'name',
              'specialname',
              'rankname',
              'album_name',
              'albumname',
              'title',
              'scene_name',
            ]),
            cover: PlatformArtwork.fromPayload(row),
            kind: kind,
            rankCid: text(['rank_cid']),
          );
        })
        .where((item) => item.title.isNotEmpty)
        .toList();
  }

  /// Scene catalogues use both flat and grouped envelopes. Only real named
  /// scene records become labels; recommendation tracks are not substitutes.
  static List<Map<String, dynamic>> _sceneRows(Object? value) {
    if (value is List) return [for (final item in value) ..._sceneRows(item)];
    if (value is! Map) return const [];
    final row = MusicPlatformApi.objectMap(value);
    for (final key in [
      'data',
      'scene_list',
      'scenes',
      'list',
      'lists',
      'info',
      'children',
    ]) {
      final nested = _sceneRows(row[key]);
      if (nested.isNotEmpty) return nested;
    }
    final id = row['scene_id'] ?? row['id'];
    final name = row['scene_name'] ?? row['name'] ?? row['title'];
    return id != null &&
            '$id'.isNotEmpty &&
            name != null &&
            '$name'.trim().isNotEmpty
        ? [row]
        : const [];
  }

  Future<List<Track>> tracks(PlatformExploreItem item, {int page = 1}) async {
    final path = switch (item.kind) {
      PlatformExploreKind.rank => '/rank/audio',
      PlatformExploreKind.album => '/album/songs',
      PlatformExploreKind.playlist => '/playlist/track/all',
      PlatformExploreKind.theme => '/theme/playlist/track',
      PlatformExploreKind.scene => '/scene/audio/list',
    };
    return PlatformCatalog.tracks(
      await api.get(
        path,
        query: {
          if (item.kind == PlatformExploreKind.rank) ...{
            'rankid': item.id,
            'rank_cid': item.rankCid.isEmpty ? '0' : item.rankCid,
          },
          if (item.kind == PlatformExploreKind.album) 'album_id': item.id,
          if (item.kind == PlatformExploreKind.playlist)
            'global_collection_id': item.id,
          if (item.kind == PlatformExploreKind.theme ||
              item.kind == PlatformExploreKind.scene)
            'id': item.id,
          'page': '$page',
          'pagesize': '30',
        },
      ),
    );
  }
}
