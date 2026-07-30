import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/track.dart';
import 'data/library_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(appDatabaseProvider));
});

final favoriteTracksProvider = StreamProvider<List<Track>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchFavorites();
});

final favoriteTrackIdsProvider = Provider<Set<String>>((ref) {
  final tracks = ref.watch(favoriteTracksProvider).value ?? const <Track>[];
  return tracks.map((track) => track.id).toSet();
});

final playlistsProvider = StreamProvider<List<UserPlaylist>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchPlaylists();
});

final playlistProvider = FutureProvider.family<UserPlaylist?, String>((
  ref,
  id,
) {
  return ref.watch(libraryRepositoryProvider).getPlaylist(id);
});

final playlistTracksProvider = StreamProvider.family<List<Track>, String>((
  ref,
  playlistId,
) {
  return ref.watch(libraryRepositoryProvider).watchPlaylistTracks(playlistId);
});
