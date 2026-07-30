import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/persistence/app_preferences.dart';

enum MusicThemeStyle { classic, shinchan }

class MusicThemeController extends Notifier<MusicThemeStyle> {
  @override
  MusicThemeStyle build() {
    final saved = ref
        .watch(sharedPreferencesProvider)
        .getString(_preferenceKey);
    return MusicThemeStyle.values.firstWhere(
      (style) => style.name == saved,
      orElse: () => MusicThemeStyle.shinchan,
    );
  }

  static const _preferenceKey = 'music_theme_style';

  Future<void> select(MusicThemeStyle style) async {
    state = style;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_preferenceKey, style.name);
  }
}

final musicThemeProvider =
    NotifierProvider<MusicThemeController, MusicThemeStyle>(
      MusicThemeController.new,
    );
