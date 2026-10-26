import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/track.dart';
import 'data/platform_catalog.dart';
import 'music_platform_providers.dart';

final platformCatalogProvider = Provider<PlatformCatalog>(
  (ref) => PlatformCatalog(ref.watch(musicPlatformApiProvider)),
);

// Await secure local restoration, never CloudBase. Providers rebuild on account
// change, so a former user's recommendations cannot survive a new login.
final platformDailyProvider = FutureProvider<List<Track>>((ref) async {
  await ref.watch(platformAccountProvider.future);
  return ref.watch(platformCatalogProvider).daily();
});
final platformNewSongsProvider = FutureProvider<List<Track>>((ref) async {
  await ref.watch(platformAccountProvider.future);
  return ref.watch(platformCatalogProvider).newSongs();
});
final platformDiscoveryProvider = FutureProvider<List<Track>>((ref) async {
  await ref.watch(platformAccountProvider.future);
  return ref.watch(platformCatalogProvider).discovery();
});
final platformFeaturedProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  await ref.watch(platformAccountProvider.future);
  return ref.watch(platformCatalogProvider).featured();
});
final platformPublicPlaylistProvider = FutureProvider.autoDispose
    .family<List<Track>, String>((ref, id) async {
      await ref.watch(platformAccountProvider.future);
      return ref.watch(platformCatalogProvider).publicPlaylist(id);
    });
