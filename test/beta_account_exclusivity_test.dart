import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mesting_music/core/persistence/app_preferences.dart';
import 'package:mesting_music/core/platform/distribution_channel.dart';
import 'package:mesting_music/features/auth/auth_providers.dart';
import 'package:mesting_music/features/auth/beta_account_choice.dart';
import 'package:mesting_music/features/auth/data/auth_repository.dart';
import 'package:mesting_music/features/auth/domain/auth_models.dart';
import 'package:mesting_music/features/auth/presentation/auth_page.dart';
import 'package:mesting_music/features/auth/presentation/first_launch_auth_coordinator.dart';
import 'package:mesting_music/features/library/library_providers.dart';
import 'package:mesting_music/features/music_platform/data/embedded_music_server.dart';
import 'package:mesting_music/features/music_platform/data/music_platform_api.dart';
import 'package:mesting_music/features/music_platform/data/platform_session_store.dart';
import 'package:mesting_music/features/music_platform/domain/platform_session.dart';
import 'package:mesting_music/features/music_platform/music_platform_providers.dart';
import 'package:mesting_music/features/profile/presentation/profile_page.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_discovery_page.dart';
import 'package:mesting_music/features/settings/presentation/settings_page.dart';
import 'package:mesting_music/features/app_update/app_update_providers.dart';
import 'package:mesting_music/features/app_update/domain/app_update_models.dart';
import 'package:mesting_music/features/search/search_providers.dart';
import 'package:mesting_music/features/search/data/hot_music_repository.dart';

class _Store implements PlatformSessionStore {
  PlatformSession? value;
  @override
  Future<PlatformSession?> read() async => value;
  @override
  Future<void> write(PlatformSession session) async {
    value = session;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class _Server implements MusicServer {
  @override
  Future<Uri> start() async => Uri.parse('http://127.0.0.1:12345');
}

class _Legacy extends UnconfiguredAuthRepository {
  int restores = 0;
  final pending = Completer<AuthSession?>();
  @override
  Future<AuthSession?> restoreSession() {
    restores++;
    return pending.future;
  }
}

void main() {
  late SharedPreferences preferences;
  late _Store store;
  late _Legacy legacy;
  late MusicPlatformApi api;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    store = _Store();
    legacy = _Legacy();
    api = MusicPlatformApi(
      server: _Server(),
      client: MockClient(
        (_) async => http.Response('{"status":1,"data":[]}', 200),
      ),
    );
  });
  overrides() => [
    sharedPreferencesProvider.overrideWithValue(preferences),
    platformSessionStoreProvider.overrideWithValue(store),
    musicPlatformApiProvider.overrideWithValue(api),
    authRepositoryProvider.overrideWithValue(legacy),
    playlistsProvider.overrideWith((ref) => Stream.value([])),
    favoriteTracksProvider.overrideWith((ref) => Stream.value([])),
    appVersionProvider.overrideWith(
      (ref) async => const AppVersionInfo(
        packageName: 'com.mesting.music.beta',
        versionName: '1.0.37-beta.2',
        versionCode: 2,
      ),
    ),
    hotMusicRepositoryProvider.overrideWith(
      (ref) => HotMusicRepository(
        rankingLoader: ({int limit = 9}) async => [],
        preferences: preferences,
        localTracks: [],
      ),
    ),
  ];

  test(
    'platform login defeats delayed CloudBase restoration and logout persists guest choice',
    () async {
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);
      container.read(authControllerProvider);
      await container.read(platformAccountProvider.future);
      await container.read(platformAccountProvider.notifier).accept({
        'userid': '7',
        'token': 'test',
        'nickname': '酷狗昵称',
      });
      legacy.pending.complete(
        AuthSession(
          user: const AuthUser(uid: 'old', nickname: '旧账号'),
          accessToken: 'old',
          refreshToken: '',
          expiresAt: DateTime(2100),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(container.read(currentUserProvider), null);
      expect(container.read(platformAccountProvider).value?.userId, '7');
      await container.read(platformAccountProvider.notifier).signOut();
      expect(
        container.read(betaAccountChoiceProvider),
        BetaAccountChoice.guest,
      );
      expect(api.session, null);
      final restarted = ProviderContainer(overrides: overrides());
      addTearDown(restarted.dispose);
      expect(await restarted.read(authControllerProvider.future), null);
      expect(await restarted.read(platformAccountProvider.future), null);
      expect(legacy.restores, 1);
    },
    skip: !DistributionChannel.isBeta,
  );

  test(
    'Mesting selection blocks a stale platform login callback',
    () async {
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);
      await container.read(platformAccountProvider.future);
      await container
          .read(betaAccountChoiceProvider.notifier)
          .select(BetaAccountChoice.mesting);
      await expectLater(
        container.read(platformAccountProvider.notifier).accept({
          'userid': '7',
          'token': 'test',
        }),
        throwsA(isA<MusicPlatformException>()),
      );
      expect(store.value, null);
      expect(api.session, null);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'Kugou profile hides old login; logout restores both choices',
    (tester) async {
      store.value = const PlatformSession(
        userId: '7',
        token: 'test',
        nickname: '酷狗昵称',
      );
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);
      await container.read(platformAccountProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: ProfilePage())),
        ),
      );
      await tester.pump();
      expect(find.text('酷狗昵称'), findsOneWidget);
      expect(find.text('登录或创建账号'), findsNothing);
      expect(find.text('酷狗云端收藏'), findsOneWidget);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AuthPage(initialMode: 'login', redirect: '/profile'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Mesting 账号登录 / 注册'), findsNothing);
      expect(find.text('退出音乐平台账号'), findsOneWidget);
      await container.read(platformAccountProvider.notifier).signOut();
      await tester.pump();
      expect(find.text('Mesting 账号登录 / 注册'), findsOneWidget);
      expect(find.text('使用音乐平台账号登录'), findsOneWidget);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'Beta discovery renders upstream content and settings show the current account only',
    (tester) async {
      final paths = <String>[];
      api = MusicPlatformApi(
        server: _Server(),
        client: MockClient((request) async {
          paths.add(request.url.path);
          return http.Response(
            jsonEncode({
              'status': 1,
              'data': request.url.path == '/top/playlist'
                  ? [
                      {'global_collection_id': 'gid-1', 'name': '真实接口精选歌单'},
                    ]
                  : [
                      {
                        'hash': 'HASH',
                        'songname': '真实接口每日推荐',
                        'singername': '测试歌手',
                      },
                    ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      store.value = const PlatformSession(
        userId: '7',
        token: 'test',
        nickname: '酷狗昵称',
      );
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);
      await container.read(platformAccountProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: PlatformDiscoveryPage()),
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('酷狗概念版 · 为你推荐'), findsOneWidget);
      expect(find.text('真实接口每日推荐'), findsWidgets);
      expect(
        paths,
        containsAll(['/everyday/recommend', '/home/discover', '/top/playlist']),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: SettingsPage())),
        ),
      );
      await tester.pump();
      expect(find.text('酷狗昵称'), findsOneWidget);
      expect(find.text('登录 / 注册'), findsNothing);
      expect(find.text('账号与绑定'), findsNothing);
      expect(tester.takeException(), null);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'restored platform login completes onboarding without a Mesting identity',
    (tester) async {
      store.value = const PlatformSession(userId: '7', token: 'test');
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);
      await container.read(platformAccountProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FirstLaunchAuthCoordinator(
              child: Scaffold(body: Text('已进入首页')),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('已进入首页'), findsOneWidget);
      expect(preferences.getBool(firstLaunchAuthCompletedPreferenceKey), true);
      expect(container.read(currentUserProvider), null);
    },
    skip: !DistributionChannel.isBeta,
  );
}
