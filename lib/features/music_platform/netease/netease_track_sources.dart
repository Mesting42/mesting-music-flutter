import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../music_platform_providers.dart';

/// These are existing adapters. No additional Kugou account or API is added.
/// A manual choice is scoped to this account/session and recording.
enum NeteaseTrackSource {
  automatic('自动', null),
  official('网易云官方', null),
  kugou('酷狗公开音源', '酷狗公开音源'),
  kuwo('酷我公开音源', '酷我公开音源'),
  bilibili('B站音频', 'B站音频'),
  bilivideo('B站视频音轨', 'B站视频音轨'),
  bugpk('BugPk', 'BugPk · 网易云同曲');

  const NeteaseTrackSource(this.label, this.adapter);
  final String label;
  final String? adapter;
}

final neteaseTrackSourcesProvider =
    NotifierProvider<NeteaseTrackSources, Map<String, NeteaseTrackSource>>(
      NeteaseTrackSources.new,
    );

class NeteaseTrackSources extends Notifier<Map<String, NeteaseTrackSource>> {
  @override
  Map<String, NeteaseTrackSource> build() {
    ref.watch(
      platformAccountProvider.select((a) => (a.value?.ownerId, a.value?.token)),
    );
    return const {};
  }

  void select(String trackId, NeteaseTrackSource source) {
    state = {...state, trackId: source};
  }
}
