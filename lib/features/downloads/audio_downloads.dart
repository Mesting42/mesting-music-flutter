import '../music_platform/netease/netease_track_sources.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../shared/models/track.dart';
import '../../core/persistence/app_preferences.dart';
import 'audio_download_storage.dart';
import '../music_platform/data/music_platform_api.dart';
import '../music_platform/data/embedded_kugou_music_source.dart';
import '../music_platform/domain/platform_session.dart';
import '../music_platform/music_platform_providers.dart';
import '../music_platform/platform_backend_providers.dart';
import '../music_platform/platform_quality_providers.dart';
import '../music_platform/netease/netease_music_repository.dart';
import '../music_platform/netease/netease_fallback.dart';
import '../search/search_providers.dart';

enum AudioDownloadPhase {
  queued,
  downloading,
  saving,
  completed,
  failed,
  cancelled,
}

class AudioDownloadTask {
  const AudioDownloadTask({
    required this.id,
    required this.owner,
    required this.track,
    this.phase = AudioDownloadPhase.queued,
    this.received = 0,
    this.total = 0,
    this.uri = '',
    this.error = '',
  });
  final String id, owner, uri, error;
  final Track track;
  final AudioDownloadPhase phase;
  final int received, total;
  AudioDownloadTask copy({
    Track? track,
    AudioDownloadPhase? phase,
    int? received,
    int? total,
    String? uri,
    String? error,
  }) => AudioDownloadTask(
    id: id,
    owner: owner,
    track: track ?? this.track,
    phase: phase ?? this.phase,
    received: received ?? this.received,
    total: total ?? this.total,
    uri: uri ?? this.uri,
    error: error ?? this.error,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'owner': owner,
    'track': track.toJson(),
    'phase': phase.name,
    'received': received,
    'total': total,
    'uri': uri,
    'error': error,
  };
}

/// Detect containers from bytes: some music CDNs label FLAC as audio/mpeg.
/// A JSON/HTML error must never become a successful-looking .mp3 download.
({String extension, String mime})? identifyAudio(List<int> data) {
  if (data.length < 12) return null;
  String at(int start, int end) =>
      String.fromCharCodes(data.sublist(start, end));
  if (at(0, 4) == 'fLaC') return (extension: 'flac', mime: 'audio/flac');
  if (at(0, 3) == 'ID3' || (data[0] == 0xff && data[1] & 0xe0 == 0xe0)) {
    return (extension: 'mp3', mime: 'audio/mpeg');
  }
  if (at(0, 4) == 'OggS') return (extension: 'ogg', mime: 'audio/ogg');
  if (at(0, 4) == 'RIFF' && at(8, 12) == 'WAVE') {
    return (extension: 'wav', mime: 'audio/wav');
  }
  if (at(4, 8) == 'ftyp') return (extension: 'm4a', mime: 'audio/mp4');
  return null;
}

typedef ResolveDownload = Future<String> Function(Track track);
typedef ResolveDownloadMedia = Future<Track> Function(Track track);
typedef PublishDownload =
    Future<String> Function(
      File file,
      Track track,
      String extension,
      String mime,
    );

/// A single bounded streaming worker owns queue/progress/cancellation. The
/// resolver and platform exporter are injected; neither controls audio playback.
class AudioDownloadManager extends ChangeNotifier {
  AudioDownloadManager({
    required this.client,
    this.resolve,
    this.resolveMedia,
    required this.publish,
    required this.currentOwner,
    required this.directory,
    required this.persist,
    List<AudioDownloadTask> restored = const [],
  }) : assert((resolve == null) != (resolveMedia == null)),
       _tasks = [...restored];
  final http.Client client;
  // Preserve URL-only embedders while letting typed native sources carry their
  // public CDN headers. Exactly one resolver owns a given download manager.
  final ResolveDownload? resolve;
  final ResolveDownloadMedia? resolveMedia;
  final PublishDownload publish;
  final String? Function() currentOwner;
  final Future<Directory> Function() directory;
  final Future<void> Function(List<AudioDownloadTask>) persist;
  final List<AudioDownloadTask> _tasks;
  List<AudioDownloadTask> get tasks => List.unmodifiable(_tasks);
  bool _working = false, _disposed = false;
  String? _active;
  Completer<void>? _abort;
  Future<void> _writes = Future.value();
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _save() {
    final snapshot = List<AudioDownloadTask>.of(_tasks);
    _writes = _writes.catchError((Object _) {}).then((_) => persist(snapshot));
    // Storage errors must not leak into the playback/UI zone as unhandled work.
    unawaited(_writes.catchError((Object _) {}));
  }

  void _replace(AudioDownloadTask task, {bool save = true}) {
    final index = _tasks.indexWhere((i) => i.id == task.id);
    if (index < 0) return;
    _tasks[index] = task;
    if (save) _save();
    _notify();
  }

  void enqueue(Track track) {
    final owner = currentOwner();
    if (owner == null) throw const MusicPlatformException('请先登录对应音乐平台');
    if (_tasks.any(
      (t) =>
          t.owner == owner &&
          t.track.id == track.id &&
          {
            AudioDownloadPhase.queued,
            AudioDownloadPhase.downloading,
            AudioDownloadPhase.saving,
          }.contains(t.phase),
    )) {
      return;
    }
    _tasks.add(
      AudioDownloadTask(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        owner: owner,
        track: track,
      ),
    );
    _save();
    _notify();
    unawaited(_pump());
  }

  void cancel(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    if (task.phase == AudioDownloadPhase.saving ||
        task.phase == AudioDownloadPhase.completed) {
      return;
    }
    if (_active == id && _abort?.isCompleted == false) _abort!.complete();
    _replace(task.copy(phase: AudioDownloadPhase.cancelled));
  }

  void cancelPending() {
    for (final task in List<AudioDownloadTask>.of(_tasks)) {
      if (task.phase == AudioDownloadPhase.queued ||
          task.phase == AudioDownloadPhase.downloading) {
        cancel(task.id);
      }
    }
  }

  void retry(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    if (task.owner != currentOwner() ||
        !{
          AudioDownloadPhase.failed,
          AudioDownloadPhase.cancelled,
        }.contains(task.phase)) {
      return;
    }
    _replace(
      task.copy(
        phase: AudioDownloadPhase.queued,
        received: 0,
        total: 0,
        error: '',
      ),
    );
    unawaited(_pump());
  }

  bool _current(AudioDownloadTask task) =>
      !_disposed &&
      task.owner == currentOwner() &&
      _tasks.any(
        (t) => t.id == task.id && t.phase != AudioDownloadPhase.cancelled,
      );
  Future<void> _pump() async {
    if (_working || _disposed) return;
    _working = true;
    try {
      while (!_disposed) {
        final next = _tasks
            .where(
              (t) =>
                  t.phase == AudioDownloadPhase.queued &&
                  t.owner == currentOwner(),
            )
            .firstOrNull;
        if (next == null) break;
        await _download(next);
      }
    } finally {
      _working = false;
    }
  }

  Future<void> _download(AudioDownloadTask task) async {
    _active = task.id;
    _abort = Completer<void>();
    File? partial;
    try {
      _replace(task.copy(phase: AudioDownloadPhase.downloading));
      final media = resolveMedia != null
          ? await resolveMedia!(task.track)
          : task.track.copyWith(
              audioAsset: await resolve!(task.track),
              audioHeaders: const {},
            );
      final url = Uri.parse(media.audioAsset);
      if (!_current(task)) return;
      if (!{'https', 'http'}.contains(url.scheme) ||
          url.host.isEmpty ||
          url.userInfo.isNotEmpty) {
        throw const FormatException('无效音频地址');
      }
      final root = await directory();
      await root.create(recursive: true);
      partial = File('${root.path}/${task.id}.part');
      final response = await client
          .send(
            http.AbortableRequest('GET', url, abortTrigger: _abort!.future)
              ..headers.addAll(publicAudioHeaders(media.audioHeaders)),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        await response.stream.take(1).drain<void>();
        throw const MusicPlatformException('下载地址已失效，请重试');
      }
      final total = response.contentLength ?? 0;
      if (total > 512 * 1024 * 1024) {
        await response.stream.take(1).drain<void>();
        throw const MusicPlatformException('文件超过 512 MB');
      }
      var received = 0;
      final prefix = <int>[];
      final output = partial.openWrite();
      final watch = Stopwatch()..start();
      try {
        await for (final chunk in response.stream.timeout(
          const Duration(seconds: 30),
        )) {
          if (!_current(task)) throw const MusicPlatformException('下载已取消');
          received += chunk.length;
          if (received > 512 * 1024 * 1024) {
            throw const MusicPlatformException('文件超过 512 MB');
          }
          if (prefix.length < 64) prefix.addAll(chunk.take(64 - prefix.length));
          output.add(chunk);
          if (watch.elapsedMilliseconds >= 250) {
            _replace(
              task.copy(
                phase: AudioDownloadPhase.downloading,
                received: received,
                total: total,
              ),
              save: false,
            );
            watch.reset();
          }
        }
        await output.flush();
      } finally {
        await output.close();
      }
      if (!_current(task)) return;
      if (received == 0 || (total > 0 && received != total)) {
        throw const MusicPlatformException('文件下载不完整，请重试');
      }
      final format = identifyAudio(prefix);
      if (format == null) throw const MusicPlatformException('返回内容不是受支持的音频文件');
      _replace(
        task.copy(
          phase: AudioDownloadPhase.saving,
          received: received,
          total: received,
        ),
      );
      final uri = await publish(
        partial,
        task.track,
        format.extension,
        format.mime,
      );
      _replace(
        task.copy(
          phase: AudioDownloadPhase.completed,
          track: task.track.copyWith(
            playbackQuality: media.playbackQuality,
            audioBitrate: media.audioBitrate,
          ),
          received: received,
          total: received,
          uri: uri,
        ),
      );
    } catch (error) {
      if (_current(task)) {
        _replace(
          task.copy(phase: AudioDownloadPhase.failed, error: error.toString()),
        );
      }
    } finally {
      if (partial != null && await partial.exists()) await partial.delete();
      _active = null;
      _abort = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_abort?.isCompleted == false) _abort!.complete();
    client.close();
    super.dispose();
  }
}

/// URI-backed playback bypasses platform parsing, even after an app restart.
Track downloadedPlaybackTrack(AudioDownloadTask task) {
  if (task.phase != AudioDownloadPhase.completed || task.uri.isEmpty) {
    throw const MusicPlatformException('歌曲尚未下载完成');
  }
  final uri = Uri.tryParse(task.uri);
  if (uri == null || !{'content', 'file'}.contains(uri.scheme)) {
    throw const MusicPlatformException('下载文件地址不可用，请重新下载');
  }
  return task.track.copyWith(
    audioAsset: task.uri,
    audioHeaders: const {},
    isPreview: false,
  );
}

final audioDownloadManagerProvider = Provider<AudioDownloadManager>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final restored = <AudioDownloadTask>[];
  try {
    final rows =
        jsonDecode(preferences.getString('audio_download_tasks_v1') ?? '[]')
            as List;
    for (final row in rows.whereType<Map>()) {
      final phase = AudioDownloadPhase.values.byName('${row['phase']}');
      restored.add(
        AudioDownloadTask(
          id: '${row['id']}',
          owner: '${row['owner']}',
          track: Track.fromJson(Map<String, Object?>.from(row['track'] as Map)),
          phase:
              phase == AudioDownloadPhase.completed ||
                  phase == AudioDownloadPhase.cancelled
              ? phase
              : AudioDownloadPhase.failed,
          received: row['received'] as int? ?? 0,
          total: row['total'] as int? ?? 0,
          uri: '${row['uri'] ?? ''}',
          error: phase == AudioDownloadPhase.completed ? '' : '上次下载已中断，可点击重试',
        ),
      );
    }
  } catch (_) {
    /* A corrupt history must not block new downloads. */
  }
  final manager = AudioDownloadManager(
    client: http.Client(),
    restored: restored,
    currentOwner: () => ref.read(platformAccountProvider).value?.ownerId,
    directory: () async =>
        Directory('${(await getTemporaryDirectory()).path}/audio-downloads'),
    persist: (tasks) async {
      if (!await preferences.setString(
        'audio_download_tasks_v1',
        jsonEncode(tasks.map((t) => t.toJson()).toList()),
      )) {
        throw const MusicPlatformException('下载记录未保存');
      }
    },
    resolveMedia: (track) async {
      final quality = ref.read(platformQualityProvider).preferred;
      if (track.source == TrackSource.netease &&
          ref.read(usesNeteaseProvider)) {
        final music = ref.read(neteaseMusicRepositoryProvider);
        final selected =
            ref.read(neteaseTrackSourcesProvider)[track.id] ??
            NeteaseTrackSource.automatic;
        if (selected != NeteaseTrackSource.automatic) {
          final credential = music.credential;
          return resolveNeteaseTrack(
            music: music,
            fallback: ref.read(neteaseFallbackResolverProvider),
            allowFallback: true,
            current: () =>
                ref.mounted &&
                ref.read(usesNeteaseProvider) &&
                ref.read(neteaseMusicRepositoryProvider).credential ==
                    credential,
            track: track,
            quality: quality,
            selectedSource: selected,
          );
        }
        Object? failure;
        Map<String, dynamic> row = {};
        try {
          final payload = await music.call('/song/download/url/v1', {
            'id': NeteaseMusicRepository.songId(track.id),
            'level': switch (quality.code) {
              'flac' => 'lossless',
              'high' => 'hires',
              '320' => 'exhigh',
              _ => 'standard',
            },
          });
          row = NeteaseMusicRepository.object(payload['data']);
        } catch (error) {
          if (error is MusicPlatformException &&
              {'301', '302', '415', '405', '460'}.contains(error.code)) {
            rethrow;
          }
          failure = error;
        }
        if ('${row['url'] ?? ''}'.startsWith('http') &&
            row['freeTrialInfo'] == null) {
          return track.copyWith(
            audioAsset: '${row['url']}',
            audioHeaders: const {},
          );
        }
        if (ref.read(neteaseFallbackEnabledProvider)) {
          final credential = music.credential;
          final fallback = await ref
              .read(neteaseFallbackResolverProvider)
              .resolve(
                track.copyWith(playbackQuality: quality.code),
                current: () =>
                    ref.mounted &&
                    ref.read(usesNeteaseProvider) &&
                    ref.read(neteaseMusicRepositoryProvider).credential ==
                        credential,
              );
          if (fallback != null) return fallback;
        }
        throw failure ?? const MusicPlatformException('网易云未返回完整下载地址');
      }
      if (track.source == TrackSource.kugou &&
          ref.read(platformAccountProvider).value?.platform ==
              MusicPlatform.kugou) {
        final source = ref.read(kugouMusicSourceProvider);
        if (source is EmbeddedKugouMusicSource) {
          final resolved = await source.resolveTrack(track, quality: quality);
          if (resolved.isPlayable && !resolved.isPreview) {
            return resolved;
          }
        }
      }
      throw const MusicPlatformException('请使用当前平台的在线歌曲下载');
    },
    publish: const AudioDownloadStorage().publish,
  );
  ref.listen(platformAccountProvider, (before, after) {
    if (before?.value?.ownerId != after.value?.ownerId ||
        before?.value?.token != after.value?.token) {
      manager.cancelPending();
    }
  });
  ref.onDispose(manager.dispose);
  return manager;
});
