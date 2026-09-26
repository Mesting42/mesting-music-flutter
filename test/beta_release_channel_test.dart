import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('beta APK has an isolated app id, name, and update feed', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final betaName = File(
      'android/app/src/debug/res/values/strings.xml',
    ).readAsStringSync();
    final updater = File(
      'lib/features/app_update/data/app_update_repository.dart',
    ).readAsStringSync();
    final betaBuilder = File(
      'tool/build_android_beta_apk.ps1',
    ).readAsStringSync();
    final betaPublisher = File(
      'tool/publish_android_beta_update.ps1',
    ).readAsStringSync();

    expect(gradle, contains('applicationIdSuffix = ".beta"'));
    expect(betaName, contains('Mesting 音乐测试版'));
    expect(updater, contains("'APP_UPDATE_PACKAGE_NAME'"));
    expect(betaBuilder, contains(r'--build-name $VersionName'));
    expect(
      betaBuilder,
      contains('APP_UPDATE_PACKAGE_NAME=com.mesting.music.beta'),
    );
    expect(betaBuilder, contains('releases/android/beta/latest.json'));
    expect(betaPublisher, contains("packageName = 'com.mesting.music.beta'"));
    expect(betaPublisher, contains("'releases/android/beta'"));
    expect(betaPublisher, isNot(contains("'releases/android'\n")));
  });
}
