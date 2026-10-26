import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/playback_providers.dart';
import '../../core/persistence/app_preferences.dart';
import 'domain/platform_audio_quality.dart';
import 'data/platform_quality_catalog.dart';
import 'music_platform_providers.dart';

final platformSongQualitiesProvider = FutureProvider.autoDispose
    .family<Set<PlatformAudioQuality>, String>((ref, id) async {
      final session = await ref.watch(platformAccountProvider.future);
      final payload = await ref
          .watch(musicPlatformApiProvider)
          .get(
            '/audio',
            query: {'hash': id.substring('kugou_'.length)},
            expectedSession: session,
          );
      return PlatformQualityCatalog.parse(payload);
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
  @override
  PlatformQualityState build() => PlatformQualityState(
    PlatformAudioQuality.fromCode(
          ref.watch(sharedPreferencesProvider).getString(preferenceKey),
        ) ??
        PlatformAudioQuality.standard,
  );

  Future<bool> select(PlatformAudioQuality quality) async {
    if (state.switching) return false;
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
      await ref
          .read(sharedPreferencesProvider)
          .setString(preferenceKey, quality.code);
      saved = quality;
      return applied;
    } finally {
      if (ref.mounted) state = PlatformQualityState(saved);
    }
  }
}

final platformQualityProvider =
    NotifierProvider<PlatformQualityController, PlatformQualityState>(
      PlatformQualityController.new,
    );
