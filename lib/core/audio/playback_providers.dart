import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/track.dart';
import 'mesting_audio_handler.dart';
import 'playback_mode.dart';

final audioHandlerProvider = Provider<MestingAudioHandler>((ref) {
  throw StateError('audioHandlerProvider 必须在应用启动时覆盖');
});

final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  return ref.watch(audioHandlerProvider).playbackState;
});

bool shouldAnimateVinyl(PlaybackState? state) {
  return state?.playing == true &&
      state?.processingState == AudioProcessingState.ready;
}

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  return ref.watch(audioHandlerProvider).mediaItem;
});

final queueProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(audioHandlerProvider).queue;
});

final upcomingQueueProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(audioHandlerProvider).upcomingQueueStream;
});

final positionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioHandlerProvider).positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioHandlerProvider).durationStream;
});

final playbackModeProvider = StreamProvider<PlaybackMode>((ref) {
  return ref.watch(audioHandlerProvider).playbackModeStream;
});

final currentTrackProvider = Provider<Track>((ref) {
  final item = ref.watch(currentMediaItemProvider).value;
  final handler = ref.watch(audioHandlerProvider);
  return handler.trackForId(item?.id ?? '') ??
      Track(
        id: item?.id ?? 'empty_player',
        title: item?.title ?? '暂无播放',
        artist: item?.artist ?? '从在线曲库选择一首歌',
        album: item?.album ?? '',
        duration: item?.duration ?? Duration.zero,
        audioAsset: item?.extras?['audioAsset']?.toString() ?? '',
        coverAsset:
            item?.extras?['coverAsset']?.toString() ??
            item?.artUri?.toString() ??
            '',
        lyricsAsset: item?.extras?['lyricsAsset']?.toString() ?? '',
      );
});
