import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/platform_profile_repository.dart';
import 'domain/platform_session.dart';
import 'domain/platform_regions.dart';
import 'music_platform_providers.dart';
import 'domain/platform_profile.dart';
export 'domain/platform_profile.dart';

final platformProfileRepositoryProvider = Provider<PlatformProfileRepository>(
  (ref) => PlatformProfileRepository(ref.watch(musicPlatformApiProvider)),
);
final platformEditableProfileProvider = FutureProvider.autoDispose
    .family<PlatformProfileInfo, PlatformSession>(
      (ref, session) =>
          ref.watch(platformProfileRepositoryProvider).fetch(session),
    );
final musicRegionsProvider = FutureProvider<List<MusicRegion>>(
  (ref) => loadMusicRegions(),
);

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
    return PlatformProfileInfo.fromJson(payload, session);
  } catch (_) {
    return fallback;
  }
});
