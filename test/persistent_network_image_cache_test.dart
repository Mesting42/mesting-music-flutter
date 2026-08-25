import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mesting_music/shared/media/persistent_network_image_cache.dart';

void main() {
  test(
    'persists a social avatar and reuses it after a signed URL refresh',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'mesting-network-image-cache-test-',
      );
      addTearDown(() => root.delete(recursive: true));
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount += 1;
        return http.Response.bytes(const <int>[0xFF, 0xD8, 0xFF, 0x00], 200);
      });
      final firstCache = PersistentNetworkImageCache(
        client: client,
        directoryProvider: () async => root,
      );

      final first = await firstCache.resolve(
        cacheKey: 'social-avatar-friend-1',
        url: 'https://cdn.example/avatars/friend-1.jpg?sign=first',
      );

      expect(first, isNotNull);
      expect(await first!.exists(), isTrue);
      expect(requestCount, 1);

      final restartedCache = PersistentNetworkImageCache(
        client: client,
        directoryProvider: () async => root,
      );
      final later = await restartedCache.resolve(
        cacheKey: 'social-avatar-friend-1',
        url: 'https://cdn.example/avatars/friend-1.jpg?sign=renewed',
      );

      expect(later, isNotNull);
      expect(later!.path, first.path);
      expect(requestCount, 1);
    },
  );

  test('does not persist a response that is not an image', () async {
    final root = await Directory.systemTemp.createTemp(
      'mesting-network-image-cache-test-',
    );
    addTearDown(() => root.delete(recursive: true));
    final cache = PersistentNetworkImageCache(
      client: MockClient((_) async => http.Response.bytes(<int>[1, 2, 3], 200)),
      directoryProvider: () async => root,
    );

    final result = await cache.resolve(
      cacheKey: 'social-avatar-friend-2',
      url: 'https://cdn.example/avatars/friend-2.jpg',
    );

    expect(result, isNull);
    final cacheDirectory = Directory(
      '${root.path}${Platform.pathSeparator}mesting_network_image_cache',
    );
    expect(await cacheDirectory.list().isEmpty, isTrue);
  });
}
