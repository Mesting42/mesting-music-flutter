import 'dart:math';

import 'playback_mode.dart';

class QueueEngine {
  const QueueEngine._();

  static int nextIndex({
    required int length,
    required int currentIndex,
    required PlaybackMode mode,
    Random? random,
  }) {
    if (length <= 1) return 0;
    if (mode == PlaybackMode.single) return currentIndex.clamp(0, length - 1);
    if (mode == PlaybackMode.random) {
      final generator = random ?? Random();
      var candidate = generator.nextInt(length - 1);
      if (candidate >= currentIndex) candidate += 1;
      return candidate;
    }
    return (currentIndex + 1) % length;
  }

  static int previousIndex({
    required int length,
    required int currentIndex,
    required PlaybackMode mode,
    Random? random,
  }) {
    if (length <= 1) return 0;
    if (mode == PlaybackMode.single) return currentIndex.clamp(0, length - 1);
    if (mode == PlaybackMode.random) {
      return nextIndex(
        length: length,
        currentIndex: currentIndex,
        mode: mode,
        random: random,
      );
    }
    return (currentIndex - 1 + length) % length;
  }
}
