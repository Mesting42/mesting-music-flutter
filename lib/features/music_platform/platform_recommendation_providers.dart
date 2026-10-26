import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/playback_providers.dart';
import '../../core/persistence/app_preferences.dart';
import '../../shared/models/track.dart';
import '../library/library_providers.dart';
import 'data/platform_recommendations.dart';
import 'music_platform_providers.dart';

final platformRecommendationsProvider = Provider<PlatformRecommendations>((
  ref,
) {
  final account = ref.watch(platformAccountProvider).value;
  final repository = PlatformRecommendations(
    ref.watch(musicPlatformApiProvider),
    ref.watch(sharedPreferencesProvider),
    account,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final platformFmStationProvider =
    NotifierProvider<PlatformFmStationController, PlatformFmStation>(
      PlatformFmStationController.new,
    );

class PlatformFmStationController extends Notifier<PlatformFmStation> {
  @override
  PlatformFmStation build() {
    final value = ref
        .watch(sharedPreferencesProvider)
        .getString('beta7_fm_station');
    return PlatformFmStation.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PlatformFmStation.heart,
    );
  }

  Future<void> select(PlatformFmStation station) async {
    state = station;
    await ref
        .read(sharedPreferencesProvider)
        .setString('beta7_fm_station', station.name);
    final session = ref.read(platformRecommendationSessionProvider);
    if (session.kind == PlatformRecommendationKind.fm) {
      final tracks = await ref.read(platformFmProvider.future);
      if (state == station) {
        await session.start(PlatformRecommendationKind.fm, tracks, 0);
      }
    }
  }
}

final platformFmProvider = FutureProvider<List<Track>>((ref) async {
  await ref.watch(platformAccountProvider.future);
  final station = ref.watch(platformFmStationProvider);
  return ref.watch(platformRecommendationsProvider).personalFm(station);
});
final platformHotSearchProvider = FutureProvider<List<PlatformHotSearchBoard>>((
  ref,
) async {
  await ref.watch(platformAccountProvider.future);
  return ref.watch(platformRecommendationsProvider).hotSearch();
});

/// Queue provenance owns refill and feedback. Fetching an FM preview alone
/// never turns an ordinary song/playlist into an FM session. Account changes
/// dispose this object and stale requests cannot affect the replacement owner.
class PlatformRecommendationSession {
  PlatformRecommendationSession(this.ref, this.repository);
  final Ref ref;
  final PlatformRecommendations repository;
  PlatformRecommendationKind? kind;
  PlatformFmStation station = PlatformFmStation.heart;
  final _owned = <String>{};
  final _reported = <String>{};
  String? _lastId;
  int _seconds = 0;
  Track? _lastTrack;
  bool _disposed = false;
  int _generation = 0;
  bool ownsFmTrack(String id) =>
      kind == PlatformRecommendationKind.fm && _owned.contains(id);

  /// An explicit search/library queue is not an FM stream, even when it happens
  /// to contain the same recording as an earlier FM recommendation.
  void end() {
    _flush();
    kind = null;
    _generation++;
    ref.read(audioHandlerProvider).invalidateRadioRecommendations();
  }

  Future<void> start(
    PlatformRecommendationKind source,
    List<Track> tracks,
    int index,
  ) async {
    if (tracks.isEmpty || _disposed) return;
    _flush();
    final generation = ++_generation;
    kind = source;
    station = ref.read(platformFmStationProvider);
    _owned
      ..clear()
      ..addAll(tracks.map((e) => e.id));
    _reported.clear();
    _lastTrack = null;
    _lastId = null;
    _seconds = 0;
    final handler = ref.read(audioHandlerProvider);
    handler.invalidateRadioRecommendations();
    await handler.replaceQueue(
      tracks,
      initialIndex: index,
      recommendationContext: true,
    );
    if (!_disposed && generation == _generation) {
      unawaited(handler.prefetchRadioTracks(force: true));
    }
  }

  Future<List<Track>> loadMore(Set<String> excluded) async {
    if (_disposed) return const [];
    final source = kind;
    final generation = _generation;
    final tracks = source == null
        ? await repository.personalFm(
            PlatformFmStation.heart,
            first: false,
            anchor: ref.read(currentTrackProvider),
          )
        : source == PlatformRecommendationKind.fm
        ? await repository.personalFm(station, first: false, anchor: _lastTrack)
        : await repository.discover(more: true);
    if (_disposed || source != kind || generation != _generation) {
      return const [];
    }
    final fresh = tracks
        .where(
          (track) => !_owned.contains(track.id) && !excluded.contains(track.id),
        )
        .toList();
    _owned.addAll(fresh.map((e) => e.id));
    return fresh;
  }

  /// The single-song UI action has already preserved/replaced the user's tail.
  /// Attach FM provenance without adding the rest of the preview page's songs.
  void adoptCurrent(PlatformRecommendationKind source, Track track) {
    if (_disposed) return;
    _flush();
    _generation++;
    kind = source;
    station = ref.read(platformFmStationProvider);
    _owned
      ..clear()
      ..add(track.id);
    _reported.clear();
    _lastTrack = track;
    _lastId = track.id;
    _seconds = 0;
    final handler = ref.read(audioHandlerProvider);
    handler.invalidateRadioRecommendations();
    unawaited(handler.prefetchRadioTracks(force: true));
  }

  void observe(Track? track, Duration position, {bool completed = false}) {
    if (_disposed) return;
    if (track?.id != _lastId) {
      _flush();
      _lastTrack = track;
      _lastId = track?.id;
      _seconds = 0;
      // Explicitly playing a song outside the owned batch ends the FM stream.
      if (kind != null && track != null && !_owned.contains(track.id)) {
        end();
      }
    }
    _seconds = position.inSeconds;
    if (completed) _flush(complete: true);
  }

  void _flush({bool complete = false}) {
    final track = _lastTrack;
    if (kind != PlatformRecommendationKind.fm ||
        track == null ||
        !_owned.contains(track.id) ||
        !_reported.add(track.id)) {
      return;
    }
    // No duplicate play report when the natural completion and next-track
    // notification arrive together. Match upstream's two-second tolerance.
    final over =
        complete ||
        (track.duration.inSeconds > 0 &&
            _seconds >= track.duration.inSeconds - 2);
    unawaited(
      repository
          .feedback(track, 'play', seconds: _seconds, complete: over)
          .catchError((Object _) => <Track>[]),
    );
  }

  Future<void> favorite(Track track, bool removing) async {
    if (_disposed ||
        kind != PlatformRecommendationKind.fm ||
        !_owned.contains(track.id)) {
      return;
    }
    try {
      await repository.feedback(track, removing ? 'cancel_red' : 'click_red');
    } catch (_) {
      /* Library writes already own visible success/error feedback. */
    }
  }

  Future<void> dislike(Track track) async {
    if (kind != PlatformRecommendationKind.fm || !_owned.contains(track.id)) {
      return;
    }
    try {
      final replacements = await repository.feedback(track, 'garbage');
      if (_disposed) return;
      if (replacements.isNotEmpty) {
        await start(PlatformRecommendationKind.fm, replacements, 0);
        return;
      }
    } catch (_) {
      /* A rejected feedback ping must not trap the disliked song. */
    }
    if (!_disposed) await ref.read(audioHandlerProvider).skipToNext();
  }

  void dispose() {
    _flush();
    _disposed = true;
  }
}

final platformRecommendationSessionProvider =
    Provider<PlatformRecommendationSession>((ref) {
      final session = PlatformRecommendationSession(
        ref,
        ref.watch(platformRecommendationsProvider),
      );
      ref.onDispose(session.dispose);
      return session;
    });

/// Listen once at application scope, independent of which player is visible.
/// Completion/favorite reports apply only to the active FM queue's provenance.
final platformRecommendationBindingProvider = Provider<void>((ref) {
  final session = ref.watch(platformRecommendationSessionProvider);
  final handler = ref.read(audioHandlerProvider);
  handler.configureRadioTrackLoader(
    session.loadMore,
    preserveServerOrder: true,
    onExplicitPlayback: session.end,
    continueAfterExplicitQueue: true,
  );
  ref.listen(currentMediaItemProvider, (_, item) {
    final track = item.value == null
        ? null
        : handler.trackForId(item.value!.id);
    session.observe(track, Duration.zero);
  });
  ref.listen(positionProvider, (_, position) {
    session.observe(
      handler.trackForId(handler.mediaItem.value?.id ?? ''),
      position.value ?? Duration.zero,
    );
  });
  ref.listen(playbackStateProvider, (_, state) {
    if (state.value?.processingState == AudioProcessingState.completed) {
      session.observe(
        handler.trackForId(handler.mediaItem.value?.id ?? ''),
        handler.playbackState.value.updatePosition,
        completed: true,
      );
    }
  });
  ref.listen(favoriteTracksProvider, (previous, next) {
    if (previous?.hasValue != true || !next.hasValue) return;
    final old = {for (final t in previous!.value!) t.id: t};
    final fresh = {for (final t in next.value!) t.id: t};
    for (final id in {...old.keys, ...fresh.keys}) {
      if (old.containsKey(id) != fresh.containsKey(id)) {
        unawaited(session.favorite(fresh[id] ?? old[id]!, old.containsKey(id)));
      }
    }
  });
});
