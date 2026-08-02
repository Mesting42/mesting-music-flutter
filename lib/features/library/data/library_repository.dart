import 'dart:async';
import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../shared/models/track.dart';
import 'library_sync_api.dart';
import 'retired_bundled_tracks.dart';

class PlaylistDetail {
  const PlaylistDetail({required this.playlist, required this.tracks});

  final UserPlaylist playlist;
  final List<Track> tracks;
}

class FavoriteTrackRequiredException implements Exception {
  const FavoriteTrackRequiredException();
}

class LibraryRepository {
  static const _mutationSyncDebounce = Duration(seconds: 8);

  LibraryRepository(
    this._database, {
    required this.ownerId,
    LibrarySyncApi? syncApi,
  }) : _syncApi = syncApi;

  final AppDatabase _database;
  final String ownerId;
  final LibrarySyncApi? _syncApi;
  Future<bool>? _activeSync;
  Timer? _syncTimer;
  bool _syncAgain = false;
  bool _forcePullAgain = false;
  bool _disposed = false;
  Object? lastSyncError;

  Stream<List<Track>> watchFavorites() {
    return _database
        .watchFavorites(ownerId)
        .map(
          (rows) => rows
              .map((row) => _decodeTrack(row.trackSnapshot))
              .where((track) => !isRetiredBundledTrackId(track.id))
              .toList(),
        );
  }

  Future<bool> isFavorite(String trackId) =>
      _database.isFavorite(ownerId, trackId);

  Future<void> setFavorite(Track track, {required bool favorite}) async {
    await _database.setFavorite(ownerId, track, favorite: favorite);
    _scheduleSync();
  }

  Future<bool> toggleFavorite(Track track) async {
    final favorite = await _database.toggleFavorite(ownerId, track);
    _scheduleSync();
    return favorite;
  }

  Stream<List<UserPlaylist>> watchPlaylists() =>
      _database.watchPlaylists(ownerId);

  Future<UserPlaylist?> getPlaylist(String id) =>
      _database.getPlaylist(ownerId, id);

  Stream<List<Track>> watchPlaylistTracks(String playlistId) {
    return _database
        .watchPlaylistTracks(ownerId, playlistId)
        .map(
          (rows) => rows
              .map((row) => _decodeTrack(row.trackSnapshot))
              .where((track) => !isRetiredBundledTrackId(track.id))
              .toList(),
        );
  }

  Future<void> createPlaylist({
    required String id,
    required String name,
    String description = '',
    String? coverAsset,
    String? coverCloudId,
  }) async {
    await _database.createPlaylist(
      ownerId: ownerId,
      id: id,
      name: name,
      description: description,
      coverAsset: coverAsset,
      coverCloudId: coverCloudId,
    );
    _scheduleSync();
  }

  Future<void> updatePlaylist({
    required String id,
    required String name,
    required String description,
    required String? coverAsset,
    String? coverCloudId,
  }) async {
    await _database.updatePlaylist(
      ownerId: ownerId,
      id: id,
      name: name,
      description: description,
      coverAsset: coverAsset,
      coverCloudId: coverCloudId,
    );
    _scheduleSync();
  }

  Future<void> deletePlaylist(String id) async {
    await _database.deletePlaylist(ownerId, id);
    _scheduleSync();
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    if (!await isFavorite(track.id)) {
      throw const FavoriteTrackRequiredException();
    }
    await _database.addTrackToPlaylist(ownerId, playlistId, track);
    _scheduleSync();
  }

  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    await _database.removeTrackFromPlaylist(ownerId, playlistId, trackId);
    _scheduleSync();
  }

  Future<void> reorderPlaylistTracks(
    String playlistId,
    List<String> trackIds,
  ) async {
    await _database.reorderPlaylistTracks(ownerId, playlistId, trackIds);
    _scheduleSync();
  }

  Future<int> countLegacyFavorites() => _database.countLegacyFavorites();

  Future<void> importLegacyLibrary() async {
    await _database.importLegacyLibraryTo(ownerId);
    _scheduleSync();
  }

  Future<bool> synchronize({bool forcePull = false}) {
    if (_syncApi == null || _disposed) return Future.value(true);
    _syncTimer?.cancel();
    _syncTimer = null;
    final active = _activeSync;
    if (active != null) {
      _syncAgain = true;
      _forcePullAgain = _forcePullAgain || forcePull;
      return active;
    }
    final future = _synchronizeSafely(forcePull: forcePull);
    _activeSync = future;
    unawaited(
      future.whenComplete(() {
        if (!identical(_activeSync, future)) return;
        _activeSync = null;
        if (_syncAgain) {
          final forcePullAgain = _forcePullAgain;
          _syncAgain = false;
          _forcePullAgain = false;
          _scheduleSync(forcePull: forcePullAgain, delay: Duration.zero);
        }
      }),
    );
    return future;
  }

  Future<bool> _synchronizeSafely({required bool forcePull}) async {
    try {
      var pullCloudSnapshot = forcePull;
      while (true) {
        final mutations = await _database.pendingLibraryMutations(ownerId);
        if (mutations.isEmpty && !pullCloudSnapshot) break;
        final snapshot = await _syncApi!.synchronize(mutations);
        pullCloudSnapshot = false;
        final complete = await _database.completeLibrarySync(
          ownerId,
          acknowledgedMutationIds: mutations.map((item) => item.localId),
          snapshot: snapshot,
        );
        if (complete) break;
      }
      lastSyncError = null;
      return true;
    } on Object catch (error) {
      lastSyncError = error;
      return false;
    }
  }

  void _scheduleSync({
    bool forcePull = false,
    Duration delay = _mutationSyncDebounce,
  }) {
    if (_syncApi == null || _disposed) return;
    _syncTimer?.cancel();
    _syncTimer = Timer(delay, () {
      _syncTimer = null;
      unawaited(synchronize(forcePull: forcePull));
    });
  }

  void dispose() {
    _disposed = true;
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Track _decodeTrack(String snapshot) {
    return Track.fromJson(jsonDecode(snapshot) as Map<String, Object?>);
  }
}
