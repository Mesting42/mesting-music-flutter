import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../shared/layout/adaptive_layout.dart';
import '../../player/presentation/music_navigation.dart';
import '../../search/presentation/music_search_page.dart';
import '../../search/search_providers.dart';
import '../../themes/music_theme_background.dart';
import 'beta_bottom_bar.dart';
import 'floating_playback_pill.dart';

/// The official Apple Music GlassScaffold/searchable-tab/accessory composition
/// is the shell, not an overlay of independently positioned imitation pills.
/// Product navigation/search/audio stay behind their existing contracts.
class BetaMusicShell extends ConsumerStatefulWidget {
  const BetaMusicShell({
    required this.child,
    required this.location,
    super.key,
  });
  final Widget child;
  final String location;
  @override
  ConsumerState<BetaMusicShell> createState() => _BetaMusicShellState();
}

class _BetaMusicShellState extends ConsumerState<BetaMusicShell> {
  final _searchText = TextEditingController();
  final _focus = FocusNode();
  final _positions = <String, ScrollPosition>{};
  bool _mini = false, _searching = false, _focused = false;

  @override
  void dispose() {
    _searchText.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BetaMusicShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _searching = false;
      _mini = false;
      _focus.unfocus();
    }
  }

  void _search(bool active) {
    setState(() {
      _searching = active;
      if (!active) _focused = false;
    });
    if (!active) _focus.unfocus();
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    _searchText.text = text;
    ref.read(musicSearchControllerProvider.notifier).submit(text);
    _focus.unfocus();
  }

  bool _scroll(ScrollNotification notification) {
    if (_searching ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final position = Scrollable.maybeOf(notification.context!)?.position;
    if (position != null) _positions[widget.location] = position;
    final mini = notification.metrics.pixels > 50;
    if (mini != _mini) setState(() => _mini = mini);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final selected = musicBottomNavigationIndexForLocation(widget.location);
    final hasTrack = ref.watch(currentMediaItemProvider).value != null;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final safe = MediaQuery.viewPaddingOf(context).bottom;
    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _searching) _search(false);
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: _searching
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: inset + 100 + safe,
                            top: MediaQuery.paddingOf(context).top,
                          ),
                          child: MusicSearchResultsBody(onSearch: _submit),
                        )
                      : MestingAdaptiveContentFrame(child: widget.child),
                ),
              ],
            ),
          ),
        ),
        // Both system safe area and the search field's keyboard float belong
        // to the official components. Applying viewInsets again doubles lift.
        // Wide screens use this same single navigation; only content is capped.
        bottomBar: Material(
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
              if (index == selected && _mini && !_searching) {
                final position = _positions[widget.location];
                if (position?.hasPixels == true) {
                  position!.animateTo(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutQuart,
                  );
                }
                setState(() => _mini = false);
                return;
              }
              _search(false);
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
    );
  }
}
