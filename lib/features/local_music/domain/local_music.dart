import '../../../shared/models/track.dart';

/// Device-library identities are URI based, independently of any cloud account.
/// A local file is never relabelled as a Kugou recording to make it playable.
class LocalMusicEntry {
  const LocalMusicEntry({
    required this.id,
    required this.uri,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.folderId,
    required this.folderName,
    this.folderPath = '',
    this.artwork = '',
    this.available = true,
    this.origin = 'file',
  });

  final String id, uri, title, artist, album, folderId, folderName;
  final String folderPath, artwork, origin;
  final Duration duration;
  final bool available;

  factory LocalMusicEntry.fromMap(Map<Object?, Object?> map) {
    String text(String key) => '${map[key] ?? ''}'.trim();
    final id = text('id');
    final uri = text('uri');
    final parsed = Uri.tryParse(uri);
    if (!id.startsWith('local_') ||
        parsed == null ||
        !const {'content', 'file'}.contains(parsed.scheme) ||
        parsed.path.isEmpty ||
        parsed.pathSegments.every((segment) => segment.isEmpty) ||
        (parsed.scheme == 'content' && parsed.host.isEmpty)) {
      throw const FormatException('本地音乐条目缺少有效的文件地址');
    }
    final milliseconds = int.tryParse('${map['durationMs']}') ?? 0;
    return LocalMusicEntry(
      id: id,
      uri: uri,
      title: text('title').isEmpty ? '未命名音频' : text('title'),
      artist: text('artist').isEmpty ? '未知歌手' : text('artist'),
      album: text('album').isEmpty ? '未知专辑' : text('album'),
      duration: Duration(milliseconds: milliseconds.clamp(0, 1 << 53)),
      folderId: text('folderId'),
      folderName: text('folderName').isEmpty ? '导入的文件' : text('folderName'),
      folderPath: text('folderPath'),
      artwork: text('artwork'),
      available: map['available'] != false,
      origin: text('origin'),
    );
  }

  Track get track => Track(
    id: id,
    title: title,
    artist: artist,
    album: album,
    duration: duration,
    audioAsset: uri,
    coverAsset: artwork,
    lyricsAsset: '',
    source: TrackSource.local,
    provider: '本地音乐',
  );

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    return needle.isEmpty ||
        '$title\n$artist\n$album\n$folderName'.toLowerCase().contains(needle);
  }

  LocalMusicEntry withAvailability(bool value) => LocalMusicEntry(
    id: id,
    uri: uri,
    title: title,
    artist: artist,
    album: album,
    duration: duration,
    folderId: folderId,
    folderName: folderName,
    folderPath: folderPath,
    artwork: artwork,
    available: value,
    origin: origin,
  );
}

class LocalMusicFolder {
  const LocalMusicFolder(this.id, this.name, this.path, this.count);
  final String id, name, path;
  final int count;
}

class LocalMusicLibrary {
  const LocalMusicLibrary({
    this.entries = const [],
    this.permissionGranted = false,
    this.notice = '',
  });
  final List<LocalMusicEntry> entries;
  final bool permissionGranted;
  final String notice;

  factory LocalMusicLibrary.fromMap(Map<Object?, Object?> map) {
    final entries = <LocalMusicEntry>[];
    final identities = <String>{};
    final rows = map['entries'];
    if (rows is List) {
      for (final row in rows.take(10000)) {
        if (row is! Map) continue;
        try {
          final entry = LocalMusicEntry.fromMap(row);
          if (identities.add(entry.id)) entries.add(entry);
        } on FormatException {
          // An obsolete entry must not hide the rest of an imported directory.
        }
      }
    }
    entries.sort((a, b) => a.title.compareTo(b.title));
    return LocalMusicLibrary(
      entries: List.unmodifiable(entries),
      permissionGranted: map['permissionGranted'] == true,
      notice: '${map['notice'] ?? ''}',
    );
  }

  List<LocalMusicFolder> get folders {
    final groups = <String, LocalMusicFolder>{};
    for (final entry in entries) {
      final old = groups[entry.folderId];
      groups[entry.folderId] = LocalMusicFolder(
        entry.folderId,
        entry.folderName,
        entry.folderPath,
        (old?.count ?? 0) + 1,
      );
    }
    return groups.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }
}
