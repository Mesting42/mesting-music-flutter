import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/track.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../experience/presentation/editorial_widgets.dart';
import '../../search/search_providers.dart';
import '../data/platform_explore.dart';
import '../music_platform_providers.dart';
import '../platform_recommendation_providers.dart';
import 'platform_design.dart';

final platformExploreRepositoryProvider = Provider<PlatformExploreRepository>(
  (ref) => PlatformExploreRepository(ref.watch(musicPlatformApiProvider)),
);
final platformExploreProvider =
    FutureProvider.family<List<PlatformExploreItem>, PlatformExploreKind>((
      ref,
      kind,
    ) async {
      await ref.watch(platformAccountProvider.future);
      return ref.watch(platformExploreRepositoryProvider).list(kind);
    });

/// Search history, real keyword boards, then upstream music exploration. A
/// keyword opens search; it is never presented as a directly playable song.
class PlatformSearchLanding extends ConsumerStatefulWidget {
  const PlatformSearchLanding({required this.onSearch, super.key});
  final ValueChanged<String> onSearch;
  @override
  ConsumerState<PlatformSearchLanding> createState() =>
      _PlatformSearchLandingState();
}

class _PlatformSearchLandingState extends ConsumerState<PlatformSearchLanding> {
  int _board = 0, _page = 0;
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(musicSearchControllerProvider).recentSearches;
    final boards = ref.watch(platformHotSearchProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 190),
      children: [
        if (history.isNotEmpty) ...[
          Row(
            children: [
              Text('搜索历史', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => ref
                    .read(musicSearchControllerProvider.notifier)
                    .clearRecentSearches(),
                child: const Text('清空'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final word in history)
                ActionChip(
                  label: Text(word),
                  onPressed: () => widget.onSearch(word),
                ),
            ],
          ),
          const SizedBox(height: 22),
        ],
        Row(
          children: [
            Text('热门搜索', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(
              tooltip: '刷新热门搜索',
              onPressed: () => ref.invalidate(platformHotSearchProvider),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        boards.when(
          loading: () => const PlatformFeedbackState(loading: true),
          error: (_, _) => EditorialEmpty(
            '热搜暂时无法加载',
            onRetry: () => ref.invalidate(platformHotSearchProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return EditorialEmpty(
                '平台暂未返回热搜',
                onRetry: () => ref.invalidate(platformHotSearchProvider),
              );
            }
            final index = _board.clamp(0, items.length - 1);
            final words = items[index].keywords;
            final pages = (words.length / 10).ceil();
            final page = _page.clamp(0, pages - 1);
            return PlatformPanel(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        ChoiceChip(
                          label: Text(items[i].name),
                          selected: i == index,
                          onSelected: (_) => setState(() {
                            _board = i;
                            _page = 0;
                          }),
                        ),
                    ],
                  ),
                  for (
                    var i = page * 10;
                    i < words.length && i < (page + 1) * 10;
                    i++
                  )
                    ListTile(
                      leading: SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      title: Text(words[i]),
                      onTap: () => widget.onSearch(words[i]),
                    ),
                  if (pages > 1)
                    TextButton(
                      onPressed: () =>
                          setState(() => _page = (page + 1) % pages),
                      child: Text('换一页 · ${page + 1}/$pages'),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        for (final kind in PlatformExploreKind.values)
          _ExploreSection(kind: kind),
      ],
    );
  }
}

class _ExploreSection extends ConsumerWidget {
  const _ExploreSection({required this.kind});
  final PlatformExploreKind kind;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(platformExploreProvider(kind))
      .when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            children: [
              Expanded(child: Text('${kind.label}暂时未能加载')),
              TextButton(
                onPressed: () => ref.invalidate(platformExploreProvider(kind)),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      kind.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (kind == PlatformExploreKind.scene)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in items)
                            Chip(label: Text(item.title)),
                        ],
                      )
                    else
                      SizedBox(
                        height: 182,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return SizedBox(
                              width: 132,
                              child: InkWell(
                                onTap:
                                    kind == PlatformExploreKind.theme ||
                                        item.id.isEmpty
                                    ? null
                                    : () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              _ExploreSongsPage(item: item),
                                        ),
                                      ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: ArtworkImage(
                                        uri: item.cover,
                                        width: 132,
                                        height: 132,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelLarge,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
      );
}

class _ExploreSongsPage extends ConsumerStatefulWidget {
  const _ExploreSongsPage({required this.item});
  final PlatformExploreItem item;
  @override
  ConsumerState<_ExploreSongsPage> createState() => _ExploreSongsPageState();
}

class _ExploreSongsPageState extends ConsumerState<_ExploreSongsPage> {
  final _tracks = <Track>[];
  int _page = 0;
  bool _busy = false, _more = true;
  String? _error;
  String? _owner;
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    if (_busy || !_more) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final owner = ref.read(platformAccountProvider).value?.userId;
    try {
      final fresh = await ref
          .read(platformExploreRepositoryProvider)
          .tracks(widget.item, page: _page + 1);
      if (!mounted ||
          ref.read(platformAccountProvider).value?.userId != owner) {
        return;
      }
      setState(() {
        final ids = _tracks.map((e) => e.id).toSet();
        final additions = fresh.where((e) => ids.add(e.id)).toList();
        _tracks.addAll(additions);
        _page++;
        _more = fresh.length >= 30 && additions.isNotEmpty;
        _owner = owner;
      });
    } catch (_) {
      if (mounted) setState(() => _error = '歌曲加载失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(platformAccountProvider).value?.userId;
    if (_owner != null && account != _owner) {
      return PlatformPageFrame(
        title: widget.item.title,
        child: const EditorialEmpty('账号已变化，请返回后重新打开'),
      );
    }
    return PlatformPageFrame(
      title: widget.item.title,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 190),
        children: [
          for (final track in _tracks)
            EditorialTrackRow(track: track, contextTracks: _tracks),
          if (_busy) const PlatformFeedbackState(loading: true),
          if (_error != null || _more)
            TextButton(
              onPressed: _busy ? null : _load,
              child: Text(_error ?? '加载更多'),
            ),
          if (!_busy && !_more && _tracks.isEmpty)
            const EditorialEmpty('平台暂未返回歌曲'),
        ],
      ),
    );
  }
}
