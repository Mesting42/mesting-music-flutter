import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'data/embedded_music_server.dart';
import 'data/music_platform_api.dart';
import 'data/platform_session_store.dart';
import 'domain/platform_session.dart';

final musicServerProvider = Provider<MusicServer>(
  (ref) => EmbeddedMusicServer(),
);
final platformSessionStoreProvider = Provider<PlatformSessionStore>(
  (ref) => const SecurePlatformSessionStore(),
);
final musicPlatformApiProvider = Provider<MusicPlatformApi>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return MusicPlatformApi(
    server: ref.watch(musicServerProvider),
    client: client,
  );
});

final platformAccountProvider =
    AsyncNotifierProvider<PlatformAccountController, PlatformSession?>(
      PlatformAccountController.new,
    );

/// A separate controller deliberately never reads authControllerProvider.
/// Storage operations run in order so a slow login write cannot resurrect a
/// credential after a later logout has already removed it.
class PlatformAccountController extends AsyncNotifier<PlatformSession?> {
  Future<void> _pendingMutation = Future<void>.value();

  Future<void> _serialize(Future<void> Function() operation) {
    final result = _pendingMutation.then((_) => operation());
    // Failure must reach the caller, while releasing the queue for retries.
    _pendingMutation = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  @override
  Future<PlatformSession?> build() async {
    final session = await ref.watch(platformSessionStoreProvider).read();
    ref.read(musicPlatformApiProvider).session = session;
    return session;
  }

  Future<void> accept(Map<String, dynamic> result) => _serialize(() async {
    // Initialization must settle before a fresh login may replace its state.
    await future;
    final session = PlatformSession.fromJson(result);
    await ref.read(platformSessionStoreProvider).write(session);
    ref.read(musicPlatformApiProvider).session = session;
    state = AsyncData(session);
  });

  Future<void> signOut() => _serialize(() async {
    await future;
    // Remove the credential before publishing guest state; failure remains
    // visible so the UI never falsely promises the credential was removed.
    await ref.read(platformSessionStoreProvider).clear();
    ref.read(musicPlatformApiProvider).session = null;
    state = const AsyncData(null);
  });
}

enum PlatformLoginMethod { kugouQr, phone, wechatQr, qqQr }

class PlatformQrChallenge {
  const PlatformQrChallenge({
    required this.method,
    required this.parameters,
    required this.imageBase64,
  });
  final PlatformLoginMethod method;
  final Map<String, String> parameters;
  final String imageBase64;
}

/// Stateless login protocol adapter. The page owns cancellation/generation,
/// while only PlatformAccountController is allowed to persist credentials.
class PlatformLoginService {
  PlatformLoginService(this.api);
  final MusicPlatformApi api;

  Future<PlatformQrChallenge> createQr(PlatformLoginMethod method) async {
    switch (method) {
      case PlatformLoginMethod.kugouQr:
        final keyResult = await api.get('/login/qr/key');
        final key = MusicPlatformApi.objectMap(keyResult['data'])['qrcode'];
        if (key == null || '$key'.isEmpty) {
          throw const MusicPlatformException('无法生成酷狗二维码，请重试');
        }
        final result = await api.get(
          '/login/qr/create',
          query: {'key': '$key', 'qrimg': 'true'},
        );
        final image = MusicPlatformApi.objectMap(result['data'])['base64'];
        return _challenge(method, {'key': '$key'}, image);
      case PlatformLoginMethod.wechatQr:
        final result = await api.get('/login/wx/create');
        final image = MusicPlatformApi.objectMap(
          result['qrcode'],
        )['qrcodebase64'];
        final uuid = '${result['uuid'] ?? ''}';
        if (uuid.isEmpty) throw const MusicPlatformException('微信二维码会话缺失');
        return _challenge(method, {'uuid': uuid}, image);
      case PlatformLoginMethod.qqQr:
        final result = await api.get('/login/qq/qr/create');
        const fields = [
          'qrsig',
          'ptqrtoken',
          'pt_login_sig',
          'pt_openlogin_data',
          'xlogin_url',
          'cookie',
        ];
        final parameters = <String, String>{};
        for (final field in fields) {
          final value = '${result[field] ?? ''}';
          if (value.isEmpty) throw const MusicPlatformException('QQ 二维码会话缺失');
          parameters[field] = value;
        }
        return _challenge(method, parameters, result['qrcode']);
      case PlatformLoginMethod.phone:
        throw ArgumentError('Phone login does not use a QR challenge');
    }
  }

  PlatformQrChallenge _challenge(
    PlatformLoginMethod method,
    Map<String, String> parameters,
    Object? image,
  ) {
    final value = '${image ?? ''}'.split(',').last;
    if (value.isEmpty) throw const MusicPlatformException('二维码图片暂时不可用，请刷新');
    try {
      base64Decode(value);
    } on FormatException {
      throw const MusicPlatformException('二维码图片格式异常，请刷新');
    }
    return PlatformQrChallenge(
      method: method,
      parameters: parameters,
      imageBase64: value,
    );
  }

  /// Returns a credential only after the platform reports completed login.
  /// Pending scans return null; terminal states stop polling with a safe error.
  Future<Map<String, dynamic>?> poll(PlatformQrChallenge challenge) async {
    final path = switch (challenge.method) {
      PlatformLoginMethod.kugouQr => '/login/qr/check',
      PlatformLoginMethod.wechatQr => '/login/wx/check',
      PlatformLoginMethod.qqQr => '/login/qq/qr/check',
      PlatformLoginMethod.phone => throw StateError('No QR session'),
    };
    var result = await api.get(
      path,
      query: {
        ...challenge.parameters,
        'timestamp': '${DateTime.now().millisecondsSinceEpoch}',
      },
      allowBusinessError: true,
    );
    var data = MusicPlatformApi.objectMap(result['data'] ?? result);
    if (challenge.method == PlatformLoginMethod.wechatQr) {
      final code = '${result['wx_errcode'] ?? ''}';
      if (code == '405') {
        final wxCode = '${result['wx_code'] ?? ''}';
        if (wxCode.isEmpty) throw const MusicPlatformException('微信授权信息缺失，请重试');
        result = await api.get('/login/openplat', query: {'code': wxCode});
        data = MusicPlatformApi.objectMap(result['data']);
      } else if (code == '402' || code == '403') {
        throw const MusicPlatformException('二维码已过期或授权已取消，请刷新');
      } else if (code == '408' || code == '404') {
        return null;
      } else {
        throw const MusicPlatformException('微信扫码状态异常，请刷新重试');
      }
    }
    if (challenge.method == PlatformLoginMethod.kugouQr) {
      final status = '${data['status'] ?? ''}';
      if (status == '800' || status == '0') {
        throw const MusicPlatformException('二维码已过期，请刷新');
      }
      if (status != '4') return null;
    }
    if (data['token'] != null &&
        data['userid'] != null &&
        (challenge.method != PlatformLoginMethod.qqQr ||
            '${result['status']}' == '1')) {
      return data;
    }
    if (challenge.method == PlatformLoginMethod.qqQr) {
      final code = '${result['code'] ?? result['ptui_code'] ?? ''}';
      // The Rust adapter uses string statuses for pending and terminal scans.
      // Stop on expiry/rejection instead of polling a dead session for minutes.
      final status = '${result['status'] ?? ''}';
      if (code == '65' ||
          status == 'expired' ||
          status == 'blocked' ||
          result['error'] != null) {
        throw const MusicPlatformException('QQ 扫码未能完成，请刷新或选择其他登录方式');
      }
    }
    return null;
  }

  Future<void> sendCode(String phone) async {
    final result = await api.get('/captcha/sent', query: {'mobile': phone});
    if ('${result['status']}' != '1') {
      throw const MusicPlatformException('验证码未发送成功，请稍后重试');
    }
  }

  Future<Map<String, dynamic>> phoneLogin(
    String phone,
    String code, {
    String? userId,
  }) => api.get(
    '/login/cellphone',
    query: {'mobile': phone, 'code': code, 'userid': ?userId},
    allowBusinessError: true,
  );
}
