import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/music_platform_api.dart';
import 'domain/platform_session.dart';
import 'music_platform_providers.dart';

class PlatformProfileInfo {
  const PlatformProfileInfo(this.nickname, this.avatarUrl);
  final String nickname;
  final String avatarUrl;
}

/// Profile refresh is independent of credential restoration: an unavailable
/// avatar endpoint must never undo a working login or block music playback.
final platformProfileProvider = FutureProvider<PlatformProfileInfo?>((
  ref,
) async {
  final session = await ref.watch(platformAccountProvider.future);
  if (session == null) return null;
  final fallback = PlatformProfileInfo(session.nickname, session.avatarUrl);
  try {
    final payload = await ref
        .watch(musicPlatformApiProvider)
        .get('/user/detail', expectedSession: session);
    final data = MusicPlatformApi.objectMap(payload['data'] ?? payload);
    return PlatformProfileInfo(
      '${data['nickname'] ?? data['username'] ?? data['name'] ?? session.nickname}',
      PlatformSession.picture(
        data['avatar'] ?? data['pic'] ?? data['img'] ?? session.avatarUrl,
      ),
    );
  } catch (_) {
    return fallback;
  }
});
