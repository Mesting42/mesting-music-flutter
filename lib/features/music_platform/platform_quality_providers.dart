import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/playback_providers.dart';
import '../../core/persistence/app_preferences.dart';
import 'domain/platform_audio_quality.dart';

class PlatformQualityState {
  const PlatformQualityState(this.preferred, {this.switching = false});
  final PlatformAudioQuality preferred;
  final bool switching;
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
    state = PlatformQualityState(quality, switching: true);
    try {
      await ref
          .read(sharedPreferencesProvider)
          .setString(preferenceKey, quality.code);
      return await ref.read(audioHandlerProvider).refreshCurrentSource();
    } finally {
      if (ref.mounted) state = PlatformQualityState(quality);
    }
  }
}

final platformQualityProvider =
    NotifierProvider<PlatformQualityController, PlatformQualityState>(
      PlatformQualityController.new,
    );
