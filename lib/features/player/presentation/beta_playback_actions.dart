import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/models/track.dart';
import '../../music_platform/presentation/platform_feedback.dart';

/// A single entry point for deliberate Beta playback. Page contents are never
/// an implicit queue: only Play All and explicit Add actions populate it.
Future<bool> playBetaSelection(
  BuildContext context,
  WidgetRef ref,
  Track track, {
  List<Track>? playAll,
}) async {
  try {
    return await _playSelection(context, ref, track, playAll: playAll);
  } catch (error) {
    if (context.mounted) showPlatformFailure(context, error);
    return false;
  }
}

Future<bool> _playSelection(
  BuildContext context,
  WidgetRef ref,
  Track track, {
  List<Track>? playAll,
}) async {
  final handler = ref.read(audioHandlerProvider);
  final pending = handler.manuallyQueuedItems;
  var replace = playAll != null;
  if (pending.isNotEmpty && !pending.any((item) => item.id == track.id)) {
    final choice = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('接下来播放什么？'),
        content: const Text('播放所选音乐后，保留原来的待播歌曲，或替换待播列表。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('保留待播歌曲'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('替换待播歌曲'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return false;
    replace = choice;
  }
  if (playAll != null) {
    // Keep is meaningful for Play All too: the newly selected collection plays
    // first and the old, deliberately queued songs follow it without duplicates.
    final ids = playAll.map((song) => song.id).toSet();
    final tail = replace
        ? const <Track>[]
        : pending
              .map((item) => handler.trackForId(item.id))
              .whereType<Track>()
              .where((song) => ids.add(song.id));
    await handler.replaceQueue([...playAll, ...tail]);
  } else {
    await handler.playSingleTrack(
      track,
      playbackContext: [track],
      replaceUpcoming: replace,
      discardRecommendations: true,
    );
  }
  return true;
}
