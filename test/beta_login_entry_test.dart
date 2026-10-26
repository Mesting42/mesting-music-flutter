import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/core/persistence/app_preferences.dart';
import 'package:mesting_music/core/platform/distribution_channel.dart';
import 'package:mesting_music/features/auth/auth_providers.dart';
import 'package:mesting_music/features/auth/data/auth_repository.dart';
import 'package:mesting_music/features/auth/domain/auth_models.dart';
import 'package:mesting_music/features/auth/presentation/first_launch_auth_coordinator.dart';
import 'package:mesting_music/features/music_platform/data/platform_session_store.dart';
import 'package:mesting_music/features/music_platform/domain/platform_session.dart';
import 'package:mesting_music/features/music_platform/music_platform_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps legacy restoration pending to reproduce an unavailable CloudBase.
class _PendingLegacyAuth extends UnconfiguredAuthRepository {
  final restored = Completer<AuthSession?>();
  @override
  Future<AuthSession?> restoreSession() => restored.future;
}

class _EmptyPlatformStore implements PlatformSessionStore {
  @override
  Future<PlatformSession?> read() async => null;
  @override
  Future<void> write(PlatformSession session) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets(
    'Beta first install exposes two logins and guest while CloudBase is pending',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final legacy = _PendingLegacyAuth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            authRepositoryProvider.overrideWithValue(legacy),
            platformSessionStoreProvider.overrideWithValue(
              _EmptyPlatformStore(),
            ),
          ],
          child: const MaterialApp(
            home: FirstLaunchAuthCoordinator(
              child: Scaffold(body: Text('推荐页面')),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('使用音乐平台账号登录'), findsOneWidget);
      expect(find.text('Mesting 账号登录 / 注册'), findsOneWidget);
      expect(find.text('暂不登录，先体验'), findsOneWidget);

      await tester.tap(find.text('使用音乐平台账号登录'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('音乐平台账号'), findsOneWidget);
      expect(find.text('酷狗扫码'), findsOneWidget);
      expect(find.text('微信扫码'), findsOneWidget);
      expect(find.text('QQ 扫码'), findsOneWidget);
      await tester.tap(find.byTooltip('返回'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('音乐平台账号'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('experience-now')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('推荐页面'), findsOneWidget);
      expect(preferences.getBool(firstLaunchAuthCompletedPreferenceKey), true);
      legacy.restored.complete(null);
      await tester.pump();
    },
    skip: !DistributionChannel.isBeta,
  );
}
