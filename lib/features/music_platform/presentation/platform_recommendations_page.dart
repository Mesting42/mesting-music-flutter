import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/track.dart';
import '../../experience/presentation/editorial_widgets.dart';
import '../data/platform_recommendations.dart';
import '../music_platform_providers.dart';
import '../platform_catalog_providers.dart';
import '../platform_recommendation_providers.dart';
import 'platform_account_page.dart';
import 'platform_design.dart';
import 'platform_feedback.dart';
import '../../../shared/widgets/automatic_song_paging.dart';
import '../../player/presentation/beta_playback_actions.dart';

/// Original md3Music's four discovery modules, rendered in the approved Mesting
/// visual language. Platform providers own ordering and provenance, not widgets.
class PlatformRecommendationHome extends ConsumerWidget {
  const PlatformRecommendationHome({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => PlatformStyle(
    child: EditorialScroll(
      onRefresh: () async {
        ref.invalidate(platformFmProvider);
        ref.invalidate(platformDailyProvider);
        ref.invalidate(platformDiscoveryProvider);
        ref.invalidate(platformNewSongsProvider);
        await ref
            .read(platformDiscoveryProvider.future)
            .then<void>((_) {}, onError: (Object _) {});
      },
      children: const [
        EditorialHeader('发现'),
        PlatformFmSection(),
        PlatformRecommendedSection(title: '每日推荐'),
        PlatformRecommendedSection(
          title: '刷歌推荐',
          kind: PlatformRecommendationKind.discover,
        ),
        PlatformRecommendedSection(title: '新歌速递', newSongs: true),
      ],
    ),
  );
}

class PlatformFmSection extends ConsumerWidget {
  const PlatformFmSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(platformAccountProvider).value != null;
    final station = ref.watch(platformFmStationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorialSection(
          '私人 FM',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PlatformRecommendationDetail(
                kind: PlatformRecommendationKind.fm,
                title: '私人 FM',
              ),
            ),
          ),
        ),
        if (!signedIn)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PlatformAccountPage(),
                ),
              ),
              icon: const Icon(Icons.login),
              label: const Text('登录酷狗后查看猜你喜欢和实时推荐'),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
            child: Wrap(
              spacing: 8,
              children: [
                for (final option in PlatformFmStation.values)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: station == option,
                    onSelected: (_) => ref
                        .read(platformFmStationProvider.notifier)
                        .select(option),
                  ),
              ],
            ),
          ),
          const PlatformRecommendedSection(
            title: '',
            kind: PlatformRecommendationKind.fm,
          ),
        ],
      ],
    );
  }
}

class PlatformRecommendedSection extends ConsumerWidget {
  const PlatformRecommendedSection({
    required this.title,
    this.kind,
    this.newSongs = false,
    super.key,
  });
  final String title;
  final PlatformRecommendationKind? kind;
  final bool newSongs;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = kind == PlatformRecommendationKind.fm
        ? platformFmProvider
        : kind == PlatformRecommendationKind.discover
        ? platformDiscoveryProvider
        : newSongs
        ? platformNewSongsProvider
        : platformDailyProvider;
    final value = ref.watch(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.isNotEmpty)
          EditorialSection(
            title,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PlatformRecommendationDetail(
                  kind: kind,
                  title: title,
                  newSongs: newSongs,
                ),
              ),
            ),
          ),
        value.when(
          loading: () => const PlatformFeedbackState(loading: true),
          error: (_, _) => EditorialEmpty(
            '暂时无法获取推荐',
            onRetry: () => ref.invalidate(provider),
          ),
          data: (tracks) => tracks.isEmpty
              ? EditorialEmpty(
                  '平台暂未返回内容',
                  onRetry: () => ref.invalidate(provider),
                )
              : Column(
                  children: [
                    for (final track in tracks.take(4))
                      EditorialTrackRow(
                        track: track,
                        contextTracks: tracks,
                        onPlay: () => _play(
                          context,
                          ref,
                          tracks,
                          tracks.indexOf(track),
                          kind,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

Future<void> _play(
  BuildContext context,
  WidgetRef ref,
  List<Track> tracks,
  int index,
  PlatformRecommendationKind? kind,
) async {
  try {
    if (kind != null) {
      if (await playBetaSelection(context, ref, tracks[index])) {
        ref
            .read(platformRecommendationSessionProvider)
            .adoptCurrent(kind, tracks[index]);
      }
    } else {
      await playEditorialTrack(context, ref, tracks[index], tracks);
    }
  } catch (error) {
    if (context.mounted) showPlatformFailure(context, error);
  }
}

class PlatformRecommendationDetail extends ConsumerStatefulWidget {
  const PlatformRecommendationDetail({
    required this.title,
    this.kind,
    this.newSongs = false,
    super.key,
  });
  final String title;
  final PlatformRecommendationKind? kind;
  final bool newSongs;
  @override
  ConsumerState<PlatformRecommendationDetail> createState() =>
      _PlatformRecommendationDetailState();
}

class _PlatformRecommendationDetailState
    extends ConsumerState<PlatformRecommendationDetail> {
  final _extra = <Track>[];
  bool _loading = false, _more = true;
  String? _error;
  String? _baseSignature;
  int _generation = 0;
  Set<String> _baseIds = {};
  Future<void> _load() async {
    if (_loading || !_more) return;
    final generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(platformRecommendationsProvider);
      final fresh = widget.kind == PlatformRecommendationKind.fm
          ? await repository.personalFm(
              ref.read(platformFmStationProvider),
              first: false,
              anchor: _extra.lastOrNull,
            )
          : await repository.discover(more: true);
      if (!mounted || generation != _generation) return;
      setState(() {
        final ids = {..._baseIds, ..._extra.map((e) => e.id)};
        final additions = fresh.where((e) => ids.add(e.id)).toList();
        _extra.addAll(additions);
        _more = additions.isNotEmpty;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _error = '加载失败，点击重试');
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.kind == PlatformRecommendationKind.fm
        ? platformFmProvider
        : widget.kind == PlatformRecommendationKind.discover
        ? platformDiscoveryProvider
        : widget.newSongs
        ? platformNewSongsProvider
        : platformDailyProvider;
    final value = ref.watch(provider);
    final signature =
        '${ref.watch(platformAccountProvider).value?.userId}:${ref.watch(platformFmStationProvider).name}';
    if (_baseSignature != signature) {
      _baseSignature = signature;
      _generation++;
      _loading = false;
      _extra.clear();
      _more = true;
    }
    return PlatformPageFrame(
      title: widget.title,
      child: value.when(
        loading: () => const PlatformFeedbackState(loading: true),
        error: (_, _) =>
            EditorialEmpty('推荐暂时无法读取', onRetry: () => ref.invalidate(provider)),
        data: (base) {
          final merged = <String, Track>{
            for (final t in [...base, ..._extra]) t.id: t,
          };
          final tracks = merged.values.toList();
          _baseIds = base.map((track) => track.id).toSet();
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _generation++;
                _loading = false;
                _extra.clear();
                _more = true;
              });
              ref.invalidate(provider);
              await ref.read(provider.future);
            },
            child: AutomaticSongPaging(
              enabled:
                  widget.kind != null && _more && !_loading && _error == null,
              onLoadMore: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 180),
                itemCount: tracks.length + 1,
                itemBuilder: (context, index) {
                  if (index < tracks.length) {
                    return EditorialTrackRow(
                      track: tracks[index],
                      contextTracks: tracks,
                      onPlay: () =>
                          _play(context, ref, tracks, index, widget.kind),
                    );
                  }
                  if (_loading) {
                    return const PlatformFeedbackState(loading: true);
                  }
                  if (_error != null) {
                    return TextButton(onPressed: _load, child: Text(_error!));
                  }
                  if (tracks.isEmpty) return const EditorialEmpty('平台暂未返回歌曲');
                  return const SizedBox(height: 24);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
