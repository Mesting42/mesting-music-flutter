import 'package:audio_service/audio_service.dart';

class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.audioAsset,
    required this.coverAsset,
    required this.lyricsAsset,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String audioAsset;
  final String coverAsset;
  final String lyricsAsset;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationMs': duration.inMilliseconds,
      'audioAsset': audioAsset,
      'coverAsset': coverAsset,
      'lyricsAsset': lyricsAsset,
    };
  }

  factory Track.fromJson(Map<String, Object?> json) {
    return Track(
      id: json['id']! as String,
      title: json['title']! as String,
      artist: json['artist']! as String,
      album: json['album']! as String,
      duration: Duration(milliseconds: json['durationMs']! as int),
      audioAsset: json['audioAsset']! as String,
      coverAsset: json['coverAsset']! as String,
      lyricsAsset: json['lyricsAsset']! as String,
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      extras: {
        'audioAsset': audioAsset,
        'coverAsset': coverAsset,
        'lyricsAsset': lyricsAsset,
      },
    );
  }
}
