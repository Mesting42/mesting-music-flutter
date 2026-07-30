import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/core/database/app_database.dart';
import 'package:mesting_music/features/library/data/demo_library.dart';

void main() {
  final skipNativeDatabase = Platform.isWindows
      ? 'Windows 测试进程的系统 SQLite 过旧；数据库在 Android 集成测试中验证。'
      : false;

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('favorite state is persisted and removable', () async {
    final track = demoTracks.first;

    expect(await database.isFavorite(track.id), isFalse);
    await database.setFavorite(track, favorite: true);
    expect(await database.isFavorite(track.id), isTrue);
    expect((await database.watchFavorites().first).single.trackId, track.id);

    await database.setFavorite(track, favorite: false);
    expect(await database.isFavorite(track.id), isFalse);
  }, skip: skipNativeDatabase);

  test('playlist keeps snapshots and supports ordering', () async {
    await database.createPlaylist(id: 'road-trip', name: '公路歌单');
    await database.addTrackToPlaylist('road-trip', demoTracks[0]);
    await database.addTrackToPlaylist('road-trip', demoTracks[1]);

    var rows = await database.watchPlaylistTracks('road-trip').first;
    expect(rows.map((row) => row.trackId), [
      demoTracks[0].id,
      demoTracks[1].id,
    ]);

    await database.reorderPlaylistTracks('road-trip', [
      demoTracks[1].id,
      demoTracks[0].id,
    ]);
    rows = await database.watchPlaylistTracks('road-trip').first;
    expect(rows.map((row) => row.trackId), [
      demoTracks[1].id,
      demoTracks[0].id,
    ]);

    await database.removeTrackFromPlaylist('road-trip', demoTracks[1].id);
    rows = await database.watchPlaylistTracks('road-trip').first;
    expect(rows.single.trackId, demoTracks[0].id);
  }, skip: skipNativeDatabase);

  test('playback session restores queue, position and mode', () async {
    await database.savePlaybackSession(
      queue: demoTracks,
      currentIndex: 3,
      position: const Duration(seconds: 42),
      playbackMode: 'random',
    );

    final session = await database.loadPlaybackSession();
    expect(session, isNotNull);
    expect(session!.currentIndex, 3);
    expect(session.positionMs, 42000);
    expect(session.playbackMode, 'random');
  }, skip: skipNativeDatabase);
}
