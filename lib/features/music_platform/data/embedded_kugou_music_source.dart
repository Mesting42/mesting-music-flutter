import 'package:http/http.dart' as http;

import '../../../shared/models/track.dart';
import '../../search/data/kugou_music_source.dart';
import 'music_platform_api.dart';

/// Translates md3Music data into existing Mesting tracks and uses its one audio
/// handler. Existing Netease/Audius/Jamendo sources remain independently usable.
class EmbeddedKugouMusicSource extends KugouMusicSource {
  EmbeddedKugouMusicSource(super.client, this.api);
  final MusicPlatformApi api;

  /// Refresh only the selected song at playback time. Stored library rows may
  /// outlive a signed URL or have been saved under a different platform login.
  Future<Track> resolveTrack(Track track, {Future<void>? abortTrigger}) async {
    if (track.source != TrackSource.kugou || !track.id.startsWith('kugou_')) {
      return track;
    }
    final payload = await api.get(
      '/song/url',
      query: {'hash': track.id.substring('kugou_'.length), 'quality': '128'},
      abortTrigger: abortTrigger,
    );
    final value = payload['data'];
    final audio = MusicPlatformApi.objectMap(
      value is List && value.isNotEmpty ? value.first : value ?? payload,
    );
    final rawUrl = audio['url'] ?? audio['play_url'];
    final url = rawUrl is List
        ? (rawUrl.isEmpty ? '' : '${rawUrl.first}')
        : '${rawUrl ?? ''}';
    final uri = Uri.tryParse(url);
    final playable =
        uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' || uri.scheme == 'http');
    final fail = audio['fail_process'];
    return track.copyWith(
      audioAsset: playable ? url : '',
      isPreview: fail is List && fail.contains('buy'),
      availabilityMessage: playable ? '' : '该歌曲当前不可播放，可能需要平台账号或相应权限',
    );
  }

  @override
  Future<List<Track>> search(
    String query, {
    int limit = 20,
    Future<void>? abortTrigger,
  }) async {
    final result = await api.get(
      '/search',
      query: {
        'keywords': query,
        'page': '1',
        'pagesize': '$limit',
        'type': 'song',
      },
      abortTrigger: abortTrigger,
    );
    return _resolveRows(result, limit, abortTrigger);
  }

  @override
  Future<List<Track>> ranking({
    required String rankId,
    required String sourceLabel,
    int limit = 9,
    Future<void>? abortTrigger,
  }) async {
    final result = await api.get(
      '/rank/audio',
      query: {'rankid': rankId, 'page': '1', 'pagesize': '$limit'},
      abortTrigger: abortTrigger,
    );
    return _resolveRows(result, limit, abortTrigger);
  }

  Future<List<Track>> _resolveRows(
    Map<String, dynamic> result,
    int limit,
    Future<void>? abortTrigger,
  ) async {
    final raw = result['data'];
    final data = MusicPlatformApi.objectMap(raw);
    final rows = raw is List
        ? raw
        : data['lists'] ??
              data['songs'] ??
              data['info'] ??
              data['songlist'] ??
              data['list'];
    if (rows is! List) return const [];
    final candidates = rows.whereType<Map>().take(limit).toList();
    final tracks = List<Track?>.filled(candidates.length, null);
    var next = 0;
    Future<void> worker() async {
      while (next < candidates.length) {
        final index = next++;
        final track = platformTrack(
          MusicPlatformApi.objectMap(candidates[index]),
        );
        if (track == null) continue;
        try {
          tracks[index] = await resolveTrack(track, abortTrigger: abortTrigger);
        } on http.RequestAbortedException {
          rethrow;
        } on Object {
          tracks[index] = track;
        }
      }
    }

    await Future.wait(
      List.generate(candidates.length.clamp(0, 4), (_) => worker()),
    );
    return tracks.whereType<Track>().toList(growable: false);
  }

  /// Response shapes differ by endpoint; preserve provider IDs for later
  /// account/playlist adapters and strip highlight markup from search results.
  static Track? platformTrack(Map<String, dynamic> row) {
    String text(List<String> keys) {
      for (final key in keys) {
        final value = '${row[key] ?? ''}'
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim();
        if (value.isNotEmpty) return value;
      }
      return '';
    }

    final hash = text(['hash', 'FileHash', 'filehash', 'audio_hash']);
    if (hash.isEmpty) return null;
    var duration =
        int.tryParse(text(['duration', 'Duration', 'timelength'])) ?? 0;
    if (duration > 10000) duration ~/= 1000;
    return Track(
      id: 'kugou_$hash',
      title: text(['songname', 'SongName', 'audio_name', 'name', 'filename']),
      artist: text(['singername', 'SingerName', 'author_name', 'singer']),
      album: text(['album_name', 'AlbumName', 'albumname']),
      duration: Duration(seconds: duration),
      audioAsset: '',
      coverAsset: text([
        'sizable_cover',
        'img',
        'Image',
        'cover',
        'album_sizable_cover',
      ]).replaceAll('{size}', '400'),
      lyricsAsset: '',
      source: TrackSource.kugou,
      provider: '酷狗音乐 · md3Music',
      availabilityMessage: '需要联网获取播放地址',
    );
  }
}
