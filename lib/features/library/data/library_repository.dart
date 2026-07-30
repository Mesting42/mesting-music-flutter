import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../shared/models/track.dart';

class PlaylistDetail {
  const PlaylistDetail({required this.playlist, required this.tracks});

  final UserPlaylist playlist;
  final List<Track> tracks;
}

class LibraryRepository {
  LibraryRepository(this._database);

  final AppDatabase _database;

  Stream<List<Track>> watchFavorites() {
    return _database.watchFavorites().map(
      (rows) => rows.map((row) => _decodeTrack(row.trackSnapshot)).toList(),
    );
  }

  Future<bool> isFavorite(String trackId) => _database.isFavorite(trackId);

  Future<void> setFavorite(Track track, {required bool favorite}) {
    return _database.setFavorite(track, favorite: favorite);
  }

  Stream<List<UserPlaylist>> watchPlaylists() => _database.watchPlaylists();

  Future<UserPlaylist?> getPlaylist(String id) => _database.getPlaylist(id);

  Stream<List<Track>> watchPlaylistTracks(String playlistId) {
    return _database
        .watchPlaylistTracks(playlistId)
        .map(
          (rows) => rows.map((row) => _decodeTrack(row.trackSnapshot)).toList(),
        );
  }

  Future<void> createPlaylist({
    required String id,
    required String name,
    String description = '',
    String? coverAsset,
  }) {
    return _database.createPlaylist(
      id: id,
      name: name,
      description: description,
      coverAsset: coverAsset,
    );
  }

  Future<void> updatePlaylist({
    required String id,
    required String name,
    required String description,
    required String? coverAsset,
  }) {
    return _database.updatePlaylist(
      id: id,
      name: name,
      description: description,
      coverAsset: coverAsset,
    );
  }

  Future<void> deletePlaylist(String id) => _database.deletePlaylist(id);

  Future<void> addTrackToPlaylist(String playlistId, Track track) {
    return _database.addTrackToPlaylist(playlistId, track);
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) {
    return _database.removeTrackFromPlaylist(playlistId, trackId);
  }

  Future<void> reorderPlaylistTracks(String playlistId, List<String> trackIds) {
    return _database.reorderPlaylistTracks(playlistId, trackIds);
  }

  Track _decodeTrack(String snapshot) {
    return Track.fromJson(jsonDecode(snapshot) as Map<String, Object?>);
  }
}
