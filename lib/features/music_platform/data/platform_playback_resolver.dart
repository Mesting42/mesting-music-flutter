import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../shared/models/track.dart';
import '../domain/platform_session.dart';
import 'music_platform_api.dart';

/// Resolves media independently of search, catalog UI and the audio engine.
/// Guest requests keep the upstream permitted-preview fallback. A membership
/// credential is never replaced with an anonymous preview after a VIP failure.
class PlatformPlaybackResolver {
  PlatformPlaybackResolver(this.api);
  final MusicPlatformApi api;
  Future<void>? _registration;

  static Map<String, dynamic> audioData(Map<String, dynamic> payload) {
    final data = payload['data'];
    return MusicPlatformApi.objectMap(
      data is List && data.isNotEmpty ? data.first : data ?? payload,
    );
  }

  static String mediaUrl(Map<String, dynamic> data) {
    final raw = data['url'] ?? data['play_url'];
    for (final candidate in raw is List ? raw : [raw]) {
      if (candidate is! String) continue;
      final uri = Uri.tryParse(candidate.trim());
      if (uri != null &&
          uri.host.isNotEmpty &&
          {'http', 'https'}.contains(uri.scheme)) {
        return uri.toString();
      }
    }
    return '';
  }

  bool _sameAccount(PlatformSession? expected) =>
      api.session?.userId == expected?.userId &&
      api.session?.token == expected?.token;

  Future<void> _register() =>
      _registration ??= api.registerDevice().whenComplete(() {
        _registration = null;
      });

  Future<Track> resolve(Track track, {Future<void>? abortTrigger}) async {
    final identity = api.session;
    final abort = Completer<void>();
    var timedOut = false;
    final timer = Timer(const Duration(seconds: 40), () {
      timedOut = true;
      if (!abort.isCompleted) abort.complete();
    });
    if (abortTrigger != null) {
      unawaited(
        abortTrigger.then((_) {
          if (!abort.isCompleted) abort.complete();
        }),
      );
    }
    var registered = false;
    final query = <String, String>{
      'hash': track.id.substring('kugou_'.length).toLowerCase(),
      'quality': '128',
    };

    Future<Map<String, dynamic>> request(
      String path, {
      bool preview = false,
    }) async {
      if (!_sameAccount(identity)) {
        throw const MusicPlatformException('账号已变化，请重新选择歌曲');
      }
      if (abort.isCompleted) throw http.RequestAbortedException();
      final payload = await api.get(
        path,
        query: {...query, if (preview) 'free_part': '1'},
        allowBusinessError: true,
        abortTrigger: abort.future,
        expectedSession: identity,
      );
      if (!_sameAccount(identity)) {
        throw const MusicPlatformException('账号已变化，请重新选择歌曲');
      }
      return payload;
    }

    Future<Map<String, dynamic>> load(
      String path, {
      bool preview = false,
    }) async {
      var payload = await request(path, preview: preview);
      final data = audioData(payload);
      final error =
          '${data['errcode'] ?? data['error_code'] ?? payload['errcode'] ?? payload['error_code'] ?? ''}';
      if (error == '20028' && !registered) {
        registered = true;
        await _register();
        payload = await request(path, preview: preview);
      }
      return audioData(payload);
    }

    Track resolved(Map<String, dynamic> data, {bool preview = false}) {
      final fail = data['fail_process'];
      final size =
          int.tryParse('${data['fileSize'] ?? data['file_size'] ?? 0}') ?? 0;
      return track.copyWith(
        audioAsset: mediaUrl(data),
        isPreview:
            preview ||
            (fail is List && fail.contains('buy')) ||
            (size > 0 && size < 200 * 1024),
        availabilityMessage: preview ? '平台提供的试听片段' : '',
      );
    }

    try {
      final vip = identity?.vipToken.isNotEmpty == true;
      if (vip) {
        final data = await load('/song/url/new');
        final fail = data['fail_process'];
        if (mediaUrl(data).isNotEmpty &&
            '${data['priv_status']}' == '1' &&
            (fail is! List || fail.isEmpty)) {
          return resolved(data);
        }
      }
      final data = await load('/song/url');
      if (mediaUrl(data).isNotEmpty) return resolved(data);
      if (!vip) {
        final preview = await load('/song/url', preview: true);
        if (mediaUrl(preview).isNotEmpty) {
          return resolved(preview, preview: true);
        }
      }
      return track.copyWith(
        audioAsset: '',
        isPreview: false,
        availabilityMessage: identity == null
            ? '平台未提供游客播放或试听地址，请登录酷狗后重试'
            : '平台暂未提供可用播放地址，请核对账号权限或稍后重试',
      );
    } on http.RequestAbortedException {
      if (timedOut) throw const MusicPlatformException('获取播放地址超时，请重试');
      rethrow;
    } finally {
      timer.cancel();
    }
  }
}
