// SPDX-License-Identifier: LGPL-3.0-only
// Native adaptation of pinned UnblockNeteaseMusic provider protocols.
// Original source, license and adaptation notes: third_party/unblock_netease/.
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../../../../shared/models/track.dart';
import 'netease_fallback_source.dart';

Map<String, dynamic> _object(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
int _number(Object? value) => num.tryParse('$value')?.round() ?? 0;
String _secureUrl(Object? value) {
  final uri = Uri.tryParse('${value ?? ''}');
  if (uri == null ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      !{'https', 'http'}.contains(uri.scheme)) {
    return '';
  }
  return uri.replace(scheme: 'https').toString();
}

/// Native adapter for upstream pyncmd. Currently kept out of production source
/// selection: on 2026-10-29 the service rejected source=netease with HTTP 400.
/// Keeping the adapter/test permits an explicit future revalidation, not an
/// automatic switch to an unrelated platform or relay server.
class GdStudioNeteaseSource implements NeteaseExactIdSource {
  GdStudioNeteaseSource(this.client, {this.lossless = true});
  final http.Client client;
  final bool lossless;
  @override
  String get label => 'GD Studio · 网易云同曲';
  @override
  Future<List<Track>> search(Track original) async => [original];
  @override
  Future<Track?> resolve(Track candidate) async {
    final id = candidate.platformSongId.isNotEmpty
        ? candidate.platformSongId
        : candidate.id.replaceFirst('netease_', '');
    if (!RegExp(r'^\d+$').hasMatch(id)) return null;
    final response = await client
        .get(
          Uri.https('music-api.gdstudio.xyz', '/api.php', {
            'types': 'url',
            'source': 'netease',
            'id': id,
            'br':
                lossless && {'flac', 'high'}.contains(candidate.playbackQuality)
                ? '999'
                : '320',
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final data = _object(jsonDecode(utf8.decode(response.bodyBytes)));
    if (data['id'] != null && '${data['id']}' != id) return null;
    if (data['freeTrialInfo'] != null || data['trial'] == true) return null;
    final bitrate = _number(data['br']);
    final url = _secureUrl(data['url']);
    if (url.isEmpty || bitrate <= 0) return null;
    return candidate.copyWith(
      audioAsset: url,
      isPreview: false,
      playbackQuality: bitrate == 999
          ? 'flac'
          : (bitrate >= 320 ? '320' : '128'),
      audioBitrate: bitrate == 999 ? 0 : bitrate * 1000,
    );
  }
}

const _biliHeaders = {
  'Referer': 'https://www.bilibili.com/',
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/130.0.0.0 Safari/537.36',
};

String _plainTitle(Object? text) => '${text ?? ''}'
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .trim();
Duration _duration(Object? value) {
  final text = '${value ?? ''}';
  if (!text.contains(':')) return Duration(seconds: _number(value));
  var seconds = 0;
  for (final part in text.split(':')) {
    seconds = seconds * 60 + _number(part);
  }
  return Duration(seconds: seconds);
}

/// Do not infer the performer from a video category or an arbitrary uploader.
/// Accept an explicit performer/title pair only. Unknown suffixes (Live,
/// cover, remix, 伴奏, etc.) survive and are rejected by recording matching.
String? bilibiliRecordingTitle(String input, Track original) {
  var title = _plainTitle(input);
  title = title
      .replaceAll(
        RegExp(
          r'\s*[【\[](?:官方音频|Official Audio)[】\]]\s*$',
          caseSensitive: false,
        ),
        '',
      )
      .trim();
  final artist = RegExp.escape(original.artist);
  final prefix = RegExp('^$artist\\s*[-—–|｜:：]\\s*', caseSensitive: false);
  final suffix = RegExp('\\s*[-—–|｜]\\s*$artist\$', caseSensitive: false);
  if (prefix.hasMatch(title)) return title.replaceFirst(prefix, '').trim();
  if (suffix.hasMatch(title)) return title.replaceFirst(suffix, '').trim();
  return null;
}

class BilibiliAudioSource implements NeteasePublicMetadataSource {
  BilibiliAudioSource(this.client);
  final http.Client client;
  @override
  String get label => 'B站音频';
  @override
  Future<List<Track>> search(Track original) async {
    final response = await client
        .get(
          Uri.https('api.bilibili.com', '/audio/music-service-c/s', {
            'search_type': 'music',
            'page': '1',
            'pagesize': '10',
            'keyword': '${original.title} ${original.artist}',
          }),
          headers: _biliHeaders,
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return [];
    final data = _object(
      _object(jsonDecode(utf8.decode(response.bodyBytes)))['data'],
    );
    final rows = data['result'];
    if (rows is! List) return [];
    return rows.whereType<Map>().map((row) {
      final explicitTitle = bilibiliRecordingTitle('${row['title']}', original);
      return Track(
        id: 'biliaudio_${row['id']}',
        title: explicitTitle ?? _plainTitle(row['title']),
        artist: explicitTitle != null
            ? original.artist
            : '${row['singer'] ?? row['author'] ?? ''}',
        album: '${row['album_title'] ?? ''}',
        duration: _duration(row['duration']),
        audioAsset: '${row['id']}',
        coverAsset: '',
        lyricsAsset: '',
        source: TrackSource.netease,
        playbackQuality: original.playbackQuality,
      );
    }).toList();
  }

  @override
  Future<Track?> resolve(Track candidate) async {
    final response = await client
        .get(
          Uri.https('www.bilibili.com', '/audio/music-service-c/web/url', {
            'privilege': '2',
            'quality': '2',
            'sid': candidate.audioAsset,
          }),
          headers: _biliHeaders,
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final body = _object(jsonDecode(utf8.decode(response.bodyBytes)));
    final data = _object(body['data']);
    final cdns = data['cdns'];
    if (body['code'] != 0 || cdns is! List || cdns.isEmpty) return null;
    final url = _secureUrl(cdns.first);
    if (url.isEmpty) return null;
    final kbps = _number(data['bitrate']);
    return candidate.copyWith(
      audioAsset: url,
      audioHeaders: _biliHeaders,
      isPreview: false,
      playbackQuality: kbps >= 320 ? '320' : '',
      audioBitrate: kbps * 1000,
    );
  }
}

/// Anonymous WBI protocol adapter, ported from the pinned LGPL upstream.
/// Only visitor cookies are used for metadata requests; never personal cookies,
/// never persist them, and never forward them to another provider or audio CDN.
class BilibiliVideoSource implements NeteasePublicMetadataSource {
  BilibiliVideoSource(this.client, {DateTime Function()? now})
    : now = now ?? DateTime.now;
  final http.Client client;
  final DateTime Function() now;
  String? _mixinKey, _visitorCookie;
  DateTime? _keysUntil;
  @override
  String get label => 'B站视频音轨';
  static const _table = [
    46,
    47,
    18,
    2,
    53,
    8,
    23,
    32,
    15,
    50,
    10,
    31,
    58,
    3,
    45,
    35,
    27,
    43,
    5,
    49,
    33,
    9,
    42,
    19,
    29,
    28,
    14,
    39,
    12,
    38,
    41,
    13,
    37,
    48,
    7,
    16,
    24,
    55,
    40,
    61,
    26,
    17,
    0,
    1,
    60,
    51,
    30,
    4,
    22,
    25,
    54,
    21,
    56,
    59,
    6,
    63,
    57,
    62,
    11,
    36,
    20,
    34,
    44,
    52,
  ];
  Future<Map<String, dynamic>> _get(Uri uri, {bool visitor = false}) async {
    final response = await client
        .get(
          uri,
          headers: {
            ..._biliHeaders,
            if (visitor && _visitorCookie?.isNotEmpty == true)
              'Cookie': _visitorCookie!,
          },
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) throw const FormatException('B站暂不可用');
    return _object(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<void> _keys() async {
    if (_mixinKey != null && _keysUntil?.isAfter(now()) == true) return;
    final body = await _get(
      Uri.https('api.bilibili.com', '/x/web-interface/nav'),
    );
    final images = _object(_object(body['data'])['wbi_img']);
    String key(Object? value) =>
        Uri.tryParse('$value')?.pathSegments.lastOrNull?.split('.').first ?? '';
    final joined = key(images['img_url']) + key(images['sub_url']);
    if (joined.length != 64) throw const FormatException('B站签名信息不可用');
    _mixinKey = _table.map((i) => joined[i]).join().substring(0, 32);
    _keysUntil = now().add(const Duration(minutes: 30));
  }

  Future<Uri> _signed(String path, Map<String, String> parameters) async {
    await _keys();
    final params = {
      ...parameters,
      'wts': '${now().millisecondsSinceEpoch ~/ 1000}',
    };
    final keys = params.keys.toList()..sort();
    String encode(String value) => Uri.encodeComponent(value)
        .replaceAll("'", '%27')
        .replaceAll('!', '%21')
        .replaceAll('(', '%28')
        .replaceAll(')', '%29')
        .replaceAll('*', '%2A');
    final query = keys
        .map(
          (key) =>
              '${encode(key)}=${encode(params[key]!.replaceAll(RegExp(r"[!'()*]"), ''))}',
        )
        .join('&');
    return Uri.parse(
      'https://api.bilibili.com$path?$query&w_rid=${md5.convert(utf8.encode(query + _mixinKey!))}',
    );
  }

  Future<void> _visitor() async {
    if (_visitorCookie != null) return;
    final response = await client
        .get(Uri.https('www.bilibili.com', '/'), headers: _biliHeaders)
        .timeout(const Duration(seconds: 8));
    final text = response.headers['set-cookie'] ?? '';
    _visitorCookie = RegExp(
      r'(?:^|,\s*)(buvid3|buvid4|b_nut)=([^;,\s]+)',
    ).allMatches(text).map((m) => '${m[1]}=${m[2]}').join('; ');
  }

  @override
  Future<List<Track>> search(Track original) async {
    await _visitor();
    final body = await _get(
      await _signed('/x/web-interface/wbi/search/type', {
        'search_type': 'video',
        'keyword': '${original.title} ${original.artist}',
        'page': '1',
      }),
      visitor: true,
    );
    final rows = _object(body['data'])['result'];
    if (body['code'] != 0 || rows is! List) return [];
    final result = <Track>[];
    for (final row in rows.whereType<Map>()) {
      final title = bilibiliRecordingTitle('${row['title']}', original);
      final id = '${row['bvid'] ?? ''}';
      if (title == null || !RegExp(r'^BV[0-9A-Za-z]{10}$').hasMatch(id)) {
        continue;
      }
      result.add(
        Track(
          id: 'bilivideo_$id',
          title: title,
          artist: original.artist,
          album: '',
          duration: _duration(row['duration']),
          audioAsset: id,
          coverAsset: '',
          lyricsAsset: '',
          source: TrackSource.netease,
        ),
      );
    }
    return result;
  }

  @override
  Future<Track?> resolve(Track candidate) async {
    final id = candidate.audioAsset;
    final view = await _get(
      await _signed('/x/web-interface/wbi/view', {'bvid': id}),
      visitor: true,
    );
    final data = _object(view['data']);
    if (view['code'] != 0 || _number(data['cid']) <= 0) return null;
    final actualTitle = bilibiliRecordingTitle(
      '${data['title'] ?? ''}',
      candidate,
    );
    if (actualTitle == null ||
        normalizeRecordingText(actualTitle) !=
            normalizeRecordingText(candidate.title)) {
      return null;
    }
    // Search results can be stale. Recheck the actual first part's duration.
    if (_duration(data['duration']) <= Duration.zero ||
        (_duration(data['duration']) - candidate.duration).inSeconds.abs() >
            2) {
      return null;
    }
    final body = await _get(
      await _signed('/x/player/wbi/playurl', {
        'bvid': id,
        'cid': '${data['cid']}',
        'fnval': '16',
        'platform': 'pc',
      }),
      visitor: true,
    );
    final audio = _object(_object(body['data'])['dash'])['audio'];
    if (body['code'] != 0 || audio is! List) return null;
    final rows =
        audio
            .whereType<Map>()
            .where(
              (r) => '${r['mimeType'] ?? r['mime_type'] ?? ''}'.startsWith(
                'audio/',
              ),
            )
            .toList()
          ..sort(
            (a, b) =>
                _number(b['bandwidth']).compareTo(_number(a['bandwidth'])),
          );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final url = _secureUrl(row['baseUrl'] ?? row['base_url']);
    if (url.isEmpty) return null;
    // DASH bandwidth is measured bits/s. Do not call 192k AAC "320k MP3" or FLAC.
    return candidate.copyWith(
      audioAsset: url,
      audioHeaders: _biliHeaders,
      audioBitrate: _number(row['bandwidth']),
      playbackQuality: '',
      isPreview: false,
    );
  }
}
