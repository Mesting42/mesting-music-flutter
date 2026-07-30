import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../shared/models/track.dart';
import 'playback_mode.dart';
import 'queue_engine.dart';

class MestingAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  MestingAudioHandler({required List<Track> tracks})
    : _tracks = List.of(tracks) {
    final mediaItems = _tracks.map((track) => track.toMediaItem()).toList();
    queue.add(mediaItems);

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
      },
    );
    _player.currentIndexStream.listen(_handleCurrentIndex);
    _player.durationStream.listen(_handleDuration);
    _ready = _initialize();
  }

  List<Track> _tracks;
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  final StreamController<PlaybackMode> _modeController =
      StreamController<PlaybackMode>.broadcast();

  late final Future<void> _ready;
  PlaybackMode _mode = PlaybackMode.list;

  List<Track> get tracks => List.unmodifiable(_tracks);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlaybackMode> get playbackModeStream async* {
    yield _mode;
    yield* _modeController.stream;
  }

  PlaybackMode get playbackMode => _mode;
  Duration get currentPosition => _player.position;
  int get currentIndex => _player.currentIndex ?? 0;

  Future<void> _initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _loadQueue(_tracks);
    await setPlaybackMode(_mode);
  }

  Future<void> _loadQueue(
    List<Track> tracks, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  }) async {
    _tracks = List.of(tracks);
    final mediaItems = _tracks.map((track) => track.toMediaItem()).toList();
    queue.add(mediaItems);
    if (_tracks.isEmpty) {
      mediaItem.add(null);
      await _player.setAudioSources(const []);
      return;
    }
    final safeIndex = initialIndex.clamp(0, _tracks.length - 1);
    await _player.setAudioSources(
      [
        for (var index = 0; index < _tracks.length; index += 1)
          AudioSource.asset(_tracks[index].audioAsset, tag: mediaItems[index]),
      ],
      initialIndex: safeIndex,
      initialPosition: initialPosition,
    );
    mediaItem.add(mediaItems[safeIndex]);
  }

  void _handleCurrentIndex(int? index) {
    final items = queue.value;
    if (index == null || index < 0 || index >= items.length) return;
    mediaItem.add(items[index]);
    _broadcastState(_player.playbackEvent);
  }

  void _handleDuration(Duration? duration) {
    final current = mediaItem.value;
    if (current == null || duration == null || current.duration == duration) {
      return;
    }
    mediaItem.add(current.copyWith(duration: duration));
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
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
        queueIndex: _player.currentIndex,
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

  @override
  Future<void> play() async {
    await _ready;
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _ready;
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _ready;
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _ready;
    await _player.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _ready;
    if (index < 0 || index >= _tracks.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _skip(forward: true);

  @override
  Future<void> skipToPrevious() async {
    await _ready;
    if (_player.position > const Duration(seconds: 4)) {
      await _player.seek(Duration.zero);
      return;
    }
    await _skip(forward: false);
  }

  Future<void> _skip({required bool forward}) async {
    await _ready;
    final current = _player.currentIndex ?? 0;
    // 单曲循环只影响自然播放完成；用户主动切歌仍按列表前后移动。
    final navigationMode = _mode == PlaybackMode.single
        ? PlaybackMode.list
        : _mode;
    final target = forward
        ? QueueEngine.nextIndex(
            length: tracks.length,
            currentIndex: current,
            mode: navigationMode,
            random: _random,
          )
        : QueueEngine.previousIndex(
            length: tracks.length,
            currentIndex: current,
            mode: navigationMode,
            random: _random,
          );
    await _player.seek(Duration.zero, index: target);
  }

  Future<void> playTrack(String id) async {
    final index = _tracks.indexWhere((track) => track.id == id);
    if (index < 0) return;
    await skipToQueueItem(index);
    await play();
  }

  Future<void> togglePlayPause() async {
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
    await _ready;
    await _loadQueue(
      tracks,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
    await setPlaybackMode(_mode);
    if (autoplay && tracks.isNotEmpty) await play();
  }

  Future<void> restoreSession({
    required List<Track> tracks,
    required int currentIndex,
    required Duration position,
    required PlaybackMode mode,
  }) async {
    await _ready;
    if (tracks.isEmpty) return;
    await _loadQueue(
      tracks,
      initialIndex: currentIndex,
      initialPosition: position,
    );
    await setPlaybackMode(mode);
  }

  Track? trackForId(String id) {
    for (final track in _tracks) {
      if (track.id == id) return track;
    }
    return null;
  }

  Future<void> setPlaybackMode(PlaybackMode mode) async {
    await _readyIfAvailable();
    _mode = mode;
    switch (mode) {
      case PlaybackMode.list:
        await _player.setShuffleModeEnabled(false);
        await _player.setLoopMode(LoopMode.all);
      case PlaybackMode.single:
        await _player.setShuffleModeEnabled(false);
        await _player.setLoopMode(LoopMode.one);
      case PlaybackMode.random:
        await _player.setLoopMode(LoopMode.all);
        await _player.shuffle();
        await _player.setShuffleModeEnabled(true);
    }
    _modeController.add(_mode);
    _broadcastState(_player.playbackEvent);
  }

  Future<void> _readyIfAvailable() async {
    // During initialisation setPlaybackMode is called from inside _ready itself.
    // At that point the player already has its sources and can be configured
    // directly; later calls await the same completed future in their caller.
  }
}
