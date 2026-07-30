import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/library/data/demo_library.dart';
import '../../shared/models/track.dart';
import 'mesting_audio_handler.dart';
import 'playback_mode.dart';

final audioHandlerProvider = Provider<MestingAudioHandler>((ref) {
  throw StateError('audioHandlerProvider 必须在应用启动时覆盖');
});

final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  return ref.watch(audioHandlerProvider).playbackState;
});

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  return ref.watch(audioHandlerProvider).mediaItem;
});

final queueProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(audioHandlerProvider).queue;
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
      trackForMediaItemId(item?.id ?? demoTracks.first.id);
});
