import 'platform_backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/playback_providers.dart';
import '../../core/persistence/app_preferences.dart';
import 'domain/platform_audio_quality.dart';
import 'data/platform_quality_catalog.dart';
import 'music_platform_providers.dart';
import 'data/music_platform_api.dart';
import 'netease/netease_playback_options.dart';
import 'netease/netease_fallback.dart';

/// Only successful provider states are retained. Each state still watches the
/// account future, so logout/login/token replacement invalidates its catalog.
/// A small FIFO bounds memory without persisting stale server capabilities.
final _qualityRetentionsProvider = Provider((ref) {
  final retentions = _QualityRetentions();
  ref.onDispose(retentions.clear);
  return retentions;
});

class _QualityRetentions {
  final _releases = <String, void Function()>{};
  void retain(String id, void Function() release) {
    _releases.remove(id)?.call();
    _releases[id] = release;
    while (_releases.length > 64) {
      _releases.remove(_releases.keys.first)?.call();
    }
  }

  void forget(String id, void Function() release) {
    if (identical(_releases[id], release)) _releases.remove(id);
  }

  void clear() {
    final releases = _releases.values.toList();
    _releases.clear();
    for (final release in releases) {
      release();
    }
  }
}

final platformSongQualitiesProvider = FutureProvider.autoDispose
    .family<Set<PlatformAudioQuality>, String>((ref, id) async {
      final session = await ref.watch(platformAccountProvider.future);
      if (id.startsWith('netease_')) {
        // Local SVIP exposes attempts, not invented server capabilities. A
        // choice is committed only after the audio handler resolves that tier.
        final local = ref.watch(neteaseLocalSvipProvider);
        final fallback = ref.watch(neteaseFallbackEnabledProvider);
        final options = ref.watch(neteasePlaybackOptionsProvider);
        if (local && fallback) {
          return {
            PlatformAudioQuality.standard,
            PlatformAudioQuality.high,
            if (options.lossless) ...[
              PlatformAudioQuality.lossless,
              PlatformAudioQuality.hiRes,
            ],
            // These are official-only attempts; strict replacement rejects
            // downgrades and never substitutes another provider's FLAC for them.
            ...PlatformAudioQuality.values.where((q) => q.neteaseOnly),
          };
        }
        return ref.watch(neteaseMusicRepositoryProvider).qualities(id);
      }
      final payload = await ref
          .watch(musicPlatformApiProvider)
          .get(
            '/audio',
            query: {'hash': id.substring('kugou_'.length)},
            expectedSession: session,
          );
      final result = PlatformQualityCatalog.parse(payload);
      if (ref.mounted) {
        final retained = ref.read(_qualityRetentionsProvider);
        final release = ref.keepAlive().close;
        retained.retain(id, release);
        ref.onDispose(() => retained.forget(id, release));
      }
      return result;
    }, retry: (_, _) => null);

class PlatformQualityState {
  const PlatformQualityState(
    this.preferred, {
    this.switching = false,
    this.switchingTrackId,
  });
  final PlatformAudioQuality preferred;
  final bool switching;
  final String? switchingTrackId;
}

/// Preferences and operation state are shared across every player appearance.
/// The audio handler owns source replacement and stale-command protection.
class PlatformQualityController extends Notifier<PlatformQualityState> {
  static const preferenceKey = 'beta_platform_audio_quality';
  String get _key => ref.read(usesNeteaseProvider)
      ? '${preferenceKey}_netease'
      : preferenceKey;
  @override
  PlatformQualityState build() {
    // Rebuild even when switching between two users of the same platform, so
    // an old in-flight quality change cannot leave the new account busy.
    ref.watch(platformAccountProvider.select((a) => a.value?.ownerId));
    final netease = ref.watch(usesNeteaseProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = PlatformAudioQuality.fromCode(
      prefs.getString(netease ? '${preferenceKey}_netease' : preferenceKey) ??
          prefs.getString(preferenceKey),
    );
    return PlatformQualityState(
      saved == null || (!netease && saved.neteaseOnly)
          ? PlatformAudioQuality.standard
          : saved,
    );
  }

  Future<bool> select(PlatformAudioQuality quality) async {
    if (state.switching) return false;
    final owner = ref.read(platformAccountProvider).value?.ownerId;
    final preference = _key;
    final previous = state.preferred;
    var saved = previous;
    state = PlatformQualityState(
      quality,
      switching: true,
      switchingTrackId: ref.read(currentTrackProvider).id,
    );
    try {
      final applied = await ref
          .read(audioHandlerProvider)
          .refreshCurrentSource();
      // A cancelled/stale request is not an applied choice. Read the audio owner
      // synchronously: the StreamProvider may still hold the previous item.
      if (!applied ||
          !ref.mounted ||
          ref.read(platformAccountProvider).value?.ownerId != owner) {
        return false;
      }
      final handler = ref.read(audioHandlerProvider);
      final actual = handler.trackForId(handler.mediaItem.value?.id ?? '');
      if (actual?.playbackQuality != quality.code) {
        throw const MusicPlatformException('未能切换到所选音质，已保留原音源');
      }
      await ref
          .read(sharedPreferencesProvider)
          .setString(preference, quality.code);
      saved = quality;
      return true;
    } finally {
      if (ref.mounted &&
          ref.read(platformAccountProvider).value?.ownerId == owner) {
        state = PlatformQualityState(saved);
      }
    }
  }
}

final platformQualityProvider =
    NotifierProvider<PlatformQualityController, PlatformQualityState>(
      PlatformQualityController.new,
    );
