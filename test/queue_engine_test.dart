import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/core/audio/playback_mode.dart';
import 'package:mesting_music/core/audio/queue_engine.dart';

void main() {
  group('QueueEngine', () {
    test('列表循环首尾相接', () {
      expect(
        QueueEngine.nextIndex(
          length: 3,
          currentIndex: 2,
          mode: PlaybackMode.list,
        ),
        0,
      );
      expect(
        QueueEngine.previousIndex(
          length: 3,
          currentIndex: 0,
          mode: PlaybackMode.list,
        ),
        2,
      );
    });

    test('单曲循环保持当前索引', () {
      expect(
        QueueEngine.nextIndex(
          length: 4,
          currentIndex: 2,
          mode: PlaybackMode.single,
        ),
        2,
      );
    });

    test('随机播放不会立刻重复当前歌曲', () {
      final target = QueueEngine.nextIndex(
        length: 5,
        currentIndex: 2,
        mode: PlaybackMode.random,
        random: Random(7),
      );

      expect(target, isNot(2));
      expect(target, inInclusiveRange(0, 4));
    });

    test('空队列和单曲队列安全返回零', () {
      expect(
        QueueEngine.nextIndex(
          length: 0,
          currentIndex: 0,
          mode: PlaybackMode.list,
        ),
        0,
      );
      expect(
        QueueEngine.previousIndex(
          length: 1,
          currentIndex: 0,
          mode: PlaybackMode.random,
        ),
        0,
      );
    });
  });
}
