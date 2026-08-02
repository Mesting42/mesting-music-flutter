import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../domain/lrc_parser.dart';
import '../domain/lyrics_document.dart';

class LyricsRepository {
  LyricsRepository({
    required http.Client client,
    required String kugouApiBaseUrl,
    required String neteaseApiBaseUrl,
    String kugouPublicLyricsBaseUrl = 'https://lyrics.kugou.com',
    LrcParser parser = const LrcParser(),
  }) : _client = client,
       _kugouApiBaseUrl = _normalizeBaseUrl(kugouApiBaseUrl),
       _neteaseApiBaseUrl = _normalizeBaseUrl(neteaseApiBaseUrl),
       _kugouPublicLyricsBaseUrl = _normalizeBaseUrl(kugouPublicLyricsBaseUrl),
       _parser = parser;

  final http.Client _client;
  final String _kugouApiBaseUrl;
  final String _neteaseApiBaseUrl;
  final String _kugouPublicLyricsBaseUrl;
  final LrcParser _parser;
  final Map<String, LyricsDocument> _cache = {};

  Future<LyricsDocument> loadAsset(String assetPath) async {
    if (assetPath.trim().isEmpty) {
      return const LyricsDocument(lines: [], isSynced: false);
    }
    final cached = _cache[assetPath];
    if (cached != null) return cached;
    final uri = Uri.tryParse(assetPath);
    final source = uri?.scheme == 'mesting-lyrics'
        ? await _loadRemoteLyrics(uri!)
        : await rootBundle.loadString(assetPath);
    final document = _parser.parse(source);
    _cache[assetPath] = document;
    return document;
  }

  Future<String> _loadRemoteLyrics(Uri locator) {
    return switch (locator.host) {
      'kugou' => _loadKugouLyrics(locator),
      'netease' => _loadNeteaseLyrics(locator),
      _ => throw LyricsUnavailableException('未知歌词来源：${locator.host}'),
    };
  }

  Future<String> _loadKugouLyrics(Uri locator) async {
    final hash = locator.pathSegments.firstOrNull ?? '';
    if (hash.isEmpty) {
      throw const LyricsUnavailableException('酷狗歌词参数不完整');
    }

    if (_kugouApiBaseUrl.isNotEmpty) {
      try {
        return await _loadKugouLyricsFromHostedApi(locator, hash);
      } on LyricsUnavailableException {
        // The public lyrics service keeps online lyrics usable when a private
        // deployment is missing or temporarily unavailable.
      }
    }

    return _loadKugouLyricsFromPublicApi(locator, hash);
  }

  Future<String> _loadKugouLyricsFromHostedApi(Uri locator, String hash) async {
    final search = await _getJson(
      _endpoint(_kugouApiBaseUrl, '/search/lyric', {
        'hash': hash,
        'album_audio_id': locator.queryParameters['albumAudioId'] ?? '0',
        'duration': locator.queryParameters['durationMs'] ?? '0',
        'man': 'no',
      }),
    );
    final candidates = search['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const LyricsUnavailableException('酷狗暂未提供这首歌的歌词');
    }
    final candidate = _asMap(candidates.first);
    final lyricId = candidate?['id']?.toString() ?? '';
    final accessKey = candidate?['accesskey']?.toString() ?? '';
    if (lyricId.isEmpty || accessKey.isEmpty) {
      throw const LyricsUnavailableException('酷狗歌词参数不完整');
    }

    final lyric = await _getJson(
      _endpoint(_kugouApiBaseUrl, '/lyric', {
        'id': lyricId,
        'accesskey': accessKey,
        'fmt': 'lrc',
        'decode': 'true',
      }),
    );
    final decoded = lyric['decodeContent']?.toString() ?? '';
    if (decoded.trim().isNotEmpty) return decoded;
    final encoded = lyric['content']?.toString() ?? '';
    if (encoded.isNotEmpty) {
      try {
        return utf8.decode(base64Decode(encoded));
      } on FormatException {
        // Continue to the user-facing unavailable state below.
      }
    }
    throw const LyricsUnavailableException('酷狗暂未提供可读取的歌词');
  }

  Future<String> _loadKugouLyricsFromPublicApi(Uri locator, String hash) async {
    final search = await _getJson(
      _endpoint(_kugouPublicLyricsBaseUrl, '/search', {
        'ver': '1',
        'man': 'no',
        'client': 'pc',
        'keyword': '',
        'duration': locator.queryParameters['durationMs'] ?? '0',
        'hash': hash,
      }),
    );
    final candidates = search['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const LyricsUnavailableException('酷狗暂未提供这首歌的歌词');
    }
    final candidate = _asMap(candidates.first);
    final lyricId = candidate?['id']?.toString() ?? '';
    final accessKey = candidate?['accesskey']?.toString() ?? '';
    if (lyricId.isEmpty || accessKey.isEmpty) {
      throw const LyricsUnavailableException('酷狗歌词参数不完整');
    }

    final lyric = await _getJson(
      _endpoint(_kugouPublicLyricsBaseUrl, '/download', {
        'ver': '1',
        'client': 'pc',
        'id': lyricId,
        'accesskey': accessKey,
        'fmt': 'lrc',
        'charset': 'utf8',
      }),
    );
    return _decodeKugouLyrics(lyric);
  }

  static String _decodeKugouLyrics(Map<String, Object?> lyric) {
    final decoded = lyric['decodeContent']?.toString() ?? '';
    if (decoded.trim().isNotEmpty) return decoded;
    final encoded = lyric['content']?.toString() ?? '';
    if (encoded.isNotEmpty) {
      try {
        return utf8.decode(base64Decode(encoded));
      } on FormatException {
        // Continue to the user-facing unavailable state below.
      }
    }
    throw const LyricsUnavailableException('酷狗暂未提供可读取的歌词');
  }

  Future<String> _loadNeteaseLyrics(Uri locator) async {
    if (_neteaseApiBaseUrl.isEmpty) {
      throw const LyricsUnavailableException('网易云歌词服务尚未配置');
    }
    final songId = locator.pathSegments.firstOrNull ?? '';
    if (songId.isEmpty) {
      throw const LyricsUnavailableException('网易云歌词参数不完整');
    }
    final payload = await _getJson(
      _endpoint(_neteaseApiBaseUrl, '/lyric/new', {'id': songId}),
    );
    final lrc = _asMap(payload['lrc']);
    final source = lrc?['lyric']?.toString() ?? '';
    if (source.trim().isEmpty) {
      throw const LyricsUnavailableException('网易云暂未提供这首歌的歌词');
    }
    return source;
  }

  Future<Map<String, Object?>> _getJson(Uri uri) async {
    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
    } on Object {
      throw const LyricsUnavailableException('歌词服务暂时无法连接');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const LyricsUnavailableException('歌词服务暂时无法连接');
    }
    try {
      return _asMap(jsonDecode(utf8.decode(response.bodyBytes))) ?? const {};
    } on FormatException {
      throw const LyricsUnavailableException('歌词服务返回内容异常');
    }
  }

  static Uri _endpoint(
    String baseUrl,
    String endpoint,
    Map<String, String> queryParameters,
  ) {
    final base = Uri.parse(baseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(
      path: '$basePath$endpoint',
      queryParameters: queryParameters,
    );
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static Map<String, Object?>? _asMap(Object? value) {
    if (value is! Map) return null;
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
}

class LyricsUnavailableException implements Exception {
  const LyricsUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
