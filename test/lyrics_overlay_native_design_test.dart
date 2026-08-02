import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'android/app/src/main/kotlin/com/mesting/mesting_music/MainActivity.kt',
  ).readAsStringSync();
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();
  final audioHandlerSource = File(
    'lib/core/audio/mesting_audio_handler.dart',
  ).readAsStringSync();
  final notificationLyricsIcon = File(
    'android/app/src/main/res/drawable/ic_notification_lyrics.xml',
  ).readAsStringSync();
  final notificationLyricsOnIcon = File(
    'android/app/src/main/res/drawable/ic_notification_lyrics_on.xml',
  ).readAsStringSync();

  test('通知中心桌面歌词操作显示词字而非消息气泡', () {
    for (final icon in <String>[
      notificationLyricsIcon,
      notificationLyricsOnIcon,
    ]) {
      expect(icon, contains('“词” glyph'));
      expect(icon, contains('M4.2,4.3L6.6,6.1'));
      expect(icon, isNot(contains('M4,4H20C21.1')));
    }
    expect(notificationLyricsOnIcon, contains('android:strokeWidth="2.2"'));
  });

  test('桌面歌词使用中性单卡与钴蓝品牌强调色', () {
    expect(source, contains('"Mesting Music"'));
    expect(source, contains('"桌面歌词"'));
    expect(source, contains('Color.parseColor("#F51C1F29")'));
    expect(source, contains('Color.parseColor("#2EFFFFFF")'));
    expect(source, contains('roundedBackground("#FF7B8FEF"'));
    expect(source, isNot(contains('#FFFF8DA8')));
    expect(source, isNot(contains('#FFFF668A')));
    expect(source, isNot(contains('Color.parseColor("#42FF9CB4")')));
  });

  test('歌词区与统一控制栏形成清晰层级', () {
    expect(source, contains('compactLyricsSurface = this'));
    expect(source, contains('lyricStatusLabel?.visibility'));
    expect(source, contains('Color.parseColor("#CC292C37")'));
    expect(source, contains('currentLine?.gravity'));
    expect(
      source,
      isNot(contains('roundedBackground("#0FFFFFFF", "#1AFFFFFF"')),
    );
    expect(source, contains('setLineSpacing(dp(2).toFloat(), 1.04f)'));
    expect(source, contains('LinearLayout.LayoutParams(dp(44), dp(44))'));
  });

  test('桌面歌词按钮向系统提供完整中文语义', () {
    for (final label in <String>[
      '上一首',
      '播放或暂停',
      '下一首',
      '歌词样式',
      '锁定桌面歌词',
      '关闭桌面歌词',
    ]) {
      expect(source, contains('"$label"'));
    }
  });

  test('通知栏首次开启桌面歌词会直接进入原生悬浮窗授权链路', () {
    expect(audioHandlerSource, contains("'requestPermissionFromNotification'"));
    expect(audioHandlerSource, contains("'permissionRequestLaunched'"));
    expect(source, contains('LyricsOverlayPermissionActivity::class.java'));
    expect(source, contains('PendingIntent.getActivity('));
    expect(source, contains('setPendingIntentBackgroundActivityStartMode'));
    expect(source, contains('MODE_BACKGROUND_ACTIVITY_START_ALLOW_ALWAYS'));
    expect(source, contains('Settings.ACTION_MANAGE_OVERLAY_PERMISSION'));
    expect(source, contains('"notificationPermissionResult"'));
    expect(
      manifest,
      contains('android:name=".LyricsOverlayPermissionActivity"'),
    );
    expect(manifest, contains('android:excludeFromRecents="true"'));
  });
}
