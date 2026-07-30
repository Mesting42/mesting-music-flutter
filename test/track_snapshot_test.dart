import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/library/data/demo_library.dart';
import 'package:mesting_music/shared/models/track.dart';

void main() {
  test('Track 数据快照可以完整往返', () {
    for (final track in demoTracks) {
      final restored = Track.fromJson(track.toJson());
      expect(restored.id, track.id);
      expect(restored.title, track.title);
      expect(restored.artist, track.artist);
      expect(restored.album, track.album);
      expect(restored.duration, track.duration);
      expect(restored.audioAsset, track.audioAsset);
      expect(restored.coverAsset, track.coverAsset);
      expect(restored.lyricsAsset, track.lyricsAsset);
    }
  });
}
