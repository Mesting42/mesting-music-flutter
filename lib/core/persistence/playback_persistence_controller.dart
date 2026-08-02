import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/track.dart';
import '../../features/library/data/retired_bundled_tracks.dart';
import '../audio/mesting_audio_handler.dart';
import '../audio/playback_mode.dart';
import '../database/app_database.dart';

final playbackPersistenceControllerProvider =
    Provider<PlaybackPersistenceController>((ref) {
      throw StateError('PlaybackPersistenceController must be overridden.');
    });

class PlaybackPersistenceController with WidgetsBindingObserver {
  static const _playbackCloudSyncInterval = Duration(minutes: 10);

  PlaybackPersistenceController({
    required AppDatabase database,
    required MestingAudioHandler audioHandler,
  }) : _database = database,
       _audioHandler = audioHandler;

  final AppDatabase _database;
  final MestingAudioHandler _audioHandler;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  Timer? _saveTimer;
  Timer? _librarySyncTimer;
  String? _sampledTrackId;
  Duration _sampledPosition = Duration.zero;
  bool _saving = false;
  bool _started = false;
  bool _switchingOwner = false;
  String? _ownerId;
  Future<void> _ownerSwitch = Future<void>.value();
  Future<bool> Function(String ownerId)? _librarySynchronizer;

  void configureLibrarySynchronizer(
    Future<bool> Function(String ownerId) synchronizer,
  ) {
    _librarySynchronizer = synchronizer;
  }

  Future<void> activateOwner(String ownerId) {
    final normalizedOwnerId = ownerId.trim().isEmpty
        ? legacyLibraryOwnerId
        : ownerId.trim();
    final operation = _ownerSwitch.then(
      (_) => _activateOwner(normalizedOwnerId),
    );
    _ownerSwitch = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _activateOwner(String ownerId) async {
    if (_ownerId == ownerId) return;
    _switchingOwner = true;
    final previousOwnerId = _ownerId;
    try {
      if (previousOwnerId != null) {
        await _sampleListeningProgress(ownerId: previousOwnerId);
        await _saveSnapshot(previousOwnerId);
      }
      _ownerId = ownerId;
      _sampledTrackId = null;
      _sampledPosition = Duration.zero;
      final session = await _database.loadPlaybackSession(ownerId);
      if (session == null) {
        await _audioHandler.clearSession();
        return;
      }
      final rawQueue = jsonDecode(session.queueSnapshot) as List<Object?>;
      final restoredTracks = rawQueue
          .map((item) => Track.fromJson(item! as Map<String, Object?>))
          .toList();
      final currentId = restoredTracks.isEmpty
          ? null
          : restoredTracks[session.currentIndex.clamp(
                  0,
                  restoredTracks.length - 1,
                )]
                .id;
      final tracks = restoredTracks
          .where((track) => !isRetiredBundledTrackId(track.id))
          .toList(growable: false);
      final restoredIndex = currentId == null
          ? 0
          : tracks.indexWhere((track) => track.id == currentId);
      final mode = PlaybackMode.values.firstWhere(
        (candidate) => candidate.name == session.playbackMode,
        orElse: () => PlaybackMode.list,
      );
      if (tracks.isEmpty) {
        await _audioHandler.clearSession();
        return;
      }
      await _audioHandler.restoreSession(
        tracks: tracks,
        currentIndex: restoredIndex < 0 ? 0 : restoredIndex,
        position: restoredIndex < 0
            ? Duration.zero
            : Duration(milliseconds: session.positionMs),
        mode: mode,
      );
    } on Object {
      // A damaged or obsolete snapshot must neither stop startup nor leak the
      // previous account's current track into the newly active account.
      await _audioHandler.clearSession();
    } finally {
      _switchingOwner = false;
    }
  }

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _subscriptions.add(
      _audioHandler.mediaItem.listen((item) async {
        final id = item?.id;
        if (id != null && id != _sampledTrackId) {
          _sampledTrackId = id;
          _sampledPosition = _audioHandler.currentPosition;
        }
        await saveNow();
      }),
    );
    _subscriptions.add(
      _audioHandler.consumedTrackStream.listen((track) async {
        final ownerId = _ownerId;
        if (ownerId == null || _switchingOwner) return;
        await _database.recordPlayback(ownerId, track, Duration.zero);
        _synchronizeLibrary(ownerId);
      }),
    );
    _subscriptions.add(
      _audioHandler.completedTrackStream.listen((track) async {
        final ownerId = _ownerId;
        if (ownerId == null || _switchingOwner) return;
        await _sampleListeningProgress(ownerId: ownerId);
        await _database.recordCompletedPlayback(ownerId, track);
        _synchronizeLibrary(ownerId);
      }),
    );
    _subscriptions.add(
      _audioHandler.playbackModeStream.listen((_) => saveNow()),
    );
    _subscriptions.add(
      _audioHandler.playbackState.listen((state) {
        if (!state.playing) {
          final ownerId = _ownerId;
          if (ownerId != null && !_switchingOwner) {
            _sampleListeningProgress(ownerId: ownerId);
          }
          saveNow();
        }
      }),
    );
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final ownerId = _ownerId;
      if (ownerId != null && !_switchingOwner) {
        await _sampleListeningProgress(ownerId: ownerId);
      }
      await saveNow();
    });
  }

  Future<void> _sampleListeningProgress({required String ownerId}) async {
    final currentId = _audioHandler.mediaItem.value?.id;
    final currentPosition = _audioHandler.currentPosition;
    if (currentId == null) return;
    if (_sampledTrackId != currentId) {
      _sampledTrackId = currentId;
      _sampledPosition = currentPosition;
      return;
    }
    final delta = currentPosition - _sampledPosition;
    _sampledPosition = currentPosition;
    // Ignore seeks and timeline jumps. Normal playback samples are five
    // seconds apart, with a little tolerance for a busy device.
    if (delta <= Duration.zero || delta > const Duration(seconds: 12)) return;
    await _database.addPlaybackDuration(ownerId, currentId, delta);
    _synchronizeLibrary(ownerId);
  }

  void _synchronizeLibrary(String ownerId) {
    final synchronizer = _librarySynchronizer;
    if (synchronizer == null) return;
    _librarySyncTimer ??= Timer(_playbackCloudSyncInterval, () {
      _librarySyncTimer = null;
      final currentOwnerId = _ownerId;
      if (currentOwnerId != null) unawaited(synchronizer(currentOwnerId));
    });
  }

  Future<void> saveNow() async {
    final ownerId = _ownerId;
    final persistedQueue = _audioHandler.persistedQueue;
    if (_saving ||
        _switchingOwner ||
        ownerId == null ||
        persistedQueue.isEmpty) {
      return;
    }
    _saving = true;
    try {
      await _saveSnapshot(ownerId, queue: persistedQueue);
    } finally {
      _saving = false;
    }
  }

  Future<void> _saveSnapshot(String ownerId, {List<Track>? queue}) async {
    final persistedQueue = queue ?? _audioHandler.persistedQueue;
    if (persistedQueue.isEmpty) return;
    final position = _audioHandler.currentPosition;
    final playbackMode = _audioHandler.playbackMode.name;
    await _database.savePlaybackSession(
      ownerId: ownerId,
      queue: persistedQueue,
      currentIndex: 0,
      position: position,
      playbackMode: playbackMode,
    );
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
    _librarySyncTimer?.cancel();
    final ownerId = _ownerId;
    if (ownerId != null) {
      await _sampleListeningProgress(ownerId: ownerId);
    }
    await saveNow();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }
}
