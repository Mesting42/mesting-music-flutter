import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../shared/models/track.dart';
import '../audio/mesting_audio_handler.dart';
import '../audio/playback_mode.dart';
import '../database/app_database.dart';

class PlaybackPersistenceController with WidgetsBindingObserver {
  PlaybackPersistenceController({
    required AppDatabase database,
    required MestingAudioHandler audioHandler,
  }) : _database = database,
       _audioHandler = audioHandler;

  final AppDatabase _database;
  final MestingAudioHandler _audioHandler;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  Timer? _saveTimer;
  String? _lastRecordedTrackId;
  bool _saving = false;

  Future<void> restore() async {
    final session = await _database.loadPlaybackSession();
    if (session == null) return;
    try {
      final rawQueue = jsonDecode(session.queueSnapshot) as List<Object?>;
      final tracks = rawQueue
          .map((item) => Track.fromJson(item! as Map<String, Object?>))
          .toList();
      final mode = PlaybackMode.values.firstWhere(
        (candidate) => candidate.name == session.playbackMode,
        orElse: () => PlaybackMode.list,
      );
      await _audioHandler.restoreSession(
        tracks: tracks,
        currentIndex: session.currentIndex,
        position: Duration(milliseconds: session.positionMs),
        mode: mode,
      );
    } on Object {
      // A damaged or obsolete snapshot must never stop the app from opening.
    }
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _subscriptions.add(
      _audioHandler.mediaItem.listen((item) async {
        final id = item?.id;
        if (id != null && id != _lastRecordedTrackId) {
          _lastRecordedTrackId = id;
          final track = _audioHandler.trackForId(id);
          if (track != null) {
            await _database.recordPlayback(track, Duration.zero);
          }
        }
        await saveNow();
      }),
    );
    _subscriptions.add(
      _audioHandler.playbackModeStream.listen((_) => saveNow()),
    );
    _subscriptions.add(
      _audioHandler.playbackState.listen((state) {
        if (!state.playing) saveNow();
      }),
    );
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => saveNow());
  }

  Future<void> saveNow() async {
    if (_saving || _audioHandler.tracks.isEmpty) return;
    _saving = true;
    try {
      await _database.savePlaybackSession(
        queue: _audioHandler.tracks,
        currentIndex: _audioHandler.currentIndex,
        position: _audioHandler.currentPosition,
        playbackMode: _audioHandler.playbackMode.name,
      );
    } finally {
      _saving = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      saveNow();
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    await saveNow();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }
}
