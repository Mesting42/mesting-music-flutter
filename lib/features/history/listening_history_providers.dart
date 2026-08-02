import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/track.dart';
import '../auth/auth_providers.dart';
import '../library/library_providers.dart';

class ListeningHistoryItem {
  const ListeningHistoryItem({
    required this.track,
    required this.completedPlayCount,
    required this.totalListened,
    required this.lastPlayedAt,
  });

  final Track track;
  final int completedPlayCount;
  final Duration totalListened;
  final DateTime lastPlayedAt;
}

final listeningRankingProvider = StreamProvider<List<ListeningHistoryItem>>((
  ref,
) {
  final ownerId = ref.watch(currentUserProvider)?.uid ?? legacyLibraryOwnerId;
  return ref
      .watch(appDatabaseProvider)
      .watchListeningRanking(ownerId)
      .map(_decodeHistory);
});

final recentPlaybackProvider = StreamProvider<List<ListeningHistoryItem>>((
  ref,
) {
  final ownerId = ref.watch(currentUserProvider)?.uid ?? legacyLibraryOwnerId;
  return ref
      .watch(appDatabaseProvider)
      .watchPlaybackHistory(ownerId)
      .map(_decodeHistory);
});

List<ListeningHistoryItem> _decodeHistory(Iterable<PlaybackHistory> rows) {
  final result = <ListeningHistoryItem>[];
  for (final row in rows) {
    try {
      final snapshot = jsonDecode(row.trackSnapshot);
      if (snapshot is! Map<String, dynamic>) continue;
      result.add(
        ListeningHistoryItem(
          track: Track.fromJson(snapshot.cast<String, Object?>()),
          completedPlayCount: row.completedPlayCount,
          totalListened: Duration(milliseconds: row.totalPlayedMs),
          lastPlayedAt: row.lastPlayedAt,
        ),
      );
    } on Object {
      // Keep one obsolete snapshot from hiding the rest of the history.
    }
  }
  return List<ListeningHistoryItem>.unmodifiable(result);
}
