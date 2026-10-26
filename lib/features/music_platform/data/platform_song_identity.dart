/// The concept API identifies an album recording with mixsongid, while audio
/// playback uses a hash. Keep these identities distinct and ignore zero IDs.
class PlatformSongIdentity {
  static String fromPayload(Object? value, [int depth = 0]) {
    if (depth > 7) return '';
    if (value is List) {
      for (final row in value) {
        final id = fromPayload(row, depth + 1);
        if (id.isNotEmpty) return id;
      }
    } else if (value is Map) {
      for (final key in [
        'album_audio_id',
        'albumAudioId',
        'AlbumAudioID',
        'MixSongID',
        'mixsongid',
        'mix_song_id',
        'add_mixsongid',
        'album_audio_id2',
        'Audioid',
        'audio_id',
      ]) {
        final id = '${value[key] ?? ''}'.trim();
        if ((int.tryParse(id) ?? 0) > 0) return id;
      }
      for (final key in [
        'data',
        'audio_info',
        'base',
        'info',
        'list',
        'songs',
        'song_info',
        'audio',
        'album_info',
      ]) {
        final id = fromPayload(value[key], depth + 1);
        if (id.isNotEmpty) return id;
      }
    }
    return '';
  }
}
