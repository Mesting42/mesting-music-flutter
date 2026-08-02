import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/persistence/app_preferences.dart';

enum PlayerVisualStyle {
  classic,
  aurora,
  cassette,
  lyricStage;

  String get id => name;

  String get displayName => switch (this) {
    PlayerVisualStyle.classic => '经典',
    PlayerVisualStyle.aurora => '流光唱片',
    PlayerVisualStyle.cassette => '星环脉冲',
    PlayerVisualStyle.lyricStage => '液态频谱',
  };

  String get description => switch (this) {
    PlayerVisualStyle.classic => '沉浸唱片与主题背景',
    PlayerVisualStyle.aurora => '环形光轨与悬浮唱片',
    PlayerVisualStyle.cassette => '深空环阵随节拍扩张',
    PlayerVisualStyle.lyricStage => '流体光幕随旋律起伏',
  };
}

PlayerVisualStyle playerVisualStyleById(String? id) =>
    PlayerVisualStyle.values.firstWhere(
      (style) => style.id == id,
      orElse: () => PlayerVisualStyle.classic,
    );

class PlayerVisualStyleController extends Notifier<PlayerVisualStyle> {
  static const preferenceKey = 'player_visual_style';

  @override
  PlayerVisualStyle build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(preferenceKey);
    return playerVisualStyleById(saved);
  }

  Future<void> select(PlayerVisualStyle style) async {
    state = style;
    await ref
        .read(sharedPreferencesProvider)
        .setString(preferenceKey, style.id);
  }
}

final playerVisualStyleProvider =
    NotifierProvider<PlayerVisualStyleController, PlayerVisualStyle>(
      PlayerVisualStyleController.new,
    );
