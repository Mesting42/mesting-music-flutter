import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/persistence/app_preferences.dart';
import '../../shared/models/track.dart';
import '../auth/auth_providers.dart';
import '../auth/data/auth_repository.dart';
import 'data/library_repository.dart';
import 'data/library_sync_api.dart';

const _libraryCloudBootstrapPrefix = 'library_cloud_bootstrapped_v2_';
const _libraryCloudLastPullPrefix = 'library_cloud_last_pull_v1_';
const _libraryCloudPullCooldown = Duration(minutes: 15);

Future<void> _bootstrapAndSynchronizeLibrary({
  required AppDatabase database,
  required LibraryRepository repository,
  required String ownerId,
  required SharedPreferences preferences,
}) async {
  final marker = '$_libraryCloudBootstrapPrefix${Uri.encodeComponent(ownerId)}';
  var bootstrappedNow = false;
  if (preferences.getBool(marker) != true) {
    await database.enqueueLibraryCloudBootstrap(ownerId);
    await preferences.setBool(marker, true);
    bootstrappedNow = true;
  }
  final lastPullMillis = preferences.getInt(
    '$_libraryCloudLastPullPrefix${Uri.encodeComponent(ownerId)}',
  );
  final lastPull = lastPullMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(lastPullMillis);
  final shouldPullCloud =
      bootstrappedNow ||
      lastPull == null ||
      DateTime.now().difference(lastPull) >= _libraryCloudPullCooldown;
  final synchronized = await repository.synchronize(forcePull: shouldPullCloud);
  if (shouldPullCloud && synchronized) {
    await preferences.setInt(
      '$_libraryCloudLastPullPrefix${Uri.encodeComponent(ownerId)}',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final _localPreviewLibraryImportProvider = FutureProvider<void>((ref) async {
  const marker = 'local_preview_library_imported_v1';
  final preferences = ref.watch(sharedPreferencesProvider);
  if (preferences.getBool(marker) == true) return;
  await ref
      .watch(appDatabaseProvider)
      .importLegacyLibraryTo(localPreviewUserId);
  await preferences.setBool(marker, true);
});

final librarySyncApiProvider = Provider<LibrarySyncApi?>((ref) {
  final backend = ref.watch(authBackendKindProvider);
  if (backend == AuthBackendKind.localPreview) {
    return null;
  }
  if (backend == AuthBackendKind.customApi) {
    return CloudBaseLibrarySyncApi(
      apiBaseUrl: ref.watch(authApiBaseUrlProvider),
      actionPath: '/v1/social/actions',
      skipMediaUpload: true,
      sessionProvider: () =>
          ref.read(authControllerProvider.notifier).ensureFreshSession(),
    );
  }
  return CloudBaseLibrarySyncApi(
    environmentId: cloudBaseEnvironmentId,
    sessionProvider: () =>
        ref.read(authControllerProvider.notifier).ensureFreshSession(),
  );
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  final ownerId = user?.uid ?? legacyLibraryOwnerId;
  final database = ref.watch(appDatabaseProvider);
  if (ownerId == localPreviewUserId) {
    ref.watch(_localPreviewLibraryImportProvider);
  }
  final syncApi = user == null ? null : ref.watch(librarySyncApiProvider);
  final repository = LibraryRepository(
    database,
    ownerId: ownerId,
    syncApi: syncApi,
  );
  ref.onDispose(repository.dispose);
  if (user != null && syncApi != null) {
    unawaited(
      _bootstrapAndSynchronizeLibrary(
        database: database,
        repository: repository,
        ownerId: ownerId,
        preferences: ref.watch(sharedPreferencesProvider),
      ),
    );
  }
  return repository;
});

final favoriteTracksProvider = StreamProvider<List<Track>>((ref) {
  if (!ref.watch(isAuthenticatedProvider)) {
    return Stream.value(const <Track>[]);
  }
  return ref.watch(libraryRepositoryProvider).watchFavorites();
});

final favoriteTrackIdsProvider = Provider<Set<String>>((ref) {
  final tracks = ref.watch(favoriteTracksProvider).value ?? const <Track>[];
  return tracks.map((track) => track.id).toSet();
});

final playlistsProvider = StreamProvider<List<UserPlaylist>>((ref) {
  if (!ref.watch(isAuthenticatedProvider)) {
    return Stream.value(const <UserPlaylist>[]);
  }
  return ref.watch(libraryRepositoryProvider).watchPlaylists();
});

final playlistProvider = FutureProvider.family<UserPlaylist?, String>((
  ref,
  id,
) {
  if (!ref.watch(isAuthenticatedProvider)) return null;
  return ref.watch(libraryRepositoryProvider).getPlaylist(id);
});

final playlistTracksProvider = StreamProvider.family<List<Track>, String>((
  ref,
  playlistId,
) {
  if (!ref.watch(isAuthenticatedProvider)) {
    return Stream.value(const <Track>[]);
  }
  return ref.watch(libraryRepositoryProvider).watchPlaylistTracks(playlistId);
});
