import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/branded_launch_screen.dart';
import 'app/mesting_music_app.dart';
import 'core/audio/mesting_audio_handler.dart';
import 'core/audio/playback_providers.dart';
import 'core/database/app_database.dart';
import 'core/persistence/app_preferences.dart';
import 'core/persistence/playback_persistence_controller.dart';
import 'core/performance/frame_timing_probe.dart';
import 'features/library/library_providers.dart';
import 'features/themes/app_brand_style.dart';
import 'features/themes/theme_controller.dart';
import 'shared/models/track.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final brandStyle = await AppBrandStyleBridge.current();
  final launchThemeMode = savedMusicThemeMode(preferences);
  await AppBrandStyleBridge.syncLaunchTheme(
    launchThemeMode,
    updateLauncher: false,
  );
  FrameTimingProbe.start();
  runApp(
    _MestingBootstrap(
      brandStyle: brandStyle,
      launchThemeMode: launchThemeMode,
      preferences: preferences,
    ),
  );
}

class _MestingBootstrap extends StatefulWidget {
  const _MestingBootstrap({
    required this.brandStyle,
    required this.launchThemeMode,
    required this.preferences,
  });

  final AppBrandStyle brandStyle;
  final ThemeMode launchThemeMode;
  final SharedPreferences preferences;

  @override
  State<_MestingBootstrap> createState() => _MestingBootstrapState();
}

class _MestingBootstrapState extends State<_MestingBootstrap> {
  late Future<_MestingDependencies> _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = _initializeDependencies();
  }

  Future<_MestingDependencies> _initializeDependencies() async {
    final stopwatch = Stopwatch()..start();
    final database = AppDatabase();
    try {
      await widget.preferences.setString(
        appBrandStylePreferenceKey,
        widget.brandStyle.id,
      );
      final audioHandler = await AudioService.init<MestingAudioHandler>(
        builder: () => MestingAudioHandler(tracks: const <Track>[]),
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
      const minimumLaunchDuration = Duration(milliseconds: 720);
      final remaining = minimumLaunchDuration - stopwatch.elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }
      final dependencies = _MestingDependencies(
        database: database,
        preferences: widget.preferences,
        audioHandler: audioHandler,
        playbackPersistence: playbackPersistence,
      );

      // Start persistence after the real app has rendered its first frame.
      // Account restoration in MestingMusicApp selects the isolated snapshot.
      // Launcher aliases are only changed by an explicit brand selection.
      // Retrying a pending alias update during cold start can make OEM
      // launchers briefly surface both the old and new icons.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        playbackPersistence.start();
      });
      return dependencies;
    } on Object {
      await database.close();
      rethrow;
    }
  }

  void _retry() {
    setState(() => _dependencies = _initializeDependencies());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MestingDependencies>(
      future: _dependencies,
      builder: (context, snapshot) {
        final dependencies = snapshot.data;
        final Widget child;
        if (dependencies == null) {
          child = MestingBrandedLaunchApp(
            key: const ValueKey('branded-launch-app'),
            brandStyle: widget.brandStyle,
            themeMode: widget.launchThemeMode,
            failed: snapshot.hasError,
            onRetry: snapshot.hasError ? _retry : null,
          );
        } else {
          child = ProviderScope(
            key: const ValueKey('mesting-music-app'),
            overrides: [
              audioHandlerProvider.overrideWithValue(dependencies.audioHandler),
              appDatabaseProvider.overrideWithValue(dependencies.database),
              sharedPreferencesProvider.overrideWithValue(
                dependencies.preferences,
              ),
              playbackPersistenceControllerProvider.overrideWithValue(
                dependencies.playbackPersistence,
              ),
            ],
            child: const MestingMusicApp(),
          );
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: child,
        );
      },
    );
  }
}

class _MestingDependencies {
  const _MestingDependencies({
    required this.database,
    required this.preferences,
    required this.audioHandler,
    required this.playbackPersistence,
  });

  final AppDatabase database;
  final SharedPreferences preferences;
  final MestingAudioHandler audioHandler;
  final PlaybackPersistenceController playbackPersistence;
}
