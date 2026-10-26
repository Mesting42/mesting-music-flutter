import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/persistence/app_preferences.dart';

/// Startup media is independent of launcher aliases, player style and theme.
/// A new install (or an upgrade without this key) uses the first supplied film.
const startupStylePreferenceKey = 'beta12_startup_style';

enum StartupStyle {
  companionsOne('video-one', '音乐伙伴', 'assets/branding/startup/companions-1'),
  companionsTwo('video-two', '唱片派对', 'assets/branding/startup/companions-2'),
  classic('classic', '经典启动页', null);

  const StartupStyle(this.id, this.label, this.assetBase);
  final String id;
  final String label;
  final String? assetBase;
  String? get videoAsset => assetBase == null ? null : '$assetBase.mp4';
  String? get posterAsset => assetBase == null ? null : '$assetBase.webp';
}

StartupStyle savedStartupStyle(SharedPreferences preferences) =>
    StartupStyle.values.firstWhere(
      (style) => style.id == preferences.getString(startupStylePreferenceKey),
      orElse: () => StartupStyle.companionsOne,
    );

class StartupStyleController extends Notifier<StartupStyle> {
  @override
  StartupStyle build() =>
      savedStartupStyle(ref.watch(sharedPreferencesProvider));

  Future<void> select(StartupStyle style) async {
    // Publish after persistence succeeds so the checkmark is never misleading.
    final saved = await ref
        .read(sharedPreferencesProvider)
        .setString(startupStylePreferenceKey, style.id);
    if (!saved) throw StateError('启动页未能保存，请重试');
    if (ref.mounted) state = style;
  }
}

final startupStyleProvider =
    NotifierProvider<StartupStyleController, StartupStyle>(
      StartupStyleController.new,
    );
