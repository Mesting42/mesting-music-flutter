import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/lyrics_repository.dart';
import 'domain/lyrics_document.dart';

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  return LyricsRepository();
});

final lyricsProvider = FutureProvider.family<LyricsDocument, String>((
  ref,
  path,
) {
  return ref.watch(lyricsRepositoryProvider).loadAsset(path);
});
