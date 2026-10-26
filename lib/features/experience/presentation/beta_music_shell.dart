import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../shared/widgets/beta_edge_back.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/layout/adaptive_layout.dart';
import '../../player/presentation/music_navigation.dart';
import '../../search/presentation/music_search_page.dart';
import '../../search/search_providers.dart';
import '../../themes/music_theme_background.dart';
import 'beta_bottom_bar.dart';
import 'floating_playback_pill.dart';
import 'player_chrome_reveal.dart';

/// The official Apple Music GlassScaffold/searchable-tab/accessory composition
/// is the shell, not an overlay of independently positioned imitation pills.
/// Product navigation/search/audio stay behind their existing contracts.
class BetaMusicShell extends ConsumerStatefulWidget {
  const BetaMusicShell({
    required this.child,
    required this.location,
    this.navigationOwner,
    this.chromeVisible = true,
    super.key,
  });
  final Widget child;
  final String location;
  final int? navigationOwner;
  final bool chromeVisible;
  @override
  ConsumerState<BetaMusicShell> createState() => _BetaMusicShellState();
}

class _BetaMusicShellState extends ConsumerState<BetaMusicShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _searchMotion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 240),
  );
  final _searchText = TextEditingController();
  final _focus = FocusNode();
  final _positions = <String, ScrollPosition>{};
  bool _mini = false, _searching = false, _focused = false;
  bool _hasOpenedSearch = false;
  bool _searchBeforeOverlay = false;
  late int _selected = musicBottomNavigationIndexForLocation(widget.location);

  static int? _rootTab(String location) => switch (location) {
    '/music/recommend' => 0,
    '/music' => 1,
    '/music/library' => 2,
    '/profile' => 3,
    _ => null,
  };

  void _backSearch() {
    final search = ref.read(musicSearchControllerProvider);
    if (search.query.isNotEmpty) {
      _searchText.clear();
      _focus.unfocus();
      ref.read(musicSearchControllerProvider.notifier).setQuery('');
    } else {
      _search(false);
    }
  }

  @override
  void dispose() {
    _searchMotion.dispose();
    _searchText.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BetaMusicShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      // Detail paths describe content, not the tab that opened it. Only an
      // explicit root destination changes ownership of the persistent bar.
      _selected = _rootTab(widget.location) ?? _selected;
      // Overlay routes retain the mounted glass bar and its current geometry.
      // Re-entering a tab must not replay a fresh accessory entrance.
      if (_rootTab(widget.location) != null &&
          _rootTab(oldWidget.location) != null) {
        _mini = false;
      }
      if (oldWidget.chromeVisible && !widget.chromeVisible) {
        _searchBeforeOverlay = _searching;
        _searching = false;
      } else if (!oldWidget.chromeVisible && widget.chromeVisible) {
        _searching = _searchBeforeOverlay;
        _searchBeforeOverlay = false;
      } else {
        _searching = false;
      }
      _focus.unfocus();
      _searching ? _searchMotion.forward() : _searchMotion.reverse();
    }
  }

  void _search(bool active) {
    setState(() {
      _searching = active;
      if (!active) _mini = false;
      if (active) _hasOpenedSearch = true;
      if (!active) _focused = false;
    });
    _searching ? _searchMotion.forward() : _searchMotion.reverse();
    if (!active) _focus.unfocus();
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    _searchText.text = text;
    ref.read(musicSearchControllerProvider.notifier).submit(text);
    _focus.unfocus();
  }

  bool _scroll(ScrollNotification notification) {
    if (!widget.chromeVisible ||
        _searching ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final position = Scrollable.maybeOf(notification.context!)?.position;
    if (position != null) _positions[widget.location] = position;
    // Hysteresis avoids toggling two costly glass geometries at one pixel
    // boundary during overscroll, slow drags and inertial settling.
    final mini = _mini
        ? notification.metrics.pixels > 24
        : notification.metrics.pixels > 88;
    if (mini != _mini) setState(() => _mini = mini);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.navigationOwner ?? _selected;
    final hasTrack = ref.watch(currentMediaItemProvider).value != null;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final shell = PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _searching) _backSearch();
      },
      child: GlassScaffold(
        key: const ValueKey('beta6-official-glass-shell'),
        background: const MusicThemeBackground(child: SizedBox.expand()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        settings: betaMusicPillGlass(context),
        edgeFade: false,
        resizeToAvoidBottomInset: false,
        body: Material(
          type: MaterialType.transparency,
          child: NotificationListener<ScrollNotification>(
            onNotification: _scroll,
            child: AnimatedBuilder(
              animation: _searchMotion,
              builder: (context, _) => Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: _searching,
                      child: Offstage(
                        // Keep the source mounted for its scroll state, but
                        // stop painting once the opaque search page has landed.
                        offstage: _searching && _searchMotion.isCompleted,
                        child: ExcludeSemantics(
                          excluding: _searching,
                          child: TickerMode(
                            enabled: !_searching,
                            child: MestingAdaptiveContentFrame(
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_hasOpenedSearch)
                    Positioned.fill(
                      child: ExcludeFocus(
                        excluding: !_searching,
                        child: Offstage(
                          offstage: !_searching && _searchMotion.isDismissed,
                          child: TickerMode(
                            enabled: !_searchMotion.isDismissed,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (_) => !_searching,
                              child: FractionalTranslation(
                                translation: Offset(
                                  1 -
                                      Curves.easeOutCubic.transform(
                                        _searchMotion.value,
                                      ),
                                  0,
                                ),
                                child: ColoredBox(
                                  key: const ValueKey('beta10-search-surface'),
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: inset,
                                      top: MediaQuery.paddingOf(context).top,
                                    ),
                                    child: BetaEdgeBack(
                                      onBack: _backSearch,
                                      child: MusicSearchResultsBody(
                                        onSearch: _submit,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Both system safe area and the search field's keyboard float belong
        // to the official components. Applying viewInsets again doubles lift.
        // Wide screens use this same single navigation; only content is capped.
        bottomBar: ValueListenableBuilder<double>(
          valueListenable: ref.watch(playerChromeRevealProvider),
          child: RepaintBoundary(
            child: Material(
              // GlassScaffold is Cupertino-based. Supply Mesting's normal text
              // defaults here so labels never inherit WidgetsApp's error style.
              type: MaterialType.transparency,
              child: BetaMusicBottomBar(
                selectedIndex: selected,
                isSearchActive: _mini || _searching,
                inline: _mini && !_searching,
                accessory: hasTrack ? const FloatingPlaybackPill() : null,
                accessoryEnabled: !_focused,
                onTabSelected: (index) {
                  if (index == selected &&
                      _mini &&
                      !_searching &&
                      _rootTab(widget.location) != null) {
                    setState(() => _mini = false);
                    return;
                  }
                  _search(false);
                  setState(() => _selected = index);
                  context.go(betaMusicRoutes[index]);
                },
                searchConfig: GlassSearchBarConfig(
                  controller: _searchText,
                  focusNode: _focus,
                  autoFocusOnExpand: false,
                  showsCancelButton: true,
                  expandWhenActive: !_mini || _searching,
                  hintText: '搜索歌曲、歌手',
                  onSearchToggle: _search,
                  onSearchFocusChanged: (focused) {
                    if (mounted) setState(() => _focused = focused);
                  },
                  onChanged: (text) => ref
                      .read(musicSearchControllerProvider.notifier)
                      .setQuery(text),
                  onSubmitted: _submit,
                  trailingBuilder: (context) => IconButton(
                    tooltip: '搜索',
                    icon: const Icon(Icons.arrow_upward_rounded),
                    onPressed: () => _submit(_searchText.text),
                  ),
                  cancelButtonSemanticLabel: '关闭搜索',
                  clearButtonSemanticLabel: '清空搜索',
                ),
              ),
            ),
          ),
          builder: (context, reveal, child) => IgnorePointer(
            ignoring: !widget.chromeVisible,
            child: AnimatedOpacity(
              opacity: widget.chromeVisible ? 1 : reveal,
              duration: widget.location == '/player'
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Transform.translate(
                offset: Offset(0, widget.chromeVisible ? 0 : (1 - reveal) * 12),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    // Embedded search is a shell state, not a child route. Register directly
    // with Router's dispatcher so Android edge/system Back reaches that state
    // before the nested navigator attempts to leave its root page.
    if (Router.maybeOf(context) == null) return shell;
    return BackButtonListener(
      onBackButtonPressed: () async {
        if (!_searching) return false;
        _backSearch();
        return true;
      },
      child: shell,
    );
  }
}
