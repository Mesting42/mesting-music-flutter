import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/library/data/demo_library.dart';
import 'package:mesting_music/features/lyrics/domain/lrc_parser.dart';

void main() {
  final localAssetsAvailable = demoTracks.every(
    (track) =>
        File(track.audioAsset).existsSync() &&
        File(track.coverAsset).existsSync() &&
        File(track.lyricsAsset).existsSync(),
  );
  final localAssetsSkipReason = localAssetsAvailable
      ? false
      : '公开仓库不包含受版权保护的本地演示素材';

  group('本地音乐资源', () {
    test('8 首歌曲的 ID 与标题映射完整', () {
      expect(demoTracks, hasLength(8));
      expect(demoTracks.map((track) => track.id).toSet(), hasLength(8));
      expect(demoTracks.map((track) => track.title).toSet(), hasLength(8));
    });

    test('本地音频、封面和歌词资源完整', () {
      for (final track in demoTracks) {
        final audio = File(track.audioAsset);
        final cover = File(track.coverAsset);
        final lyrics = File(track.lyricsAsset);

        expect(audio.existsSync(), isTrue, reason: '${track.title} 缺少音频');
        expect(audio.lengthSync(), greaterThan(0));
        expect(cover.existsSync(), isTrue, reason: '${track.title} 缺少封面');
        expect(cover.lengthSync(), greaterThan(0));
        expect(lyrics.existsSync(), isTrue, reason: '${track.title} 缺少歌词');
        expect(lyrics.lengthSync(), greaterThan(0));
      }
    }, skip: localAssetsSkipReason);

    test('所有已迁移 LRC 都能解析出同步歌词', () {
      const parser = LrcParser();

      for (final track in demoTracks) {
        final document = parser.parse(
          File(track.lyricsAsset).readAsStringSync(),
        );
        expect(document.isSynced, isTrue, reason: '${track.title} 不是同步歌词');
        expect(document.lines, isNotEmpty, reason: '${track.title} 歌词为空');
      }
    }, skip: localAssetsSkipReason);
  });
}
