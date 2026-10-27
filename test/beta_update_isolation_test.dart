import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mesting_music/core/platform/distribution_channel.dart';
import 'package:mesting_music/features/app_update/data/app_update_platform.dart';
import 'package:mesting_music/features/app_update/data/app_update_repository.dart';
import 'package:mesting_music/features/app_update/domain/app_update_models.dart';

/// Reproduces a correctly installed Beta receiving a misplaced formal manifest.
class _BetaUpdatePlatform extends AppUpdatePlatform {
  @override
  Future<AppVersionInfo> currentVersion() async => const AppVersionInfo(
    packageName: 'com.mesting.music.beta',
    versionName: '1.0.37-beta.1',
    versionCode: 1,
  );
}

void main() {
  test(
    'Beta requests its own feed and rejects a formal package manifest',
    () async {
      Uri? requestedUrl;
      final client = MockClient((request) async {
        requestedUrl = request.url;
        return http.Response(
          jsonEncode({
            'packageName': 'com.mesting.music',
            'versionName': '1.0.38',
            'versionCode': 59,
            'title': 'Formal update accidentally in Beta feed',
            'releaseNotes': ['Must never be accepted by Beta'],
            'apkUrl': 'https://updates.example.com/formal.apk',
            'sha256': List.filled(64, '0').join(),
            'sizeBytes': 100,
            'publishedAt': '2026-10-25T00:00:00Z',
          }),
          200,
        );
      });
      addTearDown(client.close);
      final repository = AppUpdateRepository(
        client: client,
        platform: _BetaUpdatePlatform(),
      );

      await expectLater(
        repository.check(),
        throwsA(
          isA<AppUpdateException>().having(
            (error) => error.code,
            'code',
            'package',
          ),
        ),
      );
      expect(requestedUrl?.path, '/releases/android/beta/latest.json');
      expect(requestedUrl?.queryParameters.containsKey('t'), true);
    },
    skip: !DistributionChannel.isBeta,
  );
}
