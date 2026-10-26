import '../../../shared/models/track.dart';
import 'embedded_kugou_music_source.dart';
import 'music_platform_api.dart';

/// Shared response parsing for the upstream discovery and cloud-list APIs.
/// No UI page constructs signed URLs or guesses cloud playlist identifiers.
class PlatformCatalog {
  PlatformCatalog(this.api);
  final MusicPlatformApi api;

  static List<Map<String, dynamic>> rows(Object? value) {
    if (value is List) {
      return value.whereType<Map>().map(MusicPlatformApi.objectMap).toList();
    }
    if (value is Map) {
      for (final key in [
        'data',
        'info',
        'songs',
        'song_list',
        'list',
        'lists',
        'tracks',
        'items',
      ]) {
        if (value[key] is List) return rows(value[key]);
      }
      if (value['data'] is Map) return rows(value['data']);
    }
    return const [];
  }

  static List<Track> tracks(Object? value) => rows(value)
      .map(EmbeddedKugouMusicSource.platformTrack)
      .whereType<Track>()
      // The audio handler resolves this private marker immediately before
      // loading each active song. Listing 10,000 favorites needs no 10,000 URL
      // requests; signed media URLs never become a persistent cloud cache.
      .map(
        (track) =>
            track.copyWith(audioAsset: 'mesting-platform://kugou/${track.id}'),
      )
      .toList(growable: false);

  Future<List<Track>> daily() async {
    final loggedIn = api.session != null;
    final payload = await api.get(
      loggedIn ? '/everyday/recommend' : '/top/song',
      query: loggedIn ? const {} : const {'type': '21608', 'pagesize': '30'},
    );
    return tracks(payload);
  }

  /// Discovery is a public new-song chart even when daily picks are personal.
  Future<List<Track>> newSongs() async => tracks(
    await api.get(
      '/top/song',
      query: const {'type': '21608', 'pagesize': '30'},
    ),
  );

  Future<List<Track>> discovery() async => tracks(
    await api.get(
      '/home/discover',
      query: const {'pagesize': '20', 'recall_type': 'song'},
    ),
  );

  Future<List<Map<String, dynamic>>> featured() async => rows(
    await api.get(
      '/top/playlist',
      query: {
        'page': '1',
        'pagesize': '12',
        'userid': api.session?.userId ?? '0',
      },
    ),
  );

  Future<List<Track>> publicPlaylist(String globalId) async {
    final result = <Track>[];
    final seen = <String>{};
    for (var page = 1; page <= 50; page++) {
      final payload = await api.get(
        '/playlist/track/all',
        query: {
          'global_collection_id': globalId,
          'page': '$page',
          'pagesize': '200',
        },
      );
      final batch = rows(payload);
      var added = 0;
      for (final track in tracks(batch)) {
        if (seen.add(track.id)) {
          result.add(track);
          added++;
        }
      }
      if (batch.length < 200) return result;
      if (added == 0) throw const MusicPlatformException('平台歌单分页未前进，请重新加载');
    }
    throw const MusicPlatformException('歌单超过本次加载上限，请在平台客户端查看完整内容');
  }
}
