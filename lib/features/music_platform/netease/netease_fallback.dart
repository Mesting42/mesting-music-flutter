import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/persistence/app_preferences.dart';
import '../../../shared/models/track.dart';
import '../data/embedded_kugou_music_source.dart';
import '../data/music_platform_api.dart';
import '../domain/platform_audio_quality.dart';
import '../music_platform_providers.dart';
import '../platform_backend_providers.dart';

final neteaseFallbackEnabledProvider =
    NotifierProvider<NeteaseFallbackSetting, bool>(NeteaseFallbackSetting.new);

class NeteaseFallbackSetting extends Notifier<bool> {
  static const key = 'netease_same_recording_fallback_v1';
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(key) ?? true;
  Future<void> setEnabled(bool value) async {
    if (!await ref.read(sharedPreferencesProvider).setBool(key, value)) {
      throw const MusicPlatformException('补源设置未保存，请重试');
    }
    state = value;
  }
}

/// Strict, deliberately conservative matching. Version words are never removed
/// from titles/albums; unknown durations cannot establish the same recording.
/// Missing evidence rejects a candidate rather than silently playing a cover.
bool isSameNeteaseRecording(Track original, Track candidate) {
  String normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[\s\p{P}\p{S}]', unicode: true), '');
  Set<String> artists(String value) => value
      .split(RegExp(r'\s*(?:/|&|、|,|，|;|；)\s*'))
      .map(normalize)
      .where((a) => a.isNotEmpty)
      .toSet();
  if (normalize(original.title).isEmpty ||
      normalize(original.title) != normalize(candidate.title)) {
    return false;
  }
  final a = artists(original.artist), b = artists(candidate.artist);
  if (a.isEmpty || a.length != b.length || !a.containsAll(b)) return false;
  if (original.duration <= Duration.zero ||
      candidate.duration <= Duration.zero ||
      (original.duration - candidate.duration).inMilliseconds.abs() > 2000) {
    return false;
  }
  // A known album is part of the identity, particularly for live/re-recordings.
  if (original.album.isNotEmpty &&
      (candidate.album.isEmpty ||
          normalize(original.album) != normalize(candidate.album))) {
    return false;
  }
  return true;
}

abstract interface class NeteaseFallbackSource {
  String get label;
  Future<List<Track>> search(Track original);
  Future<Track?> resolve(Track candidate);
}

/// Exact NetEase IDs avoid cross-platform title matching. This public service
/// is anonymous: only a song ID and requested quality leave the device.
/// Calls are serialized at >=1s intervals per the provider's published limit.
class BugpkNeteaseFallback implements NeteaseFallbackSource {
  BugpkNeteaseFallback(this.client);
  final http.Client client;
  Future<void> _tail = Future.value();
  DateTime _lastRequest = DateTime.fromMillisecondsSinceEpoch(0);
  @override
  String get label => 'BugPk · 网易云同曲';
  @override
  Future<List<Track>> search(Track original) async => [original];
  @override
  Future<Track?> resolve(Track candidate) {
    final result = _tail.then((_) async {
      final delay =
          const Duration(milliseconds: 1100) -
          DateTime.now().difference(_lastRequest);
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      _lastRequest = DateTime.now();
      final id = candidate.platformSongId.isNotEmpty
          ? candidate.platformSongId
          : candidate.id.replaceFirst('netease_', '');
      final response = await client
          .get(
            Uri.https('api.bugpk.com', '/api/163_music', {
              'type': 'url',
              'id': id,
              'level': switch (candidate.playbackQuality) {
                'flac' => 'lossless',
                'high' => 'hires',
                '320' => 'exhigh',
                _ => 'standard',
              },
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final payload = MusicPlatformApi.objectMap(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
      if (payload['code'] != 200) return null;
      final rows = payload['data'];
      final row = MusicPlatformApi.objectMap(
        rows is List && rows.isNotEmpty ? rows.first : rows,
      );
      if ('${row['id']}' != id || row['freeTrialInfo'] is Map) return null;
      final url = Uri.tryParse('${row['url'] ?? ''}');
      if (url == null ||
          url.scheme != 'https' ||
          !url.host.endsWith('.music.126.net')) {
        return null;
      }
      final delivered = switch ('${row['level']}') {
        'standard' => '128',
        'higher' || 'exhigh' => '320',
        'lossless' => 'flac',
        'hires' => 'high',
        _ => '',
      };
      // Some provider responses silently downgrade. Keep the delivered tier.
      return candidate.copyWith(
        audioAsset: url.toString(),
        isPreview: false,
        playbackQuality: delivered,
      );
    });
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}

/// This anonymous API is owned exclusively by the fallback module. It never
/// observes either saved platform session, including a retained Kugou login.
class AnonymousKugouFallback implements NeteaseFallbackSource {
  AnonymousKugouFallback(this.source);
  final EmbeddedKugouMusicSource source;
  @override
  String get label => '酷狗公开音源';
  @override
  Future<List<Track>> search(Track original) =>
      source.search('${original.title} ${original.artist}', limit: 12);
  @override
  Future<Track?> resolve(Track candidate) async {
    final result = await source.resolveTrack(candidate);
    return result.isPreview ? null : result;
  }
}

class AnonymousKuwoFallback implements NeteaseFallbackSource {
  AnonymousKuwoFallback(this.client);
  final http.Client client;
  @override
  String get label => '酷我公开音源';
  @override
  Future<List<Track>> search(Track original) async {
    final query = '${original.title} ${original.artist}';
    final landing = await client.get(
      Uri.https('www.kuwo.cn', '/search/list', {'key': query}),
    );
    final token = RegExp(
      r'kw_token=([^;,\s]+)',
    ).firstMatch(landing.headers['set-cookie'] ?? '')?.group(1);
    if (token == null) return [];
    final result = await client.get(
      Uri.https('www.kuwo.cn', '/api/www/search/searchMusicBykeyWord', {
        'key': query,
        'pn': '1',
        'rn': '20',
      }),
      headers: {
        'Referer': Uri.https('www.kuwo.cn', '/search/list', {
          'key': query,
        }).toString(),
        'csrf': token,
        'Cookie': 'kw_token=$token',
      },
    );
    final data = MusicPlatformApi.objectMap(
      jsonDecode(utf8.decode(result.bodyBytes)),
    );
    final list = MusicPlatformApi.objectMap(data['data'])['list'];
    if (list is! List) return [];
    return list.whereType<Map>().map((r) {
      var seconds = num.tryParse('${r['duration']}')?.toDouble() ?? 0;
      if (seconds <= 0) {
        for (final part in '${r['songTimeMinutes'] ?? ''}'.split(':')) {
          seconds = seconds * 60 + (num.tryParse(part) ?? 0);
        }
      }
      final id = '${r['rid'] ?? r['musicrid'] ?? ''}'.replaceFirst(
        'MUSIC_',
        '',
      );
      return Track(
        id: 'kuwo_$id',
        title: '${r['name'] ?? ''}',
        artist: '${r['artist'] ?? ''}',
        album: '${r['album'] ?? ''}',
        duration: Duration(milliseconds: (seconds * 1000).round()),
        audioAsset: id,
        coverAsset: '',
        lyricsAsset: '',
        source: TrackSource.netease,
      );
    }).toList();
  }

  @override
  Future<Track?> resolve(Track candidate) async {
    final result = await client.get(
      Uri.https('antiserver.kuwo.cn', '/anti.s', {
        'type': 'convert_url',
        'format': 'mp3',
        'response': 'url',
        'rid': 'MUSIC_${candidate.audioAsset}',
      }),
    );
    final url = result.body.trim();
    return url.startsWith('http')
        ? candidate.copyWith(audioAsset: url, playbackQuality: '')
        : null;
  }
}

/// Probe only the first response chunk. Reject HTML/JSON errors and never
/// download an entire file just to decide whether playback can start.
Future<bool> probeAudio(http.Client client, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      !{'http', 'https'}.contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return false;
  }
  final response = await client
      .send(http.Request('GET', uri)..headers['Range'] = 'bytes=0-1023')
      .timeout(const Duration(seconds: 8));
  if (response.statusCode != 200 && response.statusCode != 206) {
    await response.stream.take(1).drain<void>();
    return false;
  }
  final type = response.headers['content-type'] ?? '';
  final prefix = await response.stream.first.timeout(
    const Duration(seconds: 8),
  );
  if (prefix.isEmpty || type.contains('text/') || type.contains('json')) {
    return false;
  }
  return type.contains('audio') ||
      type.contains('octet-stream') ||
      (prefix.length >= 3 && String.fromCharCodes(prefix.take(3)) == 'ID3') ||
      (prefix.length > 1 && prefix[0] == 0xff && prefix[1] & 0xe0 == 0xe0);
}

class NeteaseFallbackResolver {
  const NeteaseFallbackResolver(this.sources, this.client);
  final List<NeteaseFallbackSource> sources;
  final http.Client client;
  Future<Track?> resolve(
    Track original, {
    required bool Function() current,
  }) async {
    for (final source in sources) {
      if (!current()) return null;
      try {
        final candidates = await source
            .search(original)
            .timeout(const Duration(seconds: 12));
        if (!current()) return null;
        for (final candidate
            in candidates
                .where(
                  (c) =>
                      source is BugpkNeteaseFallback ||
                      isSameNeteaseRecording(original, c),
                )
                .take(2)) {
          final resolved = await source
              .resolve(candidate)
              .timeout(const Duration(seconds: 12));
          if (!current()) return null;
          if (resolved == null ||
              resolved.isPreview ||
              !await probeAudio(client, resolved.audioAsset)) {
            continue;
          }
          if (!current()) return null;
          return original.copyWith(
            audioAsset: resolved.audioAsset,
            isPreview: false,
            playbackQuality: resolved.playbackQuality,
            availabilityMessage: '备用音源 · ${source.label}',
          );
        }
      } catch (_) {
        /* One unavailable provider must not stop the remaining sources. */
      }
    }
    return null;
  }
}

final neteaseFallbackResolverProvider = Provider<NeteaseFallbackResolver>((
  ref,
) {
  final client = http.Client();
  ref.onDispose(client.close);
  final api = MusicPlatformApi(
    server: ref.watch(musicServerProvider),
    client: client,
  );
  return NeteaseFallbackResolver([
    BugpkNeteaseFallback(client),
    AnonymousKugouFallback(EmbeddedKugouMusicSource(client, api)),
    AnonymousKuwoFallback(client),
  ], client);
});

Future<Track> resolveNeteasePlayback(
  WidgetRef ref,
  Track track,
  PlatformAudioQuality quality, {
  bool requireQuality = false,
}) async {
  final music = ref.read(neteaseMusicRepositoryProvider);
  final credential = music.credential;
  bool current() =>
      ref.context.mounted &&
      ref.read(usesNeteaseProvider) &&
      ref.read(neteaseMusicRepositoryProvider).credential == credential;
  Track? original;
  Object? failure;
  try {
    original = await music.resolve(
      track,
      quality,
      requireQuality: requireQuality,
    );
  } catch (error) {
    failure = error;
  }
  if (!current()) throw const MusicPlatformException('账号已变化，请重新播放');
  if (requireQuality) {
    if (original != null) return original;
    throw failure!;
  }
  if (original != null && !original.isPreview) return original;
  if (failure is MusicPlatformException &&
      {'301', '302', '415', '405', '460'}.contains(failure.code)) {
    throw failure;
  }
  if (ref.read(neteaseFallbackEnabledProvider)) {
    final fallback = await ref
        .read(neteaseFallbackResolverProvider)
        .resolve(
          track.copyWith(playbackQuality: quality.code),
          current: current,
        );
    if (fallback != null) return fallback;
  }
  if (!current()) throw const MusicPlatformException('账号已变化，请重新播放');
  if (original != null) return original;
  throw failure ?? const MusicPlatformException('未找到同一录音版本的可播放音源');
}
