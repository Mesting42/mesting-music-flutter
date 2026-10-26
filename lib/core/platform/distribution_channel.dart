import 'package:flutter/services.dart' show appFlavor;

/// Android's generated flavor is authoritative: a forgotten --dart-define must
/// never make a Beta read a formal update feed or start native code in stable.
class DistributionChannel {
  DistributionChannel._();

  static bool get isBeta => appFlavor == 'beta';
  static bool get isJavaTest => appFlavor == 'javaMysqlTest';

  static String get packageName => isBeta
      ? 'com.mesting.music.beta'
      : isJavaTest
      ? 'com.mesting.music.javatest'
      : 'com.mesting.music';

  static String get updateManifestUrl {
    const root =
        'https://mesting-d5gm7tuhxacddccfb-1331507389.tcloudbaseapp.com/releases/android';
    return '$root/${isBeta
        ? 'beta/'
        : isJavaTest
        ? 'java-mysql-test/'
        : ''}latest.json';
  }
}
