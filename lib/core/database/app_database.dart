import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../shared/models/track.dart';

part 'app_database.g.dart';

class FavoriteTracks extends Table {
  TextColumn get trackId => text()();
  TextColumn get trackSnapshot => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

class UserPlaylists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get coverAsset => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class UserPlaylistTracks extends Table {
  TextColumn get playlistId =>
      text().references(UserPlaylists, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId => text()();
  TextColumn get trackSnapshot => text()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, trackId};
}

class PlaybackSessions extends Table {
  IntColumn get id => integer()();
  TextColumn get queueSnapshot => text()();
  IntColumn get currentIndex => integer()();
  IntColumn get positionMs => integer()();
  TextColumn get playbackMode => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlaybackHistories extends Table {
  TextColumn get trackId => text()();
  TextColumn get trackSnapshot => text()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get totalPlayedMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

@DriftDatabase(
  tables: [
    FavoriteTracks,
    UserPlaylists,
    UserPlaylistTracks,
    PlaybackSessions,
    PlaybackHistories,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mesting_music'));

  @override
  int get schemaVersion => 1;

  Stream<List<FavoriteTrack>> watchFavorites() {
    return (select(
      favoriteTracks,
    )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).watch();
  }

  Future<bool> isFavorite(String trackId) async {
    final row = await (select(
      favoriteTracks,
    )..where((entry) => entry.trackId.equals(trackId))).getSingleOrNull();
    return row != null;
  }

  Future<void> setFavorite(Track track, {required bool favorite}) async {
    if (!favorite) {
      await (delete(
        favoriteTracks,
      )..where((entry) => entry.trackId.equals(track.id))).go();
      return;
    }
    await into(favoriteTracks).insertOnConflictUpdate(
      FavoriteTracksCompanion.insert(
        trackId: track.id,
        trackSnapshot: jsonEncode(track.toJson()),
        createdAt: DateTime.now(),
      ),
    );
  }

  Stream<List<UserPlaylist>> watchPlaylists() {
    return (select(
      userPlaylists,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).watch();
  }

  Future<UserPlaylist?> getPlaylist(String id) {
    return (select(
      userPlaylists,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Stream<List<UserPlaylistTrack>> watchPlaylistTracks(String playlistId) {
    return (select(userPlaylistTracks)
          ..where((row) => row.playlistId.equals(playlistId))
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .watch();
  }

  Future<void> createPlaylist({
    required String id,
    required String name,
    String description = '',
    String? coverAsset,
  }) async {
    final now = DateTime.now();
    await into(userPlaylists).insert(
      UserPlaylistsCompanion.insert(
        id: id,
        name: name,
        description: Value(description),
        coverAsset: Value(coverAsset),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updatePlaylist({
    required String id,
    required String name,
    required String description,
    required String? coverAsset,
  }) async {
    await (update(userPlaylists)..where((row) => row.id.equals(id))).write(
      UserPlaylistsCompanion(
        name: Value(name),
        description: Value(description),
        coverAsset: Value(coverAsset),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deletePlaylist(String id) async {
    await transaction(() async {
      await (delete(
        userPlaylistTracks,
      )..where((row) => row.playlistId.equals(id))).go();
      await (delete(userPlaylists)..where((row) => row.id.equals(id))).go();
    });
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    final maximum = userPlaylistTracks.sortOrder.max();
    final query = selectOnly(userPlaylistTracks)
      ..addColumns([maximum])
      ..where(userPlaylistTracks.playlistId.equals(playlistId));
    final currentMaximum = await query
        .map((row) => row.read(maximum))
        .getSingle();
    await transaction(() async {
      await into(userPlaylistTracks).insertOnConflictUpdate(
        UserPlaylistTracksCompanion.insert(
          playlistId: playlistId,
          trackId: track.id,
          trackSnapshot: jsonEncode(track.toJson()),
          sortOrder: (currentMaximum ?? -1) + 1,
          addedAt: DateTime.now(),
        ),
      );
      await (update(userPlaylists)..where((row) => row.id.equals(playlistId)))
          .write(UserPlaylistsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    await (delete(userPlaylistTracks)..where(
          (row) =>
              row.playlistId.equals(playlistId) & row.trackId.equals(trackId),
        ))
        .go();
    await _normalizePlaylistOrder(playlistId);
  }

  Future<void> reorderPlaylistTracks(
    String playlistId,
    List<String> orderedTrackIds,
  ) async {
    await transaction(() async {
      for (var index = 0; index < orderedTrackIds.length; index += 1) {
        await (update(userPlaylistTracks)..where(
              (row) =>
                  row.playlistId.equals(playlistId) &
                  row.trackId.equals(orderedTrackIds[index]),
            ))
            .write(UserPlaylistTracksCompanion(sortOrder: Value(index)));
      }
      await (update(userPlaylists)..where((row) => row.id.equals(playlistId)))
          .write(UserPlaylistsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  Future<void> _normalizePlaylistOrder(String playlistId) async {
    final rows =
        await (select(userPlaylistTracks)
              ..where((row) => row.playlistId.equals(playlistId))
              ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
            .get();
    await reorderPlaylistTracks(
      playlistId,
      rows.map((row) => row.trackId).toList(),
    );
  }

  Future<void> savePlaybackSession({
    required List<Track> queue,
    required int currentIndex,
    required Duration position,
    required String playbackMode,
  }) async {
    await into(playbackSessions).insertOnConflictUpdate(
      PlaybackSessionsCompanion.insert(
        id: const Value(1),
        queueSnapshot: jsonEncode(
          queue.map((track) => track.toJson()).toList(),
        ),
        currentIndex: currentIndex,
        positionMs: position.inMilliseconds,
        playbackMode: playbackMode,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<PlaybackSession?> loadPlaybackSession() {
    return (select(
      playbackSessions,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
  }

  Future<void> recordPlayback(Track track, Duration listened) async {
    final existing = await (select(
      playbackHistories,
    )..where((row) => row.trackId.equals(track.id))).getSingleOrNull();
    await into(playbackHistories).insertOnConflictUpdate(
      PlaybackHistoriesCompanion.insert(
        trackId: track.id,
        trackSnapshot: jsonEncode(track.toJson()),
        playCount: Value((existing?.playCount ?? 0) + 1),
        totalPlayedMs: Value(
          (existing?.totalPlayedMs ?? 0) + listened.inMilliseconds,
        ),
        lastPlayedAt: DateTime.now(),
      ),
    );
  }

  Stream<List<PlaybackHistory>> watchPlaybackHistory() {
    return (select(
      playbackHistories,
    )..orderBy([(row) => OrderingTerm.desc(row.lastPlayedAt)])).watch();
  }
}
