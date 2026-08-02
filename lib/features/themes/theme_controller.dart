import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/persistence/app_preferences.dart';
import 'app_brand_style.dart';
import 'music_theme_preset.dart';

const musicThemePreferenceKey = 'music_theme_preset';

ThemeMode savedMusicThemeMode(SharedPreferences preferences) {
  final saved = preferences.getString(musicThemePreferenceKey);
  final legacy = preferences.getString('music_theme_style');
  final preset = musicThemePresetById(
    saved ?? (legacy == 'classic' ? 'classic' : 'classic-system'),
  );
  return musicThemeMode(preset);
}

ThemeMode musicThemeMode(MusicThemePreset preset) {
  if (preset.followsSystem) return ThemeMode.system;
  return preset.dark ? ThemeMode.dark : ThemeMode.light;
}

class MusicThemeController extends Notifier<MusicThemePreset> {
  @override
  MusicThemePreset build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    final saved = preferences.getString(musicThemePreferenceKey);
    if (saved != null) return musicThemePresetById(saved);
    final legacy = preferences.getString('music_theme_style');
    return musicThemePresetById(
      legacy == 'classic' ? 'classic' : 'classic-system',
    );
  }

  Future<void> select(String presetId) async {
    final preset = musicThemePresetById(presetId);
    state = preset;
    await ref
        .read(sharedPreferencesProvider)
        .setString(musicThemePreferenceKey, preset.id);
    await AppBrandStyleBridge.syncLaunchTheme(
      musicThemeMode(preset),
      updateLauncher: false,
    );
  }
}

final musicThemeProvider =
    NotifierProvider<MusicThemeController, MusicThemePreset>(
      MusicThemeController.new,
    );

class _SystemBrightnessController extends Notifier<Brightness>
    with WidgetsBindingObserver {
  @override
  Brightness build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() => binding.removeObserver(this));
    return binding.platformDispatcher.platformBrightness;
  }

  @override
  void didChangePlatformBrightness() {
    state = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }
}

final _systemBrightnessControllerProvider =
    NotifierProvider<_SystemBrightnessController, Brightness>(
      _SystemBrightnessController.new,
    );

final systemBrightnessProvider = Provider<Brightness>(
  (ref) => ref.watch(_systemBrightnessControllerProvider),
);

final effectiveMusicThemeProvider = Provider<MusicThemePreset>((ref) {
  final selected = ref.watch(musicThemeProvider);
  if (!selected.followsSystem) return selected;
  final brightness = ref.watch(systemBrightnessProvider);
  return musicThemePresetById(
    brightness == Brightness.dark ? 'classic-dark' : 'classic',
  );
});

enum ThemePerformanceMode { automatic, full, reduced }

class ThemePerformanceController extends Notifier<ThemePerformanceMode> {
  static const _key = 'theme_performance_mode';

  @override
  ThemePerformanceMode build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return ThemePerformanceMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemePerformanceMode.automatic,
    );
  }

  Future<void> select(ThemePerformanceMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

final themePerformanceProvider =
    NotifierProvider<ThemePerformanceController, ThemePerformanceMode>(
      ThemePerformanceController.new,
    );

enum ProgressDecoration { followTheme, classic, shinchan, helloKitty, kuromi }

class ThemeVisualSettings {
  const ThemeVisualSettings({
    this.backgroundStrength = .58,
    this.showIpDecoration = false,
    this.progressStyle = ProgressDecoration.classic,
    this.progressCharacter = ProgressDecoration.classic,
  });

  final double backgroundStrength;
  final bool showIpDecoration;
  final ProgressDecoration progressStyle;
  final ProgressDecoration progressCharacter;

  ThemeVisualSettings copyWith({
    double? backgroundStrength,
    bool? showIpDecoration,
    ProgressDecoration? progressStyle,
    ProgressDecoration? progressCharacter,
  }) {
    return ThemeVisualSettings(
      backgroundStrength: backgroundStrength ?? this.backgroundStrength,
      showIpDecoration: showIpDecoration ?? this.showIpDecoration,
      progressStyle: progressStyle ?? this.progressStyle,
      progressCharacter: progressCharacter ?? this.progressCharacter,
    );
  }
}

class ThemeVisualSettingsController extends Notifier<ThemeVisualSettings> {
  static const _strengthKey = 'music_background_strength';
  static const _decorationKey = 'music_ip_decoration';
  static const _progressStyleKey = 'music_progress_style';
  static const _progressCharacterKey = 'music_progress_character';

  @override
  ThemeVisualSettings build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return ThemeVisualSettings(
      backgroundStrength: preferences.getDouble(_strengthKey) ?? .58,
      showIpDecoration: preferences.getBool(_decorationKey) ?? false,
      progressStyle: _readDecoration(preferences.getString(_progressStyleKey)),
      progressCharacter: _readDecoration(
        preferences.getString(_progressCharacterKey),
      ),
    );
  }

  ProgressDecoration _readDecoration(String? value) {
    return ProgressDecoration.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ProgressDecoration.classic,
    );
  }

  Future<void> setBackgroundStrength(double value) async {
    state = state.copyWith(backgroundStrength: value);
    await ref.read(sharedPreferencesProvider).setDouble(_strengthKey, value);
  }

  Future<void> setIpDecoration(bool value) async {
    state = state.copyWith(showIpDecoration: value);
    await ref.read(sharedPreferencesProvider).setBool(_decorationKey, value);
  }

  Future<void> setProgressStyle(ProgressDecoration value) async {
    state = state.copyWith(progressStyle: value);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_progressStyleKey, value.name);
  }

  Future<void> setProgressCharacter(ProgressDecoration value) async {
    state = state.copyWith(progressCharacter: value);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_progressCharacterKey, value.name);
  }
}

final themeVisualSettingsProvider =
    NotifierProvider<ThemeVisualSettingsController, ThemeVisualSettings>(
      ThemeVisualSettingsController.new,
    );

MusicThemeIp decorationIp(
  ProgressDecoration decoration,
  MusicThemePreset preset,
) {
  return switch (decoration) {
    ProgressDecoration.followTheme => preset.ip,
    ProgressDecoration.classic => MusicThemeIp.classic,
    ProgressDecoration.shinchan => MusicThemeIp.shinchan,
    ProgressDecoration.helloKitty => MusicThemeIp.helloKitty,
    ProgressDecoration.kuromi => MusicThemeIp.kuromi,
  };
}

String? progressCharacterAsset(
  ProgressDecoration decoration,
  MusicThemePreset preset,
) {
  return switch (decorationIp(decoration, preset)) {
    MusicThemeIp.classic => null,
    MusicThemeIp.shinchan => null,
    MusicThemeIp.helloKitty =>
      'assets/images/theme_gallery/hello-kitty-progress-head.png',
    MusicThemeIp.kuromi =>
      'assets/images/theme_gallery/kuromi-progress-head.png',
  };
}

String progressDecorationLabel(ProgressDecoration decoration) =>
    switch (decoration) {
      ProgressDecoration.followTheme => '跟随皮肤',
      ProgressDecoration.classic => '经典',
      ProgressDecoration.shinchan => '小新',
      ProgressDecoration.helloKitty => 'Hello Kitty',
      ProgressDecoration.kuromi => '库洛米',
    };
