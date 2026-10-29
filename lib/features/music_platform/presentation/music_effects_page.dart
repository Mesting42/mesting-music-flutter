import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/music_equalizer_providers.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
import '../../../shared/widgets/beta_bottom_search.dart';
import '../../../shared/widgets/beta_page_search_layout.dart';
import '../../../shared/widgets/beta_glass_scroll_body.dart';
import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../../../shared/widgets/music_feature_page.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../data/platform_effects_repository.dart';
import '../platform_effects_providers.dart';
import '../platform_backend_providers.dart';
import '../../settings/presentation/music_equalizer_page.dart';

class MusicEffectsPage extends ConsumerStatefulWidget {
  const MusicEffectsPage({super.key});
  @override
  ConsumerState<MusicEffectsPage> createState() => _MusicEffectsPageState();
}

class _MusicEffectsPageState extends ConsumerState<MusicEffectsPage> {
  final _scroll = ScrollController();
  late final _bottomSearch = BetaPageSearchController(
    hintText: '筛选已加载的音效',
    onSubmitted: (_) => setState(() {}),
    onCleared: () => setState(() {}),
    onChanged: (_) => setState(() {}),
  );
  TextEditingController get _search => _bottomSearch.text;
  MusicEffectsCatalog _catalog = MusicEffectsCatalog.community;
  final List<MusicSoundEffect> _items = [];
  int _generation = 0, _page = 0;
  bool _loading = false, _more = true, _newest = false;
  String? _error, _brandId, _brandName;
  @override
  void initState() {
    super.initState();
    _scroll.addListener(_nearEnd);
    Future.microtask(() => _load(reset: true));
  }

  @override
  void dispose() {
    _generation++;
    _scroll.dispose();
    _bottomSearch.dispose();
    super.dispose();
  }

  void _nearEnd() {
    if (_scroll.hasClients &&
        _scroll.position.extentAfter < 360 &&
        !_loading &&
        _more &&
        _error == null) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (ref.read(usesNeteaseProvider)) return;
    if (!mounted || (_loading && !reset)) return;
    final generation = reset ? ++_generation : _generation;
    final page = reset ? 1 : _page + 1;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _items.clear();
        _page = 0;
        _more = true;
      }
    });
    try {
      final result = await ref
          .read(platformEffectsRepositoryProvider)
          .list(_catalog, page: page, brandId: _brandId, newest: _newest);
      if (!mounted || generation != _generation) return;
      setState(() {
        final seen = _items.map((e) => e.id).toSet();
        _items.addAll(result.items.where((e) => seen.add(e.id)));
        _page = page;
        _more = result.hasMore;
        _loading = false;
      });
    } on Object {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _error = '音效目录暂时无法加载，请重试。';
        });
      }
    }
  }

  Future<void> _chooseBrand() async {
    try {
      final brands = await ref.read(platformEffectsRepositoryProvider).brands();
      if (!mounted) return;
      final chosen = await showLiquidGlassBottomSheet<MusicEffectBrand>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => SizedBox(
          height: MediaQuery.sizeOf(context).height * .65,
          child: Material(
            type: MaterialType.transparency,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: Text(
                    '耳机品牌',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                ListTile(
                  title: const Text('当前设备匹配'),
                  onTap: () => Navigator.pop(
                    context,
                    const MusicEffectBrand('', '当前设备匹配'),
                  ),
                ),
                for (final brand in brands)
                  ListTile(
                    title: Text(brand.name),
                    trailing: const Icon(
                      CupertinoIcons.chevron_forward,
                      size: 16,
                    ),
                    onTap: () => Navigator.pop(context, brand),
                  ),
                if (brands.isEmpty) const Text('暂未提供品牌列表。'),
              ],
            ),
          ),
        ),
      );
      if (chosen != null && mounted) {
        setState(() {
          _brandId = chosen.id.isEmpty ? null : chosen.id;
          _brandName = chosen.name;
        });
        await _load(reset: true);
      }
    } on Object {
      if (mounted) setState(() => _error = '耳机品牌加载失败，请重试。');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(usesNeteaseProvider)) return const MusicEqualizerPage();
    final equalizer = ref.watch(musicEqualizerProvider);
    final scheme = Theme.of(context).colorScheme;
    final query = _search.text.trim().toLowerCase();
    final items = _items
        .where(
          (e) =>
              query.isEmpty ||
              '${e.name} ${e.author} ${e.category}'.toLowerCase().contains(
                query,
              ),
        )
        .toList();
    return BetaPageSearchLayout(
      controller: _bottomSearch,
      child: MusicFeaturePage(
        title: '音效',
        child: ListenableBuilder(
          listenable: equalizer,
          builder: (context, _) => BetaGlassScrollBody(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
            children: [
              CupertinoSlidingSegmentedControl<MusicEffectsCatalog>(
                groupValue: _catalog,
                children: const {
                  MusicEffectsCatalog.community: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('社区'),
                  ),
                  MusicEffectsCatalog.earphone: Text('耳机'),
                  MusicEffectsCatalog.artist: Text('明星'),
                },
                onValueChanged: (value) {
                  if (value == null || value == _catalog) return;
                  setState(() {
                    _catalog = value;
                    _brandId = null;
                    _brandName = null;
                  });
                  _load(reset: true);
                },
              ),
              const SizedBox(height: 18),
              const SizedBox(height: 14),
              if (_catalog == MusicEffectsCatalog.earphone)
                Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _chooseBrand,
                    child: Text('${_brandName ?? '当前设备匹配'}  ›'),
                  ),
                ),
              if (_catalog == MusicEffectsCatalog.community)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final newest in [false, true])
                      ChoiceChip(
                        label: Text(newest ? '最新' : '热门'),
                        selected: newest == _newest,
                        onSelected: (_) {
                          setState(() => _newest = newest);
                          _load(reset: true);
                        },
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              if (equalizer.state.effectName != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equalizer.state.enabled
                            ? '当前音效 · ${equalizer.state.effectName}'
                            : '已保存音效 · ${equalizer.state.effectName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '均衡预设：${equalizer.state.preset}${equalizer.state.bound && equalizer.state.enabled ? ' · 已生效' : ' · 等待开启或播放'}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: equalizer.clearEffect,
                        child: const Text('取消音效'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                '沿用原版的免费音效目录与预设映射。应用时会开启均衡器，并保存对应的本机均衡预设。',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              if (equalizer.state.message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    equalizer.state.message!,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              for (final effect in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // The catalogue's icon_url/model_icon/logo is the exact
                      // official per-effect artwork, never inferred from an EQ
                      // category. The common image boundary sizes decodes and
                      // retains a bounded persistent cache and failure state.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ArtworkImage(
                          uri: effect.cover,
                          width: 54,
                          height: 54,
                          fit: BoxFit.contain,
                          retryOnNetworkError: true,
                          persistentNetworkCacheKey:
                              'kugou-effect-${effect.id}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effect.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                effect.author,
                                effect.category,
                              ].where((s) => s.isNotEmpty).join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '预设：${effect.preset}',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        container: true,
                        button: true,
                        label: '应用${effect.name}音效',
                        onTap: equalizer.state.binding
                            ? null
                            : () => equalizer.selectPreset(
                                effect.preset,
                                effectId: effect.id,
                                effectName: effect.name,
                              ),
                        selected:
                            equalizer.state.enabled &&
                            equalizer.state.effectId == effect.id,
                        enabled: !equalizer.state.binding,
                        excludeSemantics: true,
                        child: Tooltip(
                          message: '应用${effect.name}音效',
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            onPressed: equalizer.state.binding
                                ? null
                                : () => equalizer.selectPreset(
                                    effect.preset,
                                    effectId: effect.id,
                                    effectName: effect.name,
                                  ),
                            child: Icon(
                              equalizer.state.enabled &&
                                      equalizer.state.effectId == effect.id
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.plus_circle,
                              size: 27,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: BetaActivityIndicator()),
                ),
              if (_error != null)
                MusicFeatureMessage(
                  message: _error!,
                  onRetry: () => _load(reset: _items.isEmpty),
                ),
              if (!_loading && _error == null && items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    query.isEmpty ? '当前目录暂未返回可用的免费音效。' : '已加载的音效中没有匹配项。',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
              if (!_loading && _more)
                TextButton(
                  onPressed: () => _load(),
                  child: const Text('加载更多音效'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
