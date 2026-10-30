import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/security/avatar_image_validator.dart';
import '../../core/diagnostics/local_music_diagnostics.dart';
import '../utils/media_uri.dart';

typedef PersistentNetworkImageDirectoryProvider = Future<Directory> Function();

/// Keeps validated remote images in the app-private storage directory.
///
/// [cacheKey] identifies the logical image owner (for example a social user),
/// while the URL path distinguishes avatar replacements. Volatile URL query
/// parameters, such as download signatures, deliberately do not create a
/// second cache entry for the same image.
class PersistentNetworkImageCache {
  PersistentNetworkImageCache({
    http.Client? client,
    PersistentNetworkImageDirectoryProvider? directoryProvider,
    Duration requestTimeout = const Duration(seconds: 18),
  }) : _client = client ?? http.Client(),
       _directoryProvider = directoryProvider ?? getApplicationSupportDirectory,
       _requestTimeout = requestTimeout;

  static const _directoryName = 'mesting_network_image_cache';

  final http.Client _client;
  final PersistentNetworkImageDirectoryProvider _directoryProvider;
  final Duration _requestTimeout;
  final Map<String, File> _memoryFiles = <String, File>{};
  final Map<String, Future<File?>> _pendingLoads = <String, Future<File?>>{};

  /// Returns an already-resolved file without waiting for disk I/O.
  File? peek({required String cacheKey, required String url}) {
    final key = _cacheFileKey(cacheKey: cacheKey, url: url);
    if (key == null) return null;
    final file = _memoryFiles[key];
    if (file == null) return null;
    if (file.existsSync()) return file;
    _memoryFiles.remove(key);
    return null;
  }

  /// Reads a cached image first, downloading and validating it only on a miss.
  Future<File?> resolve({required String cacheKey, required String url}) {
    final key = _cacheFileKey(cacheKey: cacheKey, url: url);
    if (key == null) return Future<File?>.value();
    final memoryFile = peek(cacheKey: cacheKey, url: url);
    if (memoryFile != null) return Future<File?>.value(memoryFile);

    final pending = _pendingLoads[key];
    if (pending != null) return pending;

    final load = _load(cacheKey: key, url: url);
    _pendingLoads[key] = load;
    unawaited(load.whenComplete(() => _pendingLoads.remove(key)));
    return load;
  }

  /// Removes a broken cache entry so a later retry can fetch a clean image.
  Future<void> invalidate({
    required String cacheKey,
    required String url,
  }) async {
    final key = _cacheFileKey(cacheKey: cacheKey, url: url);
    if (key == null) return;
    _memoryFiles.remove(key);
    try {
      final file = await _cacheFile(key);
      if (await file.exists()) await file.delete();
    } on Object {
      // A cache cleanup failure must never prevent an avatar retry.
    }
  }

  Future<File?> _load({required String cacheKey, required String url}) async {
    File? temporary;
    try {
      final target = await _cacheFile(cacheKey);
      if (await target.exists()) {
        if (await target.length() > 0) {
          try {
            await validateAvatarImage(target.path);
            _memoryFiles[cacheKey] = target;
            LocalMusicDiagnostics.record(
              'artwork.disk_hit',
              LocalMusicDiagnostics.artwork(url),
            );
            return target;
          } on AvatarValidationException {
            // Older caches only checked nonzero length. A cached HTML/error
            // response must be replaced, rather than passed back forever.
          }
        }
        await target.delete();
      }

      final uri = Uri.tryParse(url.trim());
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return null;
      }
      final response = await _client
          .get(uri, headers: artworkRequestHeaders(url))
          .timeout(_requestTimeout);
      LocalMusicDiagnostics.record('artwork.http', {
        ...LocalMusicDiagnostics.artwork(url),
        'status': response.statusCode,
        'bytes': response.bodyBytes.length,
      });
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.bodyBytes.isEmpty ||
          response.bodyBytes.length > maxAvatarBytes) {
        return null;
      }

      temporary = File(
        '${target.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
      );
      await temporary.writeAsBytes(response.bodyBytes, flush: true);
      await validateAvatarImage(temporary.path);
      await temporary.rename(target.path);
      temporary = null;
      _memoryFiles[cacheKey] = target;
      return target;
    } on Object catch (error) {
      LocalMusicDiagnostics.record('artwork.cache_failed', {
        ...LocalMusicDiagnostics.artwork(url),
        'type': error.runtimeType.toString(),
      });
      return null;
    } finally {
      if (temporary != null) {
        try {
          if (await temporary.exists()) await temporary.delete();
        } on Object {
          // A failed temporary-cache cleanup is harmless and remains private.
        }
      }
    }
  }

  Future<File> _cacheFile(String key) async {
    final root = await _directoryProvider();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}$_directoryName',
    );
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$key.avatar');
  }

  String? _cacheFileKey({required String cacheKey, required String url}) {
    final owner = cacheKey.trim();
    final stableUrl = _stableUrl(url);
    if (owner.isEmpty || stableUrl == null) return null;
    return sha256.convert(utf8.encode('$owner\n$stableUrl')).toString();
  }

  String? _stableUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    // CDN thumbnails of different sizes are different images. Keep only this
    // stable size field; expiring signatures still do not multiply cache rows.
    return uri
        .replace(
          query: uri.queryParameters['param'] == null
              ? ''
              : Uri(
                  queryParameters: {'param': uri.queryParameters['param']!},
                ).query,
          fragment: '',
        )
        .toString();
  }
}

final persistentNetworkImageCache = PersistentNetworkImageCache();
