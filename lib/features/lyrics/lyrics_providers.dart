import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/lyrics_repository.dart';
import 'domain/lyrics_document.dart';
import '../search/data/online_music_config.dart';
import '../search/search_providers.dart';

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  return LyricsRepository(
    client: ref.watch(musicSearchHttpClientProvider),
    kugouApiBaseUrl: OnlineMusicConfig.kugouApiBaseUrl,
    neteaseApiBaseUrl: OnlineMusicConfig.neteaseApiBaseUrl,
  );
});

final lyricsProvider = FutureProvider.family<LyricsDocument, String>((
  ref,
  path,
) {
  return ref.watch(lyricsRepositoryProvider).loadAsset(path);
});
