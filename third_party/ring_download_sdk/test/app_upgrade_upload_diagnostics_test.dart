import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ring_download_sdk/compat.dart';

void main() {
  test('each fixed source profile is a small complete JSON record', () {
    for (final alias in ['peer1', 'peer2', 'seed', 'https']) {
      final event = AppUpgradeP2PDiagnostic(
        stage: 'performance',
        code: 'source_profile',
        source: alias.startsWith('peer') ? 'peer' : alias,
        attempt: alias == 'https' ? null : alias,
        appVersion: 'a' * 40,
        elapsedMs: 604800000,
        metrics: {
          for (final key in [
            'requests',
            'verified_bytes',
            'busy_us',
            'cancelled',
            'failures',
          ])
            'source_${alias}_$key': 1 << 60,
        },
      ).toJson();
      final encoded = jsonEncode(event);
      expect(utf8.encode('[AppUpgradeP2P] $encoded').length, lessThan(800));
      expect(event['code'], 'source_profile');
      expect((jsonDecode(encoded)['metrics'] as Map).length, 5);
    }
  });

  test('fixed per-source metrics cross the closed diagnostic boundary', () {
    final input = <String, int>{
      for (final source in ['peer1', 'peer2', 'seed', 'https'])
        for (final metric in [
          'requests',
          'verified_bytes',
          'busy_us',
          'cancelled',
          'failures',
        ])
          'source_${source}_$metric': 7,
      'source_private_token_requests': 7,
      'source_peer1_private_metric': 7,
      'source_peer1_url': 7,
    };
    final exported = AppUpgradeP2PDiagnostic(
      stage: 'performance',
      code: 'multisource_profile',
      metrics: input,
    ).toJson();
    final metrics = exported['metrics'] as Map;
    expect(metrics.length, 20);
    expect(metrics['source_peer1_requests'], 7);
    expect(
      metrics.keys.any(
        (key) =>
            key.toString().contains('private') ||
            key.toString().endsWith('_url'),
      ),
      false,
    );
  });
  for (final code in const [
    'upload_send_timeout',
    'upload_queue_timeout',
    'upload_buffer_query_timeout',
    'upload_buffer_unavailable',
    'upload_timeout',
  ]) {
    test('$code survives the actual diagnostic JSON boundary', () {
      final exported = AppUpgradeP2PDiagnostic(
        stage: 'sharing',
        code: code,
      ).toJson();
      expect(exported['stage'], 'sharing');
      expect(exported['code'], code);
    });
  }
  test('untrusted values remain excluded by the closed vocabulary', () {
    for (final code in const [
      '192.168.1.99',
      'https://private.example/apk?token=secret',
      'session_0123456789abcdef',
      'private-upload-path',
      'upload_timeout_secret',
      '',
    ]) {
      final exported = AppUpgradeP2PDiagnostic(
        stage: 'sharing',
        code: code,
      ).toJson();
      expect(exported['code'], 'unknown_error');
      if (code.isNotEmpty) {
        expect(exported.toString(), isNot(contains(code)));
      }
    }
  });
}
