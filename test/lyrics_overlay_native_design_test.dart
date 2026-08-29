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
  final overlayControlIcons = <String, String>{
    for (final name in <String>[
      'previous',
      'next',
      'play',
      'pause',
      'lock',
      'close',
    ])
      name: File(
        'android/app/src/main/res/drawable/ic_overlay_$name.xml',
      ).readAsStringSync(),
  };

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

  test('展开的桌面歌词使用轻量单层面板与钴蓝强调色', () {
    expect(source, contains('"Mesting Music"'));
    expect(source, contains('"桌面歌词 · 轻触收起"'));
    expect(source, contains('Color.parseColor("#F21B1E28")'));
    expect(source, contains('Color.parseColor("#F214161E")'));
    expect(source, contains('Color.parseColor("#3D91A5FF")'));
    expect(source, contains('Color.parseColor("#FF8FA3FF")'));
    expect(source, contains('Color.parseColor("#FF667DE0")'));
    expect(source, isNot(contains('#FFFF8DA8')));
    expect(source, isNot(contains('#FFFF668A')));
    expect(source, isNot(contains('Color.parseColor("#42FF9CB4")')));
  });

  test('歌词区不再嵌套笨重卡片且控制项收入统一工具栏', () {
    expect(source, contains('compactLyricsSurface = this'));
    expect(source, contains('lyricStatusLabel?.visibility'));
    expect(source, contains('compactLyricsSurface?.background = null'));
    expect(
      source,
      contains('roundedBackground("#0EFFFFFF", "#16FFFFFF", 18f)'),
    );
    expect(source, contains('LinearLayout.LayoutParams.WRAP_CONTENT'));
    expect(source, contains('currentLine?.gravity'));
    expect(source, contains('setLineSpacing(dp(2).toFloat(), 1.04f)'));
    expect(source, contains('dp(if (action == "playPause") 48 else 40)'));
    expect(source, isNot(contains('Color.parseColor("#CC292C37")')));
    expect(
      source,
      isNot(contains('LinearLayout.LayoutParams(dp(44), dp(44))')),
    );
  });

  test('控制栏使用可着色矢量图标而非字形伪图标', () {
    for (final entry in overlayControlIcons.entries) {
      expect(entry.value, contains('<vector'), reason: entry.key);
      expect(entry.value, contains('android:pathData='), reason: entry.key);
      expect(source, contains('R.drawable.ic_overlay_${entry.key}'));
    }
    expect(source, isNot(contains('controlButton(appContext, "‹"')));
    expect(source, isNot(contains('controlButton(appContext, "›"')));
    expect(source, isNot(contains('playButton?.text =')));
  });

  test('字体大小与颜色设置面板保持原有视觉与功能', () {
    expect(source, contains('settingText(appContext, "桌面歌词", 18f'));
    expect(source, contains('settingText(appContext, "字体颜色", 14f'));
    expect(source, contains('settingsPreview = settingText'));
    expect(source, contains('colorPalette.toList().chunked(4)'));
    expect(source, contains('Color.parseColor("#F51C1F29")'));
    expect(source, contains('Color.parseColor("#2EFFFFFF")'));
    expect(source, contains('settingButton(appContext, "恢复默认样式")'));
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
