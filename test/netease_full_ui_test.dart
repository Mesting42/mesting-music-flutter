import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mesting_music/core/persistence/app_preferences.dart';
import 'package:mesting_music/features/music_platform/domain/platform_session.dart';
import 'package:mesting_music/features/music_platform/music_platform_providers.dart';
import 'package:mesting_music/features/music_platform/platform_backend_providers.dart';
import 'package:mesting_music/features/music_platform/netease/netease_api.dart';
import 'package:mesting_music/features/music_platform/netease/netease_session.dart';
import 'package:mesting_music/features/music_platform/netease/netease_music_repository.dart';
import 'package:mesting_music/features/music_platform/netease/full/netease_catalog.dart';
import 'package:mesting_music/features/music_platform/netease/full/netease_full_page.dart';
import 'package:mesting_music/features/themes/app_theme.dart';
import 'package:mesting_music/features/themes/music_theme_preset.dart';
import 'package:mesting_music/shared/widgets/beta_glass_controls.dart';

const _session = NeteaseSession(
  userId: '7',
  cookies: {'MUSIC_U': 'synthetic-ui-session'},
  deviceId: 'fixture-device',
  nickname: '测试用户',
);

class _Account extends PlatformAccountController {
  @override
  Future<PlatformSession?> build() async => _session.identity;
  void replace(PlatformSession? account) => state = AsyncData(account);
}

void main() {
  final json =
      jsonDecode(
            File('assets/data/netease-full-catalog.json').readAsStringSync(),
          )
          as Map;
  final entries = [
    for (final raw in json['entries'] as List)
      NeteaseEndpoint.fromJson(Map<String, dynamic>.from(raw)),
  ];
  NeteaseEndpoint endpoint(String route) =>
      entries.firstWhere((e) => e.route == route);
  setUpAll(() async {
    await LiquidGlassWidgets.initialize();
    if (const bool.fromEnvironment('CAPTURE_NETEASE_FULL')) {
      for (final family in [
        'Roboto',
        'CupertinoSystemText',
        'CupertinoSystemDisplay',
        'MestingQA',
        'Microsoft YaHei',
        'Noto Sans SC',
        'sans-serif',
      ]) {
        await (FontLoader(family)..addFont(
              File(
                'C:/Windows/Fonts/msyh.ttc',
              ).readAsBytes().then(ByteData.sublistView),
            ))
            .load();
      }
      await (FontLoader('MaterialIcons')..addFont(
            File(
              'D:/CodexCache/flutter-3.41.9/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes().then(ByteData.sublistView),
          ))
          .load();
      await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
            rootBundle.load(
              'packages/cupertino_icons/assets/CupertinoIcons.ttf',
            ),
          ))
          .load();
    }
  });
  Future<ProviderContainer> mount(
    WidgetTester tester,
    Widget page, {
    bool dark = false,
    bool compact = false,
    http.Client? client,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = NeteaseApi(
      client ??
          MockClient(
            (request) async => http.Response(
              jsonEncode({
                'code': 200,
                'data': {'level': 8, 'listenSongs': 1200, 'nickname': '测试用户'},
                'msgs': [
                  {
                    'id': 8,
                    'msg': '你好，分享一首喜欢的音乐',
                    'fromUser': {'userId': 8, 'nickname': '音乐朋友'},
                  },
                ],
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
          ),
    )..configure(_session);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        platformAccountProvider.overrideWith(_Account.new),
        neteaseMusicRepositoryProvider.overrideWithValue(
          NeteaseMusicRepository(api),
        ),
        neteaseCatalogProvider.overrideWith((ref) async => entries),
      ],
    );
    addTearDown(container.dispose);
    await container.read(platformAccountProvider.future);
    await container.read(neteaseCatalogProvider.future);
    tester.view.physicalSize = compact
        ? const Size(320, 650)
        : const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme:
              buildMestingTheme(
                musicThemePresetById(dark ? 'classic-dark' : 'classic'),
              ).copyWith(
                textTheme: buildMestingTheme(
                  musicThemePresetById(dark ? 'classic-dark' : 'classic'),
                ).textTheme.apply(fontFamily: 'MestingQA'),
              ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(compact ? 1.5 : 1)),
            child: child!,
          ),
          home: RepaintBoundary(
            key: const ValueKey('full-capture'),
            child: Scaffold(body: page),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    return container;
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_NETEASE_FULL')) return;
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('full-capture')),
      );
      final image = await boundary.toImage(pixelRatio: 1.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File(
        '.codex-artifacts/2026-10-29-netease-full-scope/ui/$name.png',
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final dark in [false, true]) {
    for (final compact in [false, true]) {
      for (final entry in <String, Widget>{
        'social': const NeteaseFullHubPage(tab: '我的', category: '消息中心'),
        'message': NeteaseFullTaskPage(
          endpoint: endpoint('/send/text'),
          seed: const {'user_ids': '8', 'msg': '分享一首喜欢的音乐'},
        ),
        'account': NeteaseFullTaskPage(endpoint: endpoint('/user/level')),
        'retired': NeteaseFullTaskPage(
          endpoint: endpoint('/comment/hotwall/list'),
        ),
      }.entries) {
        testWidgets('${entry.key} dark=$dark compact=$compact', (tester) async {
          await mount(tester, entry.value, dark: dark, compact: compact);
          expect(find.textContaining('/api/'), findsNothing);
          await capture(
            tester,
            '${entry.key}-${dark ? 'dark' : 'light'}-${compact ? 'compact' : 'phone'}',
          );
        });
      }
    }
  }
  testWidgets('sending requires confirmation, cancellation performs no write', (
    tester,
  ) async {
    var writes = 0;
    await mount(
      tester,
      NeteaseFullTaskPage(
        endpoint: endpoint('/send/text'),
        seed: const {'user_ids': '8', 'msg': '测试消息'},
      ),
      client: MockClient((_) async {
        writes++;
        return http.Response('{"code":200}', 200);
      }),
    );
    expect(writes, 0);
    await tester.ensureVisible(find.text('确认提交'));
    await tester.tap(find.text('确认提交'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('确认发送私信？'), findsOneWidget);
    expect(writes, 0);
    await tester.tap(find.text('取消'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(writes, 0);
    await tester.tap(find.text('确认提交'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('确认'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(writes, 1);
  });
  testWidgets(
    'dragging from a task action cancels press before finger release',
    (tester) async {
      await mount(
        tester,
        NeteaseFullTaskPage(
          endpoint: endpoint('/send/text'),
          seed: const {'user_ids': '8', 'msg': '测试消息'},
        ),
        compact: true,
      );
      final action = find.widgetWithText(BetaGlassButton, '确认提交');
      await tester.ensureVisible(action);
      await tester.pump();
      final gesture = await tester.startGesture(tester.getCenter(action));
      await tester.pump(const Duration(milliseconds: 80));
      await gesture.moveBy(const Offset(0, -140));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('确认发送私信？'), findsNothing);
      await gesture.up();
      await tester.pump();
      expect(find.text('确认发送私信？'), findsNothing);
    },
  );
  testWidgets('old form disables its write after switching account', (
    tester,
  ) async {
    var writes = 0;
    final container = await mount(
      tester,
      NeteaseFullTaskPage(
        endpoint: endpoint('/send/text'),
        seed: const {'user_ids': '8', 'msg': '测试消息'},
      ),
      client: MockClient((_) async {
        writes++;
        return http.Response('{"code":200}', 200);
      }),
    );
    (container.read(platformAccountProvider.notifier) as _Account).replace(
      null,
    );
    await tester.pump();
    expect(find.text('账号已变化，请返回后重新打开'), findsOneWidget);
    expect(find.text('确认提交'), findsNothing);
    expect(writes, 0);
  });
}
