import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/mesting_music_app.dart';
import 'core/audio/mesting_audio_handler.dart';
import 'core/audio/playback_providers.dart';
import 'core/database/app_database.dart';
import 'core/persistence/app_preferences.dart';
import 'core/persistence/playback_persistence_controller.dart';
import 'features/library/data/demo_library.dart';
import 'features/library/library_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final preferences = await SharedPreferences.getInstance();

  final audioHandler = await AudioService.init(
    builder: () => MestingAudioHandler(tracks: demoTracks),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mesting.music.playback',
      androidNotificationChannelName: 'Mesting 音乐播放',
      androidNotificationChannelDescription: '显示正在播放的歌曲与媒体控制',
      androidStopForegroundOnPause: false,
    ),
  );

  final playbackPersistence = PlaybackPersistenceController(
    database: database,
    audioHandler: audioHandler,
  );
  await playbackPersistence.restore();
  playbackPersistence.start();

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        appDatabaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MestingMusicApp(),
    ),
  );
}
