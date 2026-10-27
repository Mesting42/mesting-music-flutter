import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/platform_explore.dart';
import 'music_platform_providers.dart';

/// Shared catalogues for Home and Search. Providers belong to the data boundary,
/// so a presentation route never has to import another page to fetch its data.
final platformExploreRepositoryProvider = Provider<PlatformExploreRepository>(
  (ref) => PlatformExploreRepository(ref.watch(musicPlatformApiProvider)),
);

final platformExploreProvider =
    FutureProvider.family<List<PlatformExploreItem>, PlatformExploreKind>((
      ref,
      kind,
    ) async {
      await ref.watch(platformAccountProvider.future);
      return ref.watch(platformExploreRepositoryProvider).list(kind);
    });
