import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../shared/models/track.dart';
import 'pause_fade_controller.dart';
import 'playback_completion_gate.dart';
import 'playback_mode.dart';
import 'queue_engine.dart';

typedef RadioTrackLoader =
    Future<List<Track>> Function(Set<String> excludedTrackKeys);

class MestingAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  MestingAudioHandler({required List<Track> tracks, Random? random})
    : _libraryTracks = List.of(tracks),
      _random = random ?? Random(),
      _knownTracks = <String, Track>{
        for (final track in tracks) track.id: track,
      },
      _tracks = tracks.isEmpty ? <Track>[] : <Track>[tracks.first] {
    _pauseFadeController = PauseFadeController(
      setVolume: _player.setVolume,
      pause: _player.pause,
    );
    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object error, StackTrace stackTrace) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            playing: false,
            errorMessage: '音频播放失败：$error',
          ),
        );
        _consecutiveLoadFailures += 1;
        if (_consecutiveLoadFailures <= 4) {
          unawaited(_advancePlayback(forward: true, automatic: true));
        }
      },
    );
    _player.currentIndexStream.listen(_handleCurrentIndex);
    _player.durationStream.listen(_handleDuration);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        final completedTrack = trackForId(mediaItem.value?.id ?? '');
        if (_completionGate.takeCompletion() && completedTrack != null) {
          _completedTrackController.add(completedTrack);
        }
        unawaited(_advancePlayback(forward: true, automatic: true));
      }
    });
    _ready = _initialize();
  }

  final List<Track> _libraryTracks;
  List<Track> _playbackContextTracks = const <Track>[];
  List<Track> _onlineFallbackTracks = const <Track>[];
  List<Track> _radioFallbackTracks = const <Track>[];
  final Map<String, Track> _knownTracks;
  List<Track> _tracks;
  final AudioPlayer _player = AudioPlayer();
  final Random _random;
  final StreamController<PlaybackMode> _modeController =
      StreamController<PlaybackMode>.broadcast();
  final StreamController<List<MediaItem>> _upcomingQueueController =
      StreamController<List<MediaItem>>.broadcast();
  final StreamController<Track> _consumedTrackController =
      StreamController<Track>.broadcast();
  final StreamController<Track> _completedTrackController =
      StreamController<Track>.broadcast();
  final StreamController<String> _userCommandController =
      StreamController<String>.broadcast();
  final Map<String, Uri> _artworkUriCache = <String, Uri>{};
  final Map<String, LockCachingAudioSource> _remoteCachingSources =
      <String, LockCachingAudioSource>{};

  late final Future<void> _ready;
  late final PauseFadeController _pauseFadeController;
  PlaybackMode _mode = PlaybackMode.list;
  List<MediaItem> _upcomingMediaItems = const <MediaItem>[];
  bool _currentFavorite = false;
  bool _lyricsOverlayVisible = false;
  bool _lyricsOverlayLocked = false;
  final List<Track> _playbackHistory = <Track>[];
  bool _historyNavigation = false;
  bool _completionInFlight = false;
  _PendingAdvanceRequest? _pendingAdvanceRequest;
  final PlaybackCompletionGate _completionGate = PlaybackCompletionGate();
  int _consecutiveLoadFailures = 0;
  int _queueLoadEpoch = 0;
  int _userCommandEpoch = 0;
  Timer? _consumptionTimer;
  String? _confirmedConsumedMediaId;
  bool? _lastLoggedPlaying;
  ProcessingState? _lastLoggedProcessingState;
  bool _currentSourceFromCache = false;
  RadioTrackLoader? _radioTrackLoader;
  Future<void>? _radioLoadInFlight;
  final Set<String> _autoplaySessionTrackKeys = <String>{};
  int _radioRecommendationGeneration = 0;
  int _consecutiveRadioRefillMisses = 0;

  static const _recentFallbackWindow = 8;
  static const _radioPrefetchThreshold = 24;
  static const _radioRefillAttemptLimit = 3;
  static const _lyricsOverlayChannel = MethodChannel(
    'com.mesting.music/lyrics_overlay',
  );
  static const _maximumRadioPoolSize = 360;

  static const notificationToggleFavoriteAction = 'notificationToggleFavorite';
  static const notificationToggleLyricsAction = 'notificationToggleLyrics';

  List<Track> get tracks => List.unmodifiable(_tracks);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlaybackMode> get playbackModeStream async* {
    yield _mode;
    yield* _modeController.stream;
  }

  Stream<List<MediaItem>> get upcomingQueueStream async* {
    yield upcomingQueue;
    yield* _upcomingQueueController.stream;
  }

  /// Emits after a track has played continuously for one second. Queue restore
  /// and source preloading do not emit, so it is safe for recent-play history.
  Stream<Track> get consumedTrackStream => _consumedTrackController.stream;

  /// Emits only when the audio engine reaches the natural end of a track.
  Stream<Track> get completedTrackStream => _completedTrackController.stream;
  Stream<String> get userCommandStream => _userCommandController.stream;

  PlaybackMode get playbackMode => _mode;
  Duration get currentPosition => _player.position;
  int get currentIndex => _player.currentIndex ?? 0;
  @visibleForTesting
  int get debugAudioSourceCount => _player.sequence.length;
  @visibleForTesting
  bool get debugCurrentSourceFromCache => _currentSourceFromCache;
  @visibleForTesting
  bool get debugPauseFadeInProgress => _pauseFadeController.isFading;
  @visibleForTesting
  Future<bool> debugIsRemoteCacheComplete(String trackId) async {
    final source = _remoteCachingSources[trackId];
    if (source == null) return false;
    return (await source.cacheFile).exists();
  }

  @visibleForTesting
  Future<void> debugDispose() async {
    await _pauseFadeController.cancel();
    await _userCommandController.close();
    await _player.dispose();
  }

  List<MediaItem> get upcomingQueue =>
      List<MediaItem>.unmodifiable(_upcomingMediaItems);
  List<Track> get persistedQueue {
    final currentId = mediaItem.value?.id;
    final result = <Track>[];
    final seen = <String>{};
    if (currentId != null) {
      final current = trackForId(currentId);
      if (current != null) {
        result.add(current);
        seen.add(current.id);
      }
    }
    for (final item in _upcomingMediaItems) {
      final track = trackForId(item.id);
      if (track != null && seen.add(track.id)) result.add(track);
    }
    return List<Track>.unmodifiable(result);
  }

  Future<void> _initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _loadQueue(_tracks);
    await setPlaybackMode(_mode);
  }

  Future<bool> _loadQueue(
    List<Track> tracks, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
    bool preload = true,
    int? requiredUserCommandEpoch,
  }) async {
    final loadEpoch = ++_queueLoadEpoch;
    for (final track in tracks) {
      _knownTracks[track.id] = track;
    }
    if (tracks.isEmpty) {
      _tracks = <Track>[];
      queue.add(const <MediaItem>[]);
      _upcomingMediaItems = const <MediaItem>[];
      _publishUpcomingQueue();
      mediaItem.add(null);
      _resetConsumptionConfirmation();
      _completionGate.reset();
      await _player.setAudioSources(const []);
      _trace('load-empty');
      return true;
    }

    final safeIndex = initialIndex.clamp(0, tracks.length - 1);
    final orderedTracks = <Track>[
      tracks[safeIndex],
      ...tracks.skip(safeIndex + 1),
      ...tracks.take(safeIndex),
    ];
    final mediaItems = await Future.wait(orderedTracks.map(_mediaItemFor));
    if (loadEpoch != _queueLoadEpoch ||
        (requiredUserCommandEpoch != null &&
            requiredUserCommandEpoch != _userCommandEpoch)) {
      _trace('load-stale-before-source epoch=$loadEpoch');
      return false;
    }

    _tracks = orderedTracks;
    queue.add(mediaItems);
    _upcomingMediaItems = mediaItems.skip(1).toList(growable: false);
    mediaItem.add(mediaItems.first);
    _resetConsumptionConfirmation();
    // A restored mid-track position is intentionally ineligible. Starting at
    // the beginning through play() arms the session once playback begins.
    _completionGate.reset();
    final activeSource = await _audioSourceFor(
      orderedTracks.first,
      mediaItems.first,
    );
    if (loadEpoch != _queueLoadEpoch ||
        (requiredUserCommandEpoch != null &&
            requiredUserCommandEpoch != _userCommandEpoch)) {
      _trace('load-stale-after-source-resolution epoch=$loadEpoch');
      return false;
    }
    await _player.setAudioSources(
      <AudioSource>[activeSource],
      preload: preload,
      initialIndex: 0,
      initialPosition: initialPosition,
    );
    if (loadEpoch != _queueLoadEpoch ||
        (requiredUserCommandEpoch != null &&
            requiredUserCommandEpoch != _userCommandEpoch)) {
      _trace('load-stale-after-source epoch=$loadEpoch');
      return false;
    }
    _publishUpcomingQueue();
    _trace(
      'load-current id=${mediaItems.first.id} '
      'upcoming=${_upcomingMediaItems.length} sourceCount=${_player.sequence.length}',
    );
    return true;
  }

  Future<MediaItem> _mediaItemFor(Track track) async {
    if (track.isRemote) return track.toMediaItem();
    final cached = _artworkUriCache[track.coverAsset];
    if (cached != null) return track.toMediaItem(artUri: cached);

    try {
      final bytes = await rootBundle.load(track.coverAsset);
      final cacheDirectory = await getTemporaryDirectory();
      final artworkDirectory = Directory(
        '${cacheDirectory.path}${Platform.pathSeparator}notification_artwork',
      );
      await artworkDirectory.create(recursive: true);
      final extension = _fileExtension(track.coverAsset);
      final safeId = track.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final artworkFile = File(
        '${artworkDirectory.path}${Platform.pathSeparator}$safeId$extension',
      );
      final data = bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      );
      if (!await artworkFile.exists() ||
          await artworkFile.length() != data.length) {
        await artworkFile.writeAsBytes(data, flush: true);
      }
      final uri = artworkFile.uri;
      _artworkUriCache[track.coverAsset] = uri;
      return track.toMediaItem(artUri: uri);
    } on Object {
      // Playback should remain available even if an individual artwork asset
      // cannot be prepared for the Android media notification.
      return track.toMediaItem();
    }
  }

  String _fileExtension(String path) {
    final cleanPath = path.split('?').first;
    final dot = cleanPath.lastIndexOf('.');
    if (dot < 0 || dot < cleanPath.lastIndexOf('/')) return '.png';
    return cleanPath.substring(dot).toLowerCase();
  }

  Future<AudioSource> _audioSourceFor(Track track, MediaItem item) async {
    if (track.isRemote) {
      final cachingSource = LockCachingAudioSource(
        Uri.parse(track.audioAsset),
        tag: item,
      );
      _remoteCachingSources[track.id] = cachingSource;
      final resolved = await cachingSource.resolve();
      _currentSourceFromCache = !identical(resolved, cachingSource);
      _trace('source-remote id=${track.id} cacheHit=$_currentSourceFromCache');
      return resolved;
    }
    _currentSourceFromCache = false;
    final localUri = Uri.tryParse(track.audioAsset);
    if (localUri != null && localUri.scheme == 'file') {
      return AudioSource.uri(localUri, tag: item);
    }
    return AudioSource.asset(track.audioAsset, tag: item);
  }

  void _handleCurrentIndex(int? index) {
    final items = queue.value;
    if (index == null || index < 0 || index >= items.length) return;
    final current = items[index];
    _consecutiveLoadFailures = 0;
    mediaItem.add(current);
    final currentTrack = trackForId(current.id);
    if (!_historyNavigation &&
        currentTrack != null &&
        (_playbackHistory.isEmpty ||
            _playbackHistory.last.id != currentTrack.id)) {
      _playbackHistory.add(currentTrack);
      if (_playbackHistory.length > 100) _playbackHistory.removeAt(0);
    }
    _historyNavigation = false;
    _scheduleConsumptionConfirmation();
    _broadcastState(_player.playbackEvent);
  }

  void _resetConsumptionConfirmation() {
    _consumptionTimer?.cancel();
    _consumptionTimer = null;
    _confirmedConsumedMediaId = null;
  }

  void _scheduleConsumptionConfirmation() {
    final currentId = mediaItem.value?.id;
    if (!_player.playing ||
        currentId == null ||
        currentId == _confirmedConsumedMediaId ||
        _consumptionTimer != null) {
      if (!_player.playing) {
        _consumptionTimer?.cancel();
        _consumptionTimer = null;
      }
      return;
    }
    _consumptionTimer = Timer(const Duration(seconds: 1), () {
      _consumptionTimer = null;
      if (!_player.playing || mediaItem.value?.id != currentId) return;
      _confirmCurrentConsumed(currentId);
    });
  }

  void _confirmCurrentConsumed(String currentId) {
    if (_confirmedConsumedMediaId == currentId) return;
    _confirmedConsumedMediaId = currentId;
    final consumedTrack = trackForId(currentId);
    if (consumedTrack != null) {
      _consumedTrackController.add(consumedTrack);
    }

    final previousUpcomingLength = _upcomingMediaItems.length;
    _upcomingMediaItems = QueueEngine.withoutId(
      _upcomingMediaItems,
      currentId,
      idOf: (item) => item.id,
    );
    _tracks = QueueEngine.keepCurrentAndRemoveDuplicate(
      _tracks,
      currentId,
      idOf: (track) => track.id,
    );
    queue.add(
      QueueEngine.keepCurrentAndRemoveDuplicate(
        queue.value,
        currentId,
        idOf: (item) => item.id,
      ),
    );
    if (_upcomingMediaItems.length != previousUpcomingLength) {
      _publishUpcomingQueue();
    }
    _trace(
      'consumed id=$currentId upcoming=${_upcomingMediaItems.length} '
      'sourceCount=${_player.sequence.length}',
    );
  }

  void _publishUpcomingQueue() {
    _upcomingQueueController.add(upcomingQueue);
  }

  void _handleDuration(Duration? duration) {
    final current = mediaItem.value;
    if (current == null || duration == null || current.duration == duration) {
      return;
    }
    mediaItem.add(current.copyWith(duration: duration));
  }

  void _broadcastState(PlaybackEvent event) {
    _scheduleConsumptionConfirmation();
    if (_lastLoggedPlaying != _player.playing ||
        _lastLoggedProcessingState != _player.processingState) {
      _lastLoggedPlaying = _player.playing;
      _lastLoggedProcessingState = _player.processingState;
      _trace(
        'state playing=${_player.playing} '
        'processing=${_player.processingState.name} '
        'positionMs=${_player.position.inMilliseconds}',
      );
    }
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.custom(
            androidIcon: _currentFavorite
                ? 'drawable/ic_notification_favorite'
                : 'drawable/ic_notification_favorite_border',
            label: _currentFavorite ? '取消收藏' : '收藏',
            name: notificationToggleFavoriteAction,
          ),
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.custom(
            androidIcon: _lyricsOverlayVisible
                ? 'drawable/ic_notification_lyrics_on'
                : 'drawable/ic_notification_lyrics',
            label: _lyricsOverlayLocked
                ? '解锁桌面歌词'
                : _lyricsOverlayVisible
                ? '关闭桌面歌词'
                : '打开桌面歌词',
            name: notificationToggleLyricsAction,
          ),
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [1, 2, 3],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: mediaItem.value == null ? null : 0,
        repeatMode: switch (_mode) {
          PlaybackMode.list => AudioServiceRepeatMode.all,
          PlaybackMode.single => AudioServiceRepeatMode.one,
          PlaybackMode.random => AudioServiceRepeatMode.all,
        },
        shuffleMode: _mode == PlaybackMode.random
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  Future<void> updateNotificationExtras({
    required bool favorite,
    required bool lyricsOverlayVisible,
    required bool lyricsOverlayLocked,
  }) async {
    if (_currentFavorite == favorite &&
        _lyricsOverlayVisible == lyricsOverlayVisible &&
        _lyricsOverlayLocked == lyricsOverlayLocked) {
      return;
    }
    _currentFavorite = favorite;
    _lyricsOverlayVisible = lyricsOverlayVisible;
    _lyricsOverlayLocked = lyricsOverlayLocked;
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == notificationToggleLyricsAction) {
      final permissionRequestLaunched =
          await _requestOverlayPermissionFromNotification();
      customEvent.add(<String, Object?>{
        'action': name,
        'permissionRequestLaunched': permissionRequestLaunched,
      });
      return;
    }
    if (name == notificationToggleFavoriteAction) {
      customEvent.add(<String, Object?>{'action': name});
      return;
    }
    await super.customAction(name, extras);
  }

  Future<bool> _requestOverlayPermissionFromNotification() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _lyricsOverlayChannel.invokeMethod<bool>(
            'requestPermissionFromNotification',
          ) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> play() async {
    _markUserCommand('play');
    await _ready;
    await _pauseFadeController.cancel();
    _startPlayer();
  }

  void _startPlayer() {
    _trace('command-play id=${mediaItem.value?.id}');
    _completionGate.onPlay(_player.position);
    // just_audio deliberately completes play() only when playback completes,
    // pauses, or stops. Awaiting that Future while _advancePlayback owns its
    // command lock prevents every later next/previous request for the entire
    // duration of the newly selected track.
    unawaited(
      _player.play().onError((Object error, StackTrace stackTrace) {
        developer.log(
          'command-play-failed',
          name: 'MestingAudio',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  @override
  Future<void> pause() async {
    _markUserCommand('pause');
    await _ready;
    if (!_player.playing || _player.processingState != ProcessingState.ready) {
      await _pauseFadeController.cancel();
      _trace(
        'command-pause-immediate id=${mediaItem.value?.id} '
        'processing=${_player.processingState.name}',
      );
      await _player.pause();
      return;
    }
    _trace(
      'command-pause-fade id=${mediaItem.value?.id} '
      'durationMs=${_pauseFadeController.duration.inMilliseconds}',
    );
    await _pauseFadeController.fadeOutAndPause(_player.volume);
  }

  @override
  Future<void> stop() async {
    _markUserCommand('stop');
    await _ready;
    await _pauseFadeController.cancel();
    _resetConsumptionConfirmation();
    _trace('command-stop id=${mediaItem.value?.id}');
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    _markUserCommand('seek');
    await _ready;
    await _pauseFadeController.cancel();
    final current = _player.position;
    _completionGate.onSeek(from: current, to: position);
    await _player.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _markUserCommand('skipToQueueItem');
    await _ready;
    await _pauseFadeController.cancel();
    if (index < 0 || index >= _tracks.length) return;
    if (index == 0) {
      await _player.seek(Duration.zero);
      return;
    }
    await playSingleTrack(_tracks[index]);
  }

  @override
  Future<void> skipToNext() => _skip(forward: true);

  @override
  Future<void> skipToPrevious() => _skip(forward: false);

  Future<void> _skip({required bool forward}) async {
    _markUserCommand(forward ? 'skipNext' : 'skipPrevious');
    await _ready;
    await _pauseFadeController.cancel();
    await _advancePlayback(forward: forward);
  }

  Future<void> _advancePlayback({
    required bool forward,
    bool automatic = false,
  }) async {
    final request = _PendingAdvanceRequest(
      forward: forward,
      automatic: automatic,
    );
    if (_completionInFlight) {
      _deferAdvance(request);
      return;
    }
    _completionInFlight = true;
    var advanced = false;
    try {
      if (automatic && _mode == PlaybackMode.single) {
        await seek(Duration.zero);
        await play();
        return;
      }

      if (!forward && _playbackHistory.length > 1) {
        _playbackHistory.removeLast();
        await playSingleTrack(
          _playbackHistory.last,
          fromHistory: true,
          preservePendingAdvance: true,
        );
        advanced = true;
        return;
      }

      if (_upcomingMediaItems.isNotEmpty) {
        final targetIndex = QueueEngine.resolveUpcomingIndex(
          length: _upcomingMediaItems.length,
          mode: _mode,
          random: _random,
        );
        final target = trackForId(_upcomingMediaItems[targetIndex].id);
        if (target != null) {
          await playSingleTrack(target, preservePendingAdvance: true);
          advanced = true;
          return;
        }
      }

      final fallback = _fallbackTrack(
        avoidRecent: automatic || _mode == PlaybackMode.random,
        forward: forward,
      );
      if (fallback != null) {
        _rememberAutoplaySelection(fallback);
        await playSingleTrack(fallback, preservePendingAdvance: true);
        advanced = true;
        unawaited(_ensureRadioFallbackTracks());
        return;
      }

      if (_canDiscoverRadioFallback) {
        // Never hold the shared advance lock while online discovery runs. A
        // cold-restored session may contain only the current track, and the
        // discovery round can take several seconds. Holding the lock here
        // used to drop previous/next taps and the natural-completion request.
        _deferAdvance(request);
        if (_player.processingState == ProcessingState.completed) {
          await _player.pause();
        }
        unawaited(_ensureRadioFallbackTracks());
      } else {
        _trace(
          'advance-unavailable direction=${forward ? 'next' : 'previous'} '
          'mode=${_mode.name} upcoming=${_upcomingMediaItems.length} '
          'fallback=${_fallbackPool.length} misses=$_consecutiveRadioRefillMisses',
        );
      }
    } finally {
      _completionInFlight = false;
      if (advanced) _resumePendingAdvance();
    }
  }

  void _deferAdvance(_PendingAdvanceRequest request) {
    final pending = _pendingAdvanceRequest;
    // A deliberate previous/next tap takes precedence over an automatic
    // completion that happened while another source was being loaded.
    if (!request.automatic || pending == null) {
      _pendingAdvanceRequest = request;
    }
  }

  void _resumePendingAdvance() {
    if (_completionInFlight) return;
    final pending = _pendingAdvanceRequest;
    if (pending == null) return;
    _pendingAdvanceRequest = null;
    unawaited(
      _advancePlayback(forward: pending.forward, automatic: pending.automatic),
    );
  }

  Track? _fallbackTrack({required bool avoidRecent, required bool forward}) {
    final pool = _fallbackPool;
    if (pool.isEmpty) return null;
    final currentId = mediaItem.value?.id;
    final currentTrack = currentId == null ? null : trackForId(currentId);
    final currentKey = currentTrack == null
        ? null
        : _semanticTrackKey(currentTrack);
    if (currentTrack != null) _rememberAutoplaySelection(currentTrack);
    final unplayedPool = pool
        .where(
          (track) =>
              _semanticTrackKey(track) != currentKey &&
              !_autoplaySessionTrackKeys.contains(_semanticTrackKey(track)),
        )
        .toList(growable: false);
    // Do not immediately recycle the first discovery batch. Give the online
    // loader several rotating query rounds to expand the session catalogue;
    // only fall back to an older song when those rounds found nothing new.
    if (unplayedPool.isEmpty &&
        _radioTrackLoader != null &&
        _consecutiveRadioRefillMisses < _radioRefillAttemptLimit) {
      return null;
    }
    final candidates = unplayedPool.isEmpty ? pool : unplayedPool;
    final recentIds = _playbackHistory.reversed
        .take(_recentFallbackWindow)
        .map((track) => track.id);
    final index = QueueEngine.resolveFallbackIndex(
      candidateIds: candidates.map((track) => track.id).toList(growable: false),
      recentIds: recentIds,
      currentId: currentId,
      avoidRecent: avoidRecent,
      mode: _mode,
      forward: forward,
      // Reaching this branch means the explicit Up Next queue is empty.
      // Treat that state as Autoplay even when the visible mode is list:
      // hidden page context and a stable hot-ranking snapshot must not create
      // a deterministic sequence that always starts with the same song.
      randomize: true,
      random: _random,
    );
    return index < 0 ? null : candidates[index];
  }

  List<Track> get _fallbackPool {
    final result = <Track>[];
    final seen = <String>{};
    final candidates = _mode == PlaybackMode.random
        ? <Track>[
            ..._radioFallbackTracks,
            ..._onlineFallbackTracks,
            ..._playbackContextTracks,
            ..._knownTracks.values,
            ..._libraryTracks,
          ]
        : <Track>[
            ..._playbackContextTracks,
            ..._onlineFallbackTracks,
            ..._radioFallbackTracks,
            ..._knownTracks.values,
            ..._libraryTracks,
          ];
    for (final track in candidates) {
      if (track.isPlayable && seen.add(_semanticTrackKey(track))) {
        result.add(track);
      }
    }
    return result;
  }

  void _replacePlaybackContext(Iterable<Track> tracks) {
    final next = <Track>[];
    final seen = <String>{};
    for (final track in tracks) {
      if (!track.isPlayable || !seen.add(track.id)) continue;
      next.add(track);
      _knownTracks[track.id] = track;
    }
    _playbackContextTracks = List<Track>.unmodifiable(next);
    _trace('playback-context tracks=${next.length}');
  }

  void updateOnlineFallbackTracks(Iterable<Track> tracks) {
    final next = <Track>[];
    final seen = <String>{};
    for (final track in tracks) {
      if (!track.isRemote || !track.isPlayable || !seen.add(track.id)) continue;
      next.add(track);
      _knownTracks[track.id] = track;
    }
    _onlineFallbackTracks = List<Track>.unmodifiable(next);
    if (next.isNotEmpty) _resumePendingAdvance();
  }

  void configureRadioTrackLoader(RadioTrackLoader loader) {
    _radioTrackLoader = loader;
    unawaited(_ensureRadioFallbackTracks());
  }

  Future<void> prefetchRadioTracks({bool force = false}) =>
      _ensureRadioFallbackTracks(force: force);

  Future<void> refreshRadioRecommendations() async {
    invalidateRadioRecommendations();
    await _ensureRadioFallbackTracks(force: true);
  }

  void invalidateRadioRecommendations() {
    _radioFallbackTracks = const <Track>[];
    _consecutiveRadioRefillMisses = 0;
    _radioRecommendationGeneration += 1;
  }

  Future<void> _ensureRadioFallbackTracks({bool force = false}) async {
    final loader = _radioTrackLoader;
    if (loader == null) return;
    if (!force && _availableRadioTrackCount >= _radioPrefetchThreshold) return;
    final active = _radioLoadInFlight;
    if (active != null) return active;

    final generation = _radioRecommendationGeneration;
    late final Future<void> request;
    request = () async {
      try {
        var attempts = 0;
        while (attempts < _radioRefillAttemptLimit &&
            _availableRadioTrackCount < _radioPrefetchThreshold) {
          attempts += 1;
          final excluded = <String>{
            ..._autoplaySessionTrackKeys,
            for (final track in _radioFallbackTracks) _semanticTrackKey(track),
          };
          final currentId = mediaItem.value?.id;
          final currentTrack = currentId == null ? null : trackForId(currentId);
          if (currentTrack != null) {
            excluded.add(_semanticTrackKey(currentTrack));
          }
          final tracks = await loader(Set<String>.unmodifiable(excluded));
          if (generation != _radioRecommendationGeneration) {
            _trace('radio-refill-stale generation=$generation');
            break;
          }
          final added = _mergeRadioFallbackTracks(tracks);
          if (added == 0) {
            _consecutiveRadioRefillMisses += 1;
          } else {
            _consecutiveRadioRefillMisses = 0;
          }
        }
      } on Object catch (error) {
        _trace('radio-refill-failed error=$error');
      } finally {
        if (identical(_radioLoadInFlight, request)) {
          _radioLoadInFlight = null;
        }
        if (generation != _radioRecommendationGeneration &&
            _pendingAdvanceRequest != null) {
          unawaited(_ensureRadioFallbackTracks(force: true));
        }
        final pending = _pendingAdvanceRequest;
        if (pending != null) {
          final fallback = _fallbackTrack(
            avoidRecent: pending.automatic || _mode == PlaybackMode.random,
            forward: pending.forward,
          );
          if (fallback == null) {
            _pendingAdvanceRequest = null;
            _trace(
              'radio-refill-exhausted direction='
              '${pending.forward ? 'next' : 'previous'} '
              'mode=${_mode.name} misses=$_consecutiveRadioRefillMisses',
            );
          } else {
            _resumePendingAdvance();
          }
        }
      }
    }();
    _radioLoadInFlight = request;
    return request;
  }

  int get _availableRadioTrackCount => _radioFallbackTracks
      .where(
        (track) =>
            !_autoplaySessionTrackKeys.contains(_semanticTrackKey(track)) &&
            track.id != mediaItem.value?.id,
      )
      .length;

  bool get _canDiscoverRadioFallback => _radioTrackLoader != null;

  int _mergeRadioFallbackTracks(Iterable<Track> tracks) {
    final next = <Track>[];
    final seen = <String>{};
    final previous = <String>{
      for (final track in _radioFallbackTracks) _semanticTrackKey(track),
    };
    var added = 0;
    for (final track in <Track>[..._radioFallbackTracks, ...tracks]) {
      final key = _semanticTrackKey(track);
      if (!track.isRemote ||
          !track.isPlayable ||
          _autoplaySessionTrackKeys.contains(key) ||
          !seen.add(key)) {
        continue;
      }
      next.add(track);
      if (!previous.contains(key)) added += 1;
      _knownTracks[track.id] = track;
    }
    if (next.length > _maximumRadioPoolSize) {
      next.removeRange(0, next.length - _maximumRadioPoolSize);
    }
    _radioFallbackTracks = List<Track>.unmodifiable(next);
    _trace(
      'radio-refill pool=${next.length} added=$added '
      'available=$_availableRadioTrackCount misses=$_consecutiveRadioRefillMisses',
    );
    if (next.isNotEmpty) _resumePendingAdvance();
    return added;
  }

  void _rememberAutoplaySelection(Track track) {
    final key = _semanticTrackKey(track);
    // Keep semantic keys for the full process session. This set contains only
    // short normalized title/artist strings, while the much heavier Track
    // objects remain bounded by the rolling radio pool. Evicting these keys
    // used to make a long-running Autoplay session repeat after a fixed count.
    _autoplaySessionTrackKeys.add(key);
  }

  static String _semanticTrackKey(Track track) {
    String normalize(String value) => value
        .toLowerCase()
        .replaceAll(RegExp(r'\([^)]*\)|（[^）]*）|\[[^]]*\]'), '')
        .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]'), '');
    return '${normalize(track.title)}|${normalize(track.artist)}';
  }

  Future<void> playTrack(String id) async {
    await _ready;
    final track = trackForId(id);
    if (track == null || id == mediaItem.value?.id) return;
    await playSingleTrack(track);
  }

  Future<void> playSingleTrack(
    Track track, {
    bool autoplay = true,
    bool fromHistory = false,
    Iterable<Track>? playbackContext,
    bool preservePendingAdvance = false,
  }) async {
    _markUserCommand('playSingleTrack');
    if (!preservePendingAdvance) _pendingAdvanceRequest = null;
    if (_mode == PlaybackMode.random) _rememberAutoplaySelection(track);
    if (playbackContext != null) {
      _replacePlaybackContext(playbackContext);
    }
    _knownTracks[track.id] = track;
    await _ready;
    await _pauseFadeController.cancel();
    final pending = <Track>[];
    for (final item in _upcomingMediaItems) {
      final candidate = trackForId(item.id);
      if (candidate != null && candidate.id != track.id) pending.add(candidate);
    }
    _historyNavigation = fromHistory;
    final applied = await _loadQueue(<Track>[track, ...pending]);
    if (!applied) return;
    await setPlaybackMode(_mode);
    if (autoplay) _startPlayer();
  }

  Future<bool> appendToUpcomingQueue(Track track) async {
    _markUserCommand('appendUpcoming');
    await _ready;
    final canAppend = QueueEngine.canAppendTrack(
      candidateId: track.id,
      currentId: mediaItem.value?.id,
      upcomingIds: _upcomingMediaItems.map((item) => item.id),
    );
    if (!canAppend) return false;

    _knownTracks[track.id] = track;
    final item = await _mediaItemFor(track);
    // Consumption de-duplicates the current queue into a fixed-length list.
    // Rebuild here instead of mutating it so adding from any UI remains valid
    // after the current track has played for more than one second.
    _tracks = <Track>[..._tracks, track];
    queue.add(<MediaItem>[...queue.value, item]);
    _upcomingMediaItems = <MediaItem>[..._upcomingMediaItems, item];
    _publishUpcomingQueue();
    _broadcastState(_player.playbackEvent);
    _trace(
      'append-upcoming id=${track.id} upcoming=${_upcomingMediaItems.length} '
      'sourceCount=${_player.sequence.length}',
    );
    _resumePendingAdvance();
    return true;
  }

  Future<bool> removeFromUpcomingQueue(String id) async {
    _markUserCommand('removeUpcoming');
    await _ready;
    final pendingIndex = _upcomingMediaItems.indexWhere(
      (item) => item.id == id,
    );
    if (pendingIndex < 0 || id == mediaItem.value?.id) return false;

    _tracks = _tracks.where((track) => track.id != id).toList();
    queue.add(queue.value.where((item) => item.id != id).toList());
    _upcomingMediaItems = _upcomingMediaItems
        .where((item) => item.id != id)
        .toList(growable: false);
    _publishUpcomingQueue();
    _broadcastState(_player.playbackEvent);
    _trace(
      'remove-upcoming id=$id upcoming=${_upcomingMediaItems.length} '
      'sourceCount=${_player.sequence.length}',
    );
    return true;
  }

  /// Applies a remote "一起听" snapshot without marking it as a local user
  /// command. The current track must be the first item in [tracks].
  Future<void> applySynchronizedPlayback({
    required List<Track> tracks,
    required Duration position,
    required bool playing,
  }) async {
    if (tracks.isEmpty) return;
    _pendingAdvanceRequest = null;
    _replacePlaybackContext(tracks);
    await _ready;
    await _pauseFadeController.cancel();
    final current = tracks.first;
    final safePosition = Duration(
      milliseconds: position.inMilliseconds.clamp(
        0,
        current.duration.inMilliseconds,
      ),
    );
    final applied = await _loadQueue(
      List<Track>.unmodifiable(tracks),
      initialPosition: safePosition,
    );
    if (!applied) return;
    await setPlaybackMode(_mode);
    if (playing) {
      _startPlayer();
    } else {
      await _player.pause();
    }
    _trace(
      'together-snapshot id=${current.id} positionMs='
      '${safePosition.inMilliseconds} playing=$playing '
      'queue=${tracks.length}',
    );
  }

  Future<void> togglePlayPause() async {
    await _ready;
    if (_pauseFadeController.isFading) {
      _markUserCommand('cancelPauseFade');
      await _pauseFadeController.cancel();
      return;
    }
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> cyclePlaybackMode() => setPlaybackMode(_mode.next);

  Future<void> replaceQueue(
    List<Track> tracks, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
    bool autoplay = true,
  }) async {
    _markUserCommand('replaceQueue');
    if (tracks.isNotEmpty) {
      _replacePlaybackContext(tracks);
    }
    await _ready;
    await _pauseFadeController.cancel();
    final applied = await _loadQueue(
      tracks,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
    if (!applied) return;
    await setPlaybackMode(_mode);
    if (autoplay && tracks.isNotEmpty) _startPlayer();
  }

  Future<void> restoreSession({
    required List<Track> tracks,
    required int currentIndex,
    required Duration position,
    required PlaybackMode mode,
  }) async {
    final restoreEpoch = _userCommandEpoch;
    if (tracks.isNotEmpty) {
      _replacePlaybackContext(tracks);
    }
    await _ready;
    if (tracks.isEmpty || restoreEpoch != _userCommandEpoch) return;
    final applied = await _loadQueue(
      tracks,
      initialIndex: currentIndex,
      initialPosition: position,
      preload: false,
      requiredUserCommandEpoch: restoreEpoch,
    );
    if (applied) {
      await setPlaybackMode(mode);
      _trace('restore-applied id=${mediaItem.value?.id}');
    } else {
      _trace('restore-skipped-after-user-command');
    }
  }

  Future<void> clearSession() async {
    _markUserCommand('clearSession');
    _pendingAdvanceRequest = null;
    _replacePlaybackContext(const <Track>[]);
    _playbackHistory.clear();
    _autoplaySessionTrackKeys.clear();
    invalidateRadioRecommendations();
    await _ready;
    await _pauseFadeController.cancel();
    await _player.stop();
    await _loadQueue(const <Track>[]);
    await setPlaybackMode(PlaybackMode.list);
    _trace('session-cleared');
  }

  Track? trackForId(String id) {
    return _knownTracks[id];
  }

  Future<void> setPlaybackMode(PlaybackMode mode) async {
    await _readyIfAvailable();
    _mode = mode;
    switch (mode) {
      case PlaybackMode.list:
        await _player.setShuffleModeEnabled(false);
        await _player.setLoopMode(LoopMode.off);
      case PlaybackMode.single:
        await _player.setShuffleModeEnabled(false);
        await _player.setLoopMode(LoopMode.one);
      case PlaybackMode.random:
        await _player.setLoopMode(LoopMode.off);
        await _player.setShuffleModeEnabled(false);
        final currentId = mediaItem.value?.id;
        final currentTrack = currentId == null ? null : trackForId(currentId);
        if (currentTrack != null) _rememberAutoplaySelection(currentTrack);
        unawaited(_ensureRadioFallbackTracks());
    }
    _modeController.add(_mode);
    _broadcastState(_player.playbackEvent);
  }

  Future<void> _readyIfAvailable() async {
    // During initialisation setPlaybackMode is called from inside _ready itself.
    // At that point the player already has its sources and can be configured
    // directly; later calls await the same completed future in their caller.
  }

  void _markUserCommand(String command) {
    _userCommandEpoch += 1;
    if (!_userCommandController.isClosed) {
      _userCommandController.add(command);
    }
    _trace('user-command=$command epoch=$_userCommandEpoch');
  }

  void _trace(String message) {
    developer.log(message, name: 'MestingAudio');
  }
}

class _PendingAdvanceRequest {
  const _PendingAdvanceRequest({
    required this.forward,
    required this.automatic,
  });

  final bool forward;
  final bool automatic;
}
