import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:mesting_music/features/experience/presentation/music_landing_page.dart';
import 'package:mesting_music/features/experience/presentation/music_library_page.dart';
import 'package:mesting_music/features/experience/presentation/cover_player_page.dart';
import 'package:mesting_music/features/experience/presentation/listening_replay_page.dart';
import 'package:mesting_music/features/player/presentation/music_shell.dart';
import 'package:mesting_music/features/player/presentation/music_navigation.dart';
import 'package:mesting_music/features/lyrics/domain/lyrics_document.dart';
import 'package:mesting_music/features/lyrics/lyrics_providers.dart';
import 'package:mesting_music/features/playlists/presentation/playlist_editor_dialog.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mesting_music/core/audio/mesting_audio_handler.dart';
import 'package:mesting_music/core/audio/playback_providers.dart';
import 'package:mesting_music/core/database/app_database.dart';
import 'package:mesting_music/core/persistence/app_preferences.dart';
import 'package:mesting_music/core/platform/distribution_channel.dart';
import 'package:mesting_music/features/auth/auth_providers.dart';
import 'package:mesting_music/features/auth/data/auth_repository.dart';
import 'package:mesting_music/features/library/library_providers.dart';
import 'package:mesting_music/features/library/data/library_repository.dart';
import 'package:mesting_music/features/themes/theme_controller.dart';

import 'package:mesting_music/features/music_platform/data/embedded_music_server.dart';
import 'package:mesting_music/features/music_platform/data/music_platform_api.dart';
import 'package:mesting_music/features/music_platform/data/platform_comments_repository.dart';
import 'package:mesting_music/features/music_platform/data/platform_library_repository.dart';
import 'package:mesting_music/features/music_platform/data/platform_session_store.dart';
import 'package:mesting_music/features/music_platform/domain/platform_session.dart';
import 'package:mesting_music/features/music_platform/music_platform_providers.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_account_page.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_comments_page.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_library_page.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_profile.dart';
import 'package:mesting_music/features/themes/app_theme.dart';
import 'package:mesting_music/features/themes/music_theme_preset.dart';
import 'package:mesting_music/shared/models/track.dart';

const _identity = PlatformSession(
  userId: '7',
  token: 'test',
  nickname: '音乐旅行者',
);
const _resource = PlatformCommentResource(
  kind: PlatformCommentKind.song,
  id: '12345',
  name: '认真的雪',
);
const _track = Track(
  id: 'kugou_HASH',
  title: '认真的雪',
  artist: '薛之谦',
  album: '薛之谦',
  duration: Duration(minutes: 4, seconds: 19),
  source: TrackSource.kugou,
  audioAsset: 'mesting-platform://kugou/kugou_HASH',
  platformSongId: '12345',
  coverAsset: 'assets/images/playlists/13416469337261709.jpeg',
  lyricsAsset: '',
);

class _Handler extends MestingAudioHandler {
  _Handler() : super(tracks: []);
}

class _Server implements MusicServer {
  @override
  Future<Uri> start() async => Uri.parse('http://127.0.0.1:12345');
}

class _Store implements PlatformSessionStore {
  _Store(this.session);
  final PlatformSession? session;
  @override
  Future<PlatformSession?> read() async => session;
  @override
  Future<void> write(PlatformSession session) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var fontsLoaded = false;
  setUpAll(() async {
    await LiquidGlassWidgets.initialize();
    // Optional local QA font, never bundled in the application/source assets.
    if (const bool.fromEnvironment('EXPORT_BETA_SCREENSHOTS')) {
      final font = File('C:/Windows/Fonts/msyh.ttc');
      if (await font.exists()) {
        final loader = FontLoader('BetaQACJK')
          ..addFont(
            font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await loader.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(
            File(
              'D:/flutter/mesting-beta5/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await icons.load();
        fontsLoaded = true;
      }
    }
  });
  late ProviderContainer container;
  late AppDatabase database;
  late MusicPlatformApi api;
  late LibraryRepository library;
  var qaPreset = musicThemePresetById('classic');
  late bool metadataReady;
  late List<String> paths;
  Future<void> prepare({bool guest = false}) async {
    metadataReady = false;
    paths = [];
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    api = MusicPlatformApi(
      server: _Server(),
      client: MockClient((request) async {
        paths.add(request.url.path);
        final Object data = switch (request.url.path) {
          '/user/detail' => {'nickname': '音乐旅行者'},
          '/audio' =>
            metadataReady
                ? {
                    'audio_info': [
                      {'Audioid': 12345},
                    ],
                  }
                : {},
          '/song/url' => {},
          '/user/playlist' => {
            'info': [
              {
                'listid': 11,
                'name': '我喜欢',
                'is_def': 2,
                'list_create_userid': 7,
              },
              {
                'listid': 22,
                'name': '慢慢听，慢慢喜欢',
                'global_collection_id': 'gid',
                'list_create_userid': 7,
              },
            ],
          },
          '/comment/music' || '/comment/music/topliked' || '/comment/floor' => {
            'childrenid': 'child',
            'list': [
              {
                'id': 'one',
                'user_id': 8,
                'user_name': '听风的人',
                'content': '一首歌，留住一段记忆。',
                'like_count': 109,
                'reply_num': 4,
                'special_child_id': 'child',
                'createtime': '2026-07-11 10:00:00',
              },
              {
                'id': 'two',
                'user_id': 7,
                'user_name': '音乐旅行者',
                'content': '今天也在认真听歌。',
                'like_count': 31,
                'special_child_id': 'child',
                'createtime': '2026-10-25 08:00:00',
              },
            ],
          },
          '/top/playlist' => [
            {'global_collection_id': 'gid', 'name': '让旋律陪你走过四季'},
          ],
          _ => {
            'info': [
              for (var i = 0; i < 3; i++)
                {
                  'hash': 'HASH$i',
                  'songname': ['认真的雪', '演员', '天外来物'][i],
                  'singername': '薛之谦',
                  'album_audio_id': 12345 + i,
                  'sizable_cover':
                      'assets/images/playlists/13416469337261709.jpeg',
                },
            ],
          },
        };
        return http.Response(
          jsonEncode({'status': 1, 'error_code': 0, 'data': data}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    )..session = guest ? null : _identity;
    library = guest
        ? LibraryRepository(database, ownerId: legacyLibraryOwnerId)
        : PlatformLibraryRepository(database, api: api, identity: _identity);
    await database.recordPlayback(
      'kugou:7',
      _track,
      const Duration(minutes: 32),
    );
    container = ProviderContainer(
      overrides: [
        effectiveMusicThemeProvider.overrideWith((ref) => qaPreset),
        appDatabaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        authRepositoryProvider.overrideWithValue(
          const UnconfiguredAuthRepository(),
        ),
        platformSessionStoreProvider.overrideWithValue(
          _Store(guest ? null : _identity),
        ),
        musicPlatformApiProvider.overrideWithValue(api),
        libraryRepositoryProvider.overrideWithValue(library),
        audioHandlerProvider.overrideWithValue(_Handler()),
        currentMediaItemProvider.overrideWith(
          (ref) => Stream.value(_track.toMediaItem()),
        ),
        currentTrackProvider.overrideWithValue(_track),
        positionProvider.overrideWith(
          (ref) => Stream.value(const Duration(seconds: 37)),
        ),
        durationProvider.overrideWith((ref) => Stream.value(_track.duration)),
        lyricsProvider.overrideWith(
          (ref, asset) async => const LyricsDocument(
            isSynced: true,
            lines: [
              LyricsLine(time: Duration.zero, text: '每一段旋律'),
              LyricsLine(time: Duration(seconds: 20), text: '都留下自己的足迹'),
              LyricsLine(time: Duration(seconds: 40), text: '在音乐里继续向前'),
            ],
          ),
        ),
        playbackStateProvider.overrideWith(
          (ref) => Stream.value(PlaybackState()),
        ),
      ],
    );
    await container.read(platformAccountProvider.future);
  }

  Future<void> disposeFixture(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    library.dispose();
    // Drift removes cancelled watched queries on a zero-duration timer.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    // Flutter runs addTearDown on the real loop after draining fake-time streams.
  }

  Future<void> captureScreenshot(WidgetTester tester, String capture) async {
    if (const bool.fromEnvironment('EXPORT_BETA_SCREENSHOTS')) {
      // Asset decoding uses real I/O. Wait for all visible artwork before QA.
      final context = tester.element(find.byType(MaterialApp).first);
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      await tester.runAsync(() async {
        await Future.wait(
          images.map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pump(const Duration(milliseconds: 500));
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('beta5-capture')),
      );
      await tester.runAsync(() async {
        final picture = await boundary.toImage();
        final png = await picture.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory(
          const String.fromEnvironment('BETA_SCREENSHOT_DIR'),
        );
        await directory.create(recursive: true);
        await File(
          '${directory.path}/$capture.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        picture.dispose();
      });
    }
  }

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    bool dark = false,
    String? capture,
    bool shell = false,
    String location = '/music/recommend',
    double scale = 1,
  }) async {
    final theme = buildMestingTheme(
      musicThemePresetById(dark ? 'classic-dark' : 'classic'),
    );
    qaPreset = musicThemePresetById(dark ? 'classic-dark' : 'classic');
    container.invalidate(effectiveMusicThemeProvider);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        for (final path in [
          '/music',
          '/music/recommend',
          '/music/library',
          '/profile',
          '/music/search',
        ])
          GoRoute(
            path: path,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey('$capture-$scale-$dark'),
              child: shell
                  ? MusicShell(location: state.uri.toString(), child: page)
                  : Scaffold(
                      backgroundColor: theme.colorScheme.surface,
                      body: page,
                    ),
            ),
          ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: const ValueKey('beta5-capture'),
          child: LiquidGlassWidgets.wrap(
            brightnessResolver: Theme.maybeBrightnessOf,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: fontsLoaded
                  ? theme.copyWith(
                      textTheme: theme.textTheme.apply(fontFamily: 'BetaQACJK'),
                    )
                  : theme,
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), null);
    if (capture != null) await captureScreenshot(tester, capture);
  }

  void viewport(WidgetTester tester, [Size size = const Size(390, 844)]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'beta5 cover-led pages render in both themes and wide layouts',
    (tester) async {
      viewport(tester);
      await prepare();
      for (final dark in [false, true]) {
        final suffix = dark ? 'dark' : 'light';
        await pump(
          tester,
          const MusicLandingPage(),
          shell: true,
          dark: dark,
          capture: 'home-$suffix',
        );
        expect(find.text('为你精选'), findsOneWidget);
        expect(find.byType(MusicBottomNavigation), findsOneWidget);
        await pump(
          tester,
          const MusicLandingPage(discovery: true),
          shell: true,
          location: '/music',
          dark: dark,
          capture: 'discover-$suffix',
        );
        await pump(
          tester,
          const MusicLibraryPage(),
          shell: true,
          location: '/music/library',
          dark: dark,
          capture: 'library-$suffix',
        );
        await pump(
          tester,
          const MusicLibraryPage(view: 'favorites'),
          shell: true,
          location: '/music/library',
          dark: dark,
          capture: 'favorites-$suffix',
        );
        await pump(
          tester,
          const ListeningReplayPage(),
          shell: true,
          location: '/music/library',
          dark: dark,
          capture: 'replay-$suffix',
        );
        expect(
          find.text('${DateTime.now().month} 月').hitTestable(),
          findsOneWidget,
        );
        await pump(
          tester,
          const CoverPlayerPage(key: ValueKey('qa-cover')),
          dark: dark,
          capture: 'player-$suffix',
        );
        await pump(
          tester,
          const CoverPlayerPage(
            lyricsInitially: true,
            key: ValueKey('qa-lyrics'),
          ),
          dark: dark,
          capture: 'lyrics-$suffix',
        );
        await pump(
          tester,
          const PlatformAccountPage(),
          dark: dark,
          capture: 'account-$suffix',
        );
        await pump(
          tester,
          const PlatformProfile(),
          shell: true,
          location: '/profile',
          dark: dark,
          capture: 'profile-$suffix',
        );
        await pump(
          tester,
          PlatformCommentsPage(
            resource: _resource,
            repository: PlatformCommentsRepository(api, _identity),
          ),
          dark: dark,
          capture: 'comments-$suffix',
        );
        await pump(
          tester,
          const PlatformCloudPlaylistPage(id: 'kg:22'),
          dark: dark,
          capture: 'playlist-$suffix',
        );
      }
      tester.view.physicalSize = const Size(1024, 768);
      await pump(
        tester,
        const MusicLandingPage(),
        shell: true,
        capture: 'home-wide',
      );
      await pump(
        tester,
        const MusicLibraryPage(),
        shell: true,
        location: '/music/library',
        capture: 'library-wide',
      );
      await pump(
        tester,
        const CoverPlayerPage(lyricsInitially: true),
        capture: 'lyrics-wide',
      );
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'small windows and larger text retain transport and editor actions',
    (tester) async {
      viewport(tester, const Size(320, 640));
      await prepare(guest: true);
      await pump(
        tester,
        const CoverPlayerPage(key: ValueKey('qa-cover')),
        scale: 1.6,
        capture: 'player-accessibility',
      );
      await pump(
        tester,
        const MusicLibraryPage(),
        shell: true,
        scale: 1.6,
        location: '/music/library',
        capture: 'library-accessibility',
      );
      await pump(tester, const PlatformAccountPage(), capture: 'login-narrow');
      await tester.showKeyboard(find.byType(TextField).first);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pump();
      expect(tester.takeException(), null);
      tester.view.resetViewInsets();
      await pump(
        tester,
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () =>
                  showPlaylistEditorDialog(context, initialName: '慢慢听'),
              child: const Text('编辑歌单'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('编辑歌单'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('保存歌单'), findsOneWidget);
      expect(tester.takeException(), null);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'playlist editor keeps fixed confirmation and cover controls',
    (tester) async {
      viewport(tester);
      await prepare();
      await pump(
        tester,
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () =>
                  showPlaylistEditorDialog(context, initialName: '慢慢听，慢慢喜欢'),
              child: const Text('编辑'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();
      await captureScreenshot(tester, 'playlist-editor-light');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.showKeyboard(
        find.byKey(const ValueKey('playlist-editor-name-field')),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('保存歌单').hitTestable(), findsOneWidget);
      expect(tester.takeException(), null);
      await captureScreenshot(tester, 'playlist-editor-keyboard');
      tester.view.resetViewInsets();
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );
}
