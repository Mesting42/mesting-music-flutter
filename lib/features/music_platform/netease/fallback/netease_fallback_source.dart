import '../../../../shared/models/track.dart';

abstract interface class NeteaseFallbackSource {
  String get label;
  Future<List<Track>> search(Track original);
  Future<Track?> resolve(Track candidate);
}

/// Only adapters resolving the requested NetEase ID may bypass title matching.
abstract interface class NeteaseExactIdSource
    implements NeteaseFallbackSource {}

/// Video/audio catalogues can prove title, performer, version and duration
/// without carrying an album field. Their parsers must retain version words.
abstract interface class NeteasePublicMetadataSource
    implements NeteaseFallbackSource {}

String normalizeRecordingText(String value) => value.toLowerCase().replaceAll(
  RegExp(r'[\s\p{P}\p{S}]', unicode: true),
  '',
);

bool isSameNeteaseRecording(
  Track original,
  Track candidate, {
  bool allowMissingAlbum = false,
}) {
  Set<String> artists(String value) => value
      .split(RegExp(r'\s*(?:/|&|、|,|，|;|；)\s*'))
      .map(normalizeRecordingText)
      .where((a) => a.isNotEmpty)
      .toSet();
  if (normalizeRecordingText(original.title).isEmpty ||
      normalizeRecordingText(original.title) !=
          normalizeRecordingText(candidate.title)) {
    return false;
  }
  final a = artists(original.artist), b = artists(candidate.artist);
  if (a.isEmpty || a.length != b.length || !a.containsAll(b)) return false;
  if (original.duration <= Duration.zero ||
      candidate.duration <= Duration.zero ||
      (original.duration - candidate.duration).inMilliseconds.abs() > 2000) {
    return false;
  }
  if (original.album.isNotEmpty &&
      !(allowMissingAlbum && candidate.album.isEmpty) &&
      normalizeRecordingText(original.album) !=
          normalizeRecordingText(candidate.album)) {
    return false;
  }
  return true;
}
