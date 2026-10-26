import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/platform_session.dart';

abstract interface class PlatformSessionStore {
  Future<PlatformSession?> read();
  Future<void> write(PlatformSession session);
  Future<void> clear();
}

/// Separate key and repository: signing out of either account cannot clear the
/// other provider. No credentials are written to preferences, logs or exports.
class SecurePlatformSessionStore implements PlatformSessionStore {
  const SecurePlatformSessionStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const key = 'mesting_music_platform_kugou_session_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<PlatformSession?> read() async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    try {
      return PlatformSession.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(PlatformSession session) =>
      _storage.write(key: key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: key);
}
