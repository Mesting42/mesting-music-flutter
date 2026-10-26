import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../themes/beta_appearance.dart';

/// Composition and optical values from liquid_glass_widgets' official
/// example/lib/apple_music/apple_music_demo.dart (MIT). Keep these centralized:
/// the package owns the spring, press/drag physics and accessory morphing.
LiquidGlassSettings betaMusicPillGlass(BuildContext context) =>
    LiquidGlassSettings(
      glassColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xCC1C1C1E)
          : const Color(0xCCF2F2F7),
      thickness: 30,
      blur: 2,
      lightIntensity: .18,
      chromaticAberration: .01,
      saturation: 1.2,
      fresnelStrength: 0,
    );

const betaMusicRoutes = [
  '/music/recommend',
  '/music',
  '/music/library',
  '/profile',
];
const betaMusicTabs = [
  GlassTab(
    label: '首页',
    icon: Icon(Icons.home_rounded),
    activeIcon: Icon(Icons.home_rounded),
  ),
  GlassTab(
    label: '发现',
    icon: Icon(CupertinoIcons.square_grid_2x2),
    activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
  ),
  GlassTab(
    label: '音乐库',
    icon: Icon(CupertinoIcons.music_albums),
    activeIcon: Icon(CupertinoIcons.music_albums_fill),
  ),
  GlassTab(
    label: '我的',
    icon: Icon(CupertinoIcons.person),
    activeIcon: Icon(CupertinoIcons.person_fill),
  ),
];

class BetaMusicBottomBar extends StatelessWidget {
  const BetaMusicBottomBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.searchConfig,
    this.isSearchActive = false,
    this.inline = false,
    this.accessory,
    this.accessoryEnabled = true,
    super.key,
  });
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final GlassSearchBarConfig searchConfig;
  final bool isSearchActive, inline, accessoryEnabled;
  final Widget? accessory;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    final scaled = (MediaQuery.textScalerOf(context).scale(24) - 24).clamp(
      0.0,
      28.0,
    );
    return GlassTabBar.searchable(
      key: const ValueKey('beta6-official-music-bar'),
      tabs: betaMusicTabs,
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
      isSearchActive: isSearchActive,
      bottomAccessoryPlacement: inline
          ? GlassTabBarAccessoryPlacement.inline
          : GlassTabBarAccessoryPlacement.expanded,
      bottomAccessory: accessory,
      bottomAccessoryEnabled: accessoryEnabled,
      bottomAccessoryHeight: 50 + scaled,
      barHeight: 64 + scaled,
      searchBarHeight: 50 + scaled,
      horizontalPadding: 20,
      verticalPadding: 16,
      spacing: 8,
      selectedIconColor: BetaAppearance.red,
      selectedLabelColor: BetaAppearance.red,
      unselectedIconColor: foreground.withValues(alpha: .9),
      unselectedLabelColor: foreground.withValues(alpha: .9),
      indicatorColor: foreground.withValues(alpha: .2),
      labelFontSize: 10,
      iconSize: 28,
      iconLabelSpacing: 0,
      quality: GlassQuality.premium,
      interactionBehavior: GlassInteractionBehavior.full,
      settings: LiquidGlassSettings(
        glassColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xAA1C1C1E)
            : const Color(0xAAF2F2F7),
        thickness: 30,
        blur: 2,
        chromaticAberration: .01,
        lightAngle: GlassDefaults.lightAngle,
        lightIntensity: .2,
        ambientStrength: 0,
        refractiveIndex: 1.2,
        fresnelStrength: 0,
        saturation: 1.2,
        specularSharpness: GlassSpecularSharpness.medium,
      ),
      searchConfig: searchConfig,
    );
  }
}
