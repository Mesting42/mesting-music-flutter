import 'package:audio_service/audio_service.dart';

enum TrackSource { local, kugou, netease, audius, jamendo }

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
    this.source = TrackSource.local,
    this.provider = '本地',
    this.isPreview = false,
    this.externalUrl = '',
    this.licenseUrl = '',
    this.availabilityMessage = '',
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String audioAsset;
  final String coverAsset;
  final String lyricsAsset;
  final TrackSource source;
  final String provider;
  final bool isPreview;
  final String externalUrl;
  final String licenseUrl;
  final String availabilityMessage;

  bool get isRemote => source != TrackSource.local;
  String get resolvedLyricsAsset {
    final value = lyricsAsset.trim();
    if (value.isNotEmpty) return value;
    if (source == TrackSource.kugou && id.startsWith('kugou_')) {
      final hash = id.substring('kugou_'.length);
      if (hash.isNotEmpty) {
        return Uri(
          scheme: 'mesting-lyrics',
          host: 'kugou',
          path: '/$hash',
          queryParameters: {'durationMs': '${duration.inMilliseconds}'},
        ).toString();
      }
    }
    return '';
  }

  bool get hasLyrics => resolvedLyricsAsset.isNotEmpty;
  bool get isPlayable => audioAsset.trim().isNotEmpty;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationMs': duration.inMilliseconds,
      'audioAsset': audioAsset,
      'coverAsset': coverAsset,
      'lyricsAsset': resolvedLyricsAsset,
      'source': source.name,
      'provider': provider,
      'isPreview': isPreview,
      'externalUrl': externalUrl,
      'licenseUrl': licenseUrl,
      'availabilityMessage': availabilityMessage,
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
      source: TrackSource.values.firstWhere(
        (source) => source.name == json['source'],
        orElse: () => TrackSource.local,
      ),
      provider: json['provider'] as String? ?? '本地',
      isPreview: json['isPreview'] as bool? ?? false,
      externalUrl: json['externalUrl'] as String? ?? '',
      licenseUrl: json['licenseUrl'] as String? ?? '',
      availabilityMessage: json['availabilityMessage'] as String? ?? '',
    );
  }

  MediaItem toMediaItem({Uri? artUri}) {
    final resolvedArtwork =
        artUri ?? (isRemote ? Uri.tryParse(coverAsset) : null);
    return MediaItem(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      artUri: resolvedArtwork,
      extras: {
        'audioAsset': audioAsset,
        'coverAsset': coverAsset,
        'lyricsAsset': resolvedLyricsAsset,
        'source': source.name,
        'provider': provider,
        'isPreview': isPreview,
        'externalUrl': externalUrl,
        'availabilityMessage': availabilityMessage,
      },
    );
  }

  Track copyWith({
    String? audioAsset,
    String? coverAsset,
    String? lyricsAsset,
    bool? isPreview,
    String? availabilityMessage,
  }) {
    return Track(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      audioAsset: audioAsset ?? this.audioAsset,
      coverAsset: coverAsset ?? this.coverAsset,
      lyricsAsset: lyricsAsset ?? this.lyricsAsset,
      source: source,
      provider: provider,
      isPreview: isPreview ?? this.isPreview,
      externalUrl: externalUrl,
      licenseUrl: licenseUrl,
      availabilityMessage: availabilityMessage ?? this.availabilityMessage,
    );
  }
}
