import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/platform_session.dart';
import 'embedded_music_server.dart';

/// Adapter for md3Music's embedded Rust routes at commit a69503b.
/// Endpoint contracts come from the AGPL upstream; see third_party/md3music.
/// Pages never construct upstream URLs or handle authentication headers.
class MusicPlatformApi {
  MusicPlatformApi({required MusicServer server, required http.Client client})
    : _server = server,
      _client = client;

  final MusicServer _server;
  final http.Client _client;
  PlatformSession? session;
  String? _dfid;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> query = const {},
    bool allowBusinessError = false,
    Future<void>? abortTrigger,
    PlatformSession? expectedSession,
  }) async {
    // Enforce the boundary even if a future caller passes a malformed path.
    if (!path.startsWith('/') || path.startsWith('//') || path.contains('?')) {
      throw ArgumentError.value(path, 'path', 'Expected an absolute API path');
    }
    final base = await _server.start();
    if (base.scheme != 'http' || base.host != '127.0.0.1') {
      throw StateError('音乐接口必须使用本机回环地址');
    }
    final identity = session;
    if (expectedSession != null &&
        (identity?.userId != expectedSession.userId ||
            identity?.token != expectedSession.token)) {
      throw const MusicPlatformException('账号已变化，请返回后重新操作');
    }
    final request = http.AbortableRequest(
      'GET',
      base.replace(
        path: path,
        queryParameters: {
          ...query,
          'dfid': ?_dfid,
          // Account-specific responses must never hit another account's cache.
          if (identity != null) 't': '${DateTime.now().microsecondsSinceEpoch}',
        },
      ),
      abortTrigger: abortTrigger,
    );
    request.followRedirects = false;
    request.headers['Accept'] = 'application/json';
    request.headers['x-apicache-bypass'] = '1';
    request.headers['Cache-Control'] = 'no-cache';
    if (identity != null) {
      request.headers['Authorization'] = [
        'token=${identity.token}',
        'userid=${identity.userId}',
        if (identity.vipToken.isNotEmpty) 'vip_token=${identity.vipToken}',
      ].join(';');
    }
    try {
      final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 15)),
      ).timeout(const Duration(seconds: 15));
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('音乐平台返回了无法识别的数据');
      }
      if (!allowBusinessError &&
          (response.statusCode != 200 ||
              decoded['status']?.toString() == '0')) {
        // Raw responses/URLs can contain credentials. Never log or expose them.
        throw const MusicPlatformException('音乐平台暂时未能完成请求，请稍后重试');
      }
      if (expectedSession != null &&
          (session?.userId != expectedSession.userId ||
              session?.token != expectedSession.token)) {
        throw const MusicPlatformException('账号已变化，请返回后重新操作');
      }
      return decoded;
    } on http.RequestAbortedException {
      rethrow;
    } on TimeoutException {
      throw const MusicPlatformException('音乐平台连接超时，请重试');
    } on MusicPlatformException {
      rethrow;
    } on Object {
      throw const MusicPlatformException('暂时无法连接音乐平台，请检查网络后重试');
    }
  }

  Future<void> registerDevice() async {
    final result = await get('/register/dev');
    final data = objectMap(result['data']);
    _dfid = data['dfid']?.toString();
  }

  static Map<String, dynamic> objectMap(Object? value) => value is Map
      ? value.map((key, value) => MapEntry(key.toString(), value))
      : <String, dynamic>{};
}

class MusicPlatformException implements Exception {
  const MusicPlatformException(this.message);
  final String message;
  @override
  String toString() => message;
}
