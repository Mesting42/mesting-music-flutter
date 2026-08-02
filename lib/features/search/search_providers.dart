import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/persistence/app_preferences.dart';
import '../../shared/models/track.dart';
import 'data/audius_music_source.dart';
import 'data/hot_music_repository.dart';
import 'data/jamendo_music_source.dart';
import 'data/kugou_music_source.dart';
import 'data/music_search_repository.dart';
import 'data/netease_music_source.dart';
import 'domain/music_source.dart';

final musicSearchHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final kugouMusicSourceProvider = Provider<KugouMusicSource>((ref) {
  return KugouMusicSource(ref.watch(musicSearchHttpClientProvider));
});

final onlineMusicSourcesProvider = Provider<List<MusicSource>>((ref) {
  final client = ref.watch(musicSearchHttpClientProvider);
  return List<MusicSource>.unmodifiable([
    ref.watch(kugouMusicSourceProvider),
    NeteaseMusicSource(client),
    AudiusMusicSource(client),
    JamendoMusicSource(client),
  ]);
});

final musicSearchRepositoryProvider = Provider<MusicSearchRepository>((ref) {
  final repository = MusicSearchRepository(
    localTracks: const <Track>[],
    sources: ref.watch(onlineMusicSourcesProvider),
  );
  ref.onDispose(repository.cancelActiveSearch);
  return repository;
});

final hotMusicRepositoryProvider = Provider<HotMusicRepository>((ref) {
  final source = ref.watch(kugouMusicSourceProvider);
  return HotMusicRepository(
    rankingLoader: ({int limit = 9}) => source.hotRanking(limit: limit),
    popularRankingLoader: ({int limit = 9}) =>
        source.ranking(rankId: '82831', sourceLabel: '酷狗网络热歌榜', limit: limit),
    risingRankingLoader: ({int limit = 9}) =>
        source.ranking(rankId: '6666', sourceLabel: '酷狗飙升榜', limit: limit),
    preferences: ref.watch(sharedPreferencesProvider),
    localTracks: const <Track>[],
  );
});

final hotMusicControllerProvider =
    AsyncNotifierProvider<HotMusicController, HotMusicSnapshot>(
      HotMusicController.new,
    );

class HotMusicController extends AsyncNotifier<HotMusicSnapshot> {
  @override
  Future<HotMusicSnapshot> build() {
    return ref.watch(hotMusicRepositoryProvider).load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<HotMusicSnapshot>();
    state = await AsyncValue.guard(
      () => ref.read(hotMusicRepositoryProvider).load(forceRefresh: true),
    );
  }
}

final musicSearchControllerProvider =
    NotifierProvider<MusicSearchController, MusicSearchState>(
      MusicSearchController.new,
    );

class MusicSearchController extends Notifier<MusicSearchState> {
  static const _recentSearchesKey = 'music_recent_searches';
  static const _debounceDuration = Duration(milliseconds: 450);
  static const _maxRecentSearches = 8;

  Timer? _debounce;
  var _generation = 0;

  @override
  MusicSearchState build() {
    final repository = ref.read(musicSearchRepositoryProvider);
    ref.onDispose(() {
      _debounce?.cancel();
      repository.cancelActiveSearch();
    });
    final preferences = ref.watch(sharedPreferencesProvider);
    return MusicSearchState(
      recentSearches: preferences.getStringList(_recentSearchesKey) ?? const [],
    );
  }

  void setQuery(String rawQuery) {
    final query = rawQuery.trim();
    _debounce?.cancel();
    _generation += 1;
    ref.read(musicSearchRepositoryProvider).cancelActiveSearch();

    if (query.isEmpty) {
      state = state.copyWith(
        query: '',
        localTracks: const [],
        onlineTracks: const [],
        warnings: const [],
        isLoading: false,
        fromCache: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      query: query,
      localTracks: const [],
      onlineTracks: const [],
      isLoading: true,
      fromCache: false,
      clearError: true,
      warnings: const [],
    );
    final generation = _generation;
    _debounce = Timer(_debounceDuration, () => _search(query, generation));
  }

  Future<void> submit(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return;
    }
    _debounce?.cancel();
    _generation += 1;
    ref.read(musicSearchRepositoryProvider).cancelActiveSearch();
    state = state.copyWith(
      query: query,
      localTracks: const [],
      onlineTracks: const [],
      isLoading: true,
      fromCache: false,
      clearError: true,
      warnings: const [],
    );
    await _search(query, _generation);
  }

  Future<void> retry() => submit(state.query);

  void removeRecentSearch(String query) {
    final recent = [...state.recentSearches]..remove(query);
    _saveRecentSearches(recent);
  }

  void clearRecentSearches() => _saveRecentSearches(const []);

  Future<void> _search(String query, int generation) async {
    try {
      final result = await ref
          .read(musicSearchRepositoryProvider)
          .search(query);
      if (generation != _generation) {
        return;
      }
      _rememberQuery(query);
      state = state.copyWith(
        query: result.query,
        localTracks: result.localTracks,
        onlineTracks: result.onlineTracks,
        warnings: result.warnings,
        isLoading: false,
        fromCache: result.fromCache,
        clearError: true,
      );
    } on http.RequestAbortedException {
      // A newer query superseded this request. Its state is already visible.
    } on MusicSearchException catch (error) {
      if (generation != _generation) {
        return;
      }
      state = state.copyWith(
        localTracks: _localMatches(query),
        onlineTracks: const [],
        warnings: const [],
        isLoading: false,
        fromCache: false,
        errorMessage: error.message,
      );
    } on Object {
      if (generation != _generation) {
        return;
      }
      state = state.copyWith(
        localTracks: _localMatches(query),
        onlineTracks: const [],
        warnings: const [],
        isLoading: false,
        fromCache: false,
        errorMessage: '搜索暂时不可用，请稍后重试',
      );
    }
  }

  List<Track> _localMatches(String query) {
    return const <Track>[];
  }

  void _rememberQuery(String query) {
    final recent = [...state.recentSearches]
      ..remove(query)
      ..insert(0, query);
    if (recent.length > _maxRecentSearches) {
      recent.removeRange(_maxRecentSearches, recent.length);
    }
    _saveRecentSearches(recent);
  }

  void _saveRecentSearches(List<String> recent) {
    final immutable = List<String>.unmodifiable(recent);
    state = state.copyWith(recentSearches: immutable);
    ref
        .read(sharedPreferencesProvider)
        .setStringList(_recentSearchesKey, immutable);
  }
}

class MusicSearchState {
  const MusicSearchState({
    this.query = '',
    this.localTracks = const [],
    this.onlineTracks = const [],
    this.recentSearches = const [],
    this.warnings = const [],
    this.isLoading = false,
    this.fromCache = false,
    this.errorMessage,
  });

  final String query;
  final List<Track> localTracks;
  final List<Track> onlineTracks;
  final List<String> recentSearches;
  final List<String> warnings;
  final bool isLoading;
  final bool fromCache;
  final String? errorMessage;

  bool get hasResults => localTracks.isNotEmpty || onlineTracks.isNotEmpty;

  MusicSearchState copyWith({
    String? query,
    List<Track>? localTracks,
    List<Track>? onlineTracks,
    List<String>? recentSearches,
    List<String>? warnings,
    bool? isLoading,
    bool? fromCache,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MusicSearchState(
      query: query ?? this.query,
      localTracks: localTracks ?? this.localTracks,
      onlineTracks: onlineTracks ?? this.onlineTracks,
      recentSearches: recentSearches ?? this.recentSearches,
      warnings: warnings ?? this.warnings,
      isLoading: isLoading ?? this.isLoading,
      fromCache: fromCache ?? this.fromCache,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
