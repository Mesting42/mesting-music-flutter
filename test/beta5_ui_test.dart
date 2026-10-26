import 'package:mesting_music/features/music_platform/data/platform_category_search.dart';
import 'package:mesting_music/features/settings/presentation/settings_page.dart';
import 'package:mesting_music/features/music_platform/platform_category_search_providers.dart';
import 'package:mesting_music/features/search/presentation/beta_category_search_results.dart';
import 'package:mesting_music/features/library/presentation/library_access.dart';
import 'dart:async';
import 'package:mesting_music/app/router/app_router.dart' as production;
import 'package:mesting_music/features/experience/presentation/floating_playback_pill.dart';
import 'package:mesting_music/features/experience/presentation/beta_music_shell.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_comment_composer.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_design.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:mesting_music/features/experience/presentation/music_landing_page.dart';
import 'package:mesting_music/features/experience/presentation/music_library_page.dart';
import 'package:mesting_music/features/experience/presentation/beta_now_playing_page.dart';
import 'package:mesting_music/features/experience/presentation/apple_player_controls.dart';
import 'package:mesting_music/features/experience/presentation/player_content_transition.dart';
import 'package:mesting_music/core/audio/media_volume_controller.dart';
import 'package:mesting_music/features/music_platform/platform_recommendation_providers.dart';
import 'package:mesting_music/features/music_platform/data/platform_recommendations.dart';
import 'package:mesting_music/features/music_platform/presentation/platform_search_landing.dart';
import 'package:mesting_music/features/music_platform/data/platform_explore.dart';
import 'package:mesting_music/features/search/presentation/music_search_page.dart';
import 'package:mesting_music/features/search/presentation/apple_search_results.dart';
import 'package:mesting_music/features/search/search_providers.dart';
import 'package:mesting_music/shared/widgets/music_notice.dart';
import 'package:mesting_music/shared/widgets/track_artwork.dart';
import 'package:mesting_music/features/experience/presentation/listening_replay_page.dart';
import 'package:mesting_music/features/player/presentation/music_shell.dart';
import 'package:mesting_music/features/player/player_visual_style.dart';
import 'package:mesting_music/features/player/presentation/now_playing_page.dart';
import 'package:mesting_music/features/experience/presentation/beta_bottom_bar.dart';
import 'package:mesting_music/features/lyrics/domain/lyrics_document.dart';
import 'package:mesting_music/features/lyrics/lyrics_providers.dart';
import 'package:mesting_music/features/playlists/presentation/playlist_editor_dialog.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons, CupertinoTextField;
import 'package:mesting_music/features/themes/theme_gallery_page.dart';
import 'package:mesting_music/features/themes/startup_style_picker.dart';
import 'package:mesting_music/features/music_platform/platform_catalog_providers.dart';
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

final _qaRecordingProvider = NotifierProvider<_QARecording, Track>(
  _QARecording.new,
);

class _QARecording extends Notifier<Track> {
  @override
  Track build() => _track;
  void select(Track track) => state = track;
}

/// Local UI catalogue fixtures; real wire parsing is covered separately.
class _CategoryFixtures extends PlatformCategorySearchRepository {
  _CategoryFixtures(super.api);
  @override
  Future<PlatformCategoryPage> search(
    String query,
    PlatformSearchKind kind, {
    int page = 1,
    Future<void>? abortTrigger,
  }) async => PlatformCategoryPage(
    [
      for (var i = 0; i < 4; i++)
        PlatformSearchHit(
          kind: kind,
          id: '$i',
          title: kind == PlatformSearchKind.albums
              ? ['意外', '绅士', '初学者', '天外来物'][i]
              : kind == PlatformSearchKind.artists
              ? ['薛之谦', '薛之谦(2)', '薛之谦fm', '薛之谦jokx'][i]
              : kind == PlatformSearchKind.playlists
              ? ['薛之谦必听热歌', '演唱会曲目', '夜深别听薛之谦', '精选伤感歌单'][i]
              : '演员',
          subtitle: '薛之谦',
          cover: _track.coverAsset,
          globalId: 'collection-real-$i',
          count: 139 + i,
          track: kind == PlatformSearchKind.lyrics ? _track : null,
          lyric: kind == PlatformSearchKind.lyrics
              ? '薛之谦 - 演员  词：薛之谦  曲：薛之谦'
              : '',
        ),
    ],
    4,
    false,
  );
}

class _Volume extends MediaVolumeController {
  @override
  MediaVolumeState build() =>
      const MediaVolumeState(value: .55, available: true);
  @override
  Future<void> setVolume(double value) async {
    state = MediaVolumeState(value: value, available: true);
  }
}

class _Handler extends MestingAudioHandler {
  _Handler() : super(tracks: []);
  final presentationCommands = StreamController<String>.broadcast(sync: true);
  @override
  Stream<String> get userCommandStream => presentationCommands.stream;
  @override
  Future<void> skipToNext() async => presentationCommands.add('skipNext');
  @override
  Future<void> skipToPrevious() async =>
      presentationCommands.add('skipPrevious');
  int toggles = 0;
  @override
  Future<void> togglePlayPause() async {
    toggles++;
  }
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
        // Cupertino widgets choose the iOS font family inside GlassScaffold.
        // Supply its CJK test substitute as well; device builds use system fonts.
        for (final family in [
          'Roboto', // Material chip labels select this family directly.
          'CupertinoSystemText',
          'CupertinoSystemDisplay',
        ]) {
          await (FontLoader(family)..addFont(
                font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
              ))
              .load();
        }
        final icons = FontLoader('MaterialIcons')
          ..addFont(
            File(
              'D:/flutter/mesting-beta5/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await icons.load();
        final cupertino = FontLoader('packages/cupertino_icons/CupertinoIcons')
          ..addFont(
            rootBundle.load(
              'packages/cupertino_icons/assets/CupertinoIcons.ttf',
            ),
          );
        await cupertino.load();
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
  Future<void> prepare({
    bool guest = false,
    bool standardOnly = false,
    bool qualityUnknown = false,
    bool playing = false,
    Stream<PlaybackState>? playbackEvents,
  }) async {
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
            (!qualityUnknown &&
                    (metadataReady ||
                        request.url.queryParameters['hash'] == 'HASH'))
                ? {
                    'audio_info': [
                      {
                        'Audioid': 12345,
                        'hash': 'sd',
                        if (!standardOnly) 'hash_320': 'hq',
                        if (!standardOnly) 'hash_flac': 'sq',
                        if (!standardOnly) 'hash_high': 'hires',
                      },
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
        platformCategorySearchRepositoryProvider.overrideWithValue(
          _CategoryFixtures(api),
        ),
        libraryRepositoryProvider.overrideWithValue(library),
        audioHandlerProvider.overrideWithValue(_Handler()),
        currentMediaItemProvider.overrideWith(
          (ref) => Stream.value(_track.toMediaItem()),
        ),
        currentTrackProvider.overrideWith(
          (ref) => ref.watch(_qaRecordingProvider),
        ),
        mediaVolumeProvider.overrideWith(_Volume.new),
        // These are parsed UI fixtures, not wire payloads. Real platform cover
        // parsing rejects asset filenames and is covered in beta6_platform_test.
        platformFmProvider.overrideWith((ref) async => [_track]),
        platformHotSearchProvider.overrideWith(
          (ref) async => const [
            PlatformHotSearchBoard('热搜榜', ['认真的雪', '平凡之路', '音乐让我们相遇']),
          ],
        ),
        platformExploreProvider.overrideWith(
          (ref, kind) async => [
            PlatformExploreItem(
              id: '1',
              title: kind.label,
              cover: _track.coverAsset,
              kind: kind,
            ),
          ],
        ),
        platformDailyProvider.overrideWith((ref) async => [_track]),
        platformNewSongsProvider.overrideWith((ref) async => [_track]),
        platformDiscoveryProvider.overrideWith((ref) async => [_track]),
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
          (ref) =>
              playbackEvents ??
              Stream.value(
                PlaybackState(
                  playing: playing,
                  processingState: AudioProcessingState.ready,
                ),
              ),
        ),
      ],
    );
    await container.read(platformAccountProvider.future);
  }

  Future<void> disposeFixture(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await (container.read(audioHandlerProvider) as _Handler)
        .presentationCommands
        .close();
    container.dispose();
    library.dispose();
    // Drift removes cancelled watched queries on a zero-duration timer.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    // Flutter runs addTearDown on the real loop after draining fake-time streams.
  }

  Future<void> captureScreenshot(
    WidgetTester tester,
    String capture, {
    Duration settle = const Duration(milliseconds: 500),
  }) async {
    if (const bool.fromEnvironment('EXPORT_BETA_SCREENSHOTS')) {
      // Asset decoding uses real I/O. Wait for all visible artwork before QA.
      final context = tester.element(find.byType(MaterialApp).first);
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      await tester.runAsync(() async {
        await Future.wait(
          images.map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pump(settle);
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
          '${directory.path}/${capture.replaceFirst('beta7-', 'beta9-').replaceFirst('beta8-', 'beta9-')}.png',
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
          '/music/settings',
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
            adaptiveQuality: false,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: fontsLoaded
                  ? theme.copyWith(
                      textTheme: theme.textTheme.apply(fontFamily: 'BetaQACJK'),
                      chipTheme: theme.chipTheme.copyWith(
                        labelStyle:
                            (theme.chipTheme.labelStyle ?? const TextStyle())
                                .copyWith(fontFamily: 'BetaQACJK'),
                      ),
                      listTileTheme: theme.listTileTheme.copyWith(
                        subtitleTextStyle:
                            (theme.listTileTheme.subtitleTextStyle ??
                                    const TextStyle())
                                .copyWith(fontFamily: 'BetaQACJK'),
                      ),
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
        expect(find.byType(BetaMusicBottomBar), findsOneWidget);
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
          const BetaNowPlayingPage(key: ValueKey('qa-cover')),
          dark: dark,
          capture: 'player-$suffix',
        );
        await pump(
          tester,
          const BetaNowPlayingPage(
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
          const SettingsPage(),
          shell: true,
          location: '/music/settings',
          dark: dark,
          capture: 'settings-$suffix',
        );
        expect(
          find.byKey(const ValueKey('settings-open-source')),
          findsOneWidget,
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
        const BetaNowPlayingPage(lyricsInitially: true),
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
        const BetaNowPlayingPage(key: ValueKey('qa-cover')),
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

  testWidgets(
    'beta7 official bottom morph, embedded search and quality dialog',
    (tester) async {
      viewport(tester);
      await prepare();
      await pump(
        tester,
        const MusicLandingPage(),
        shell: true,
        capture: 'beta7-home-expanded',
      );
      expect(
        tester
            .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
            .inline,
        false,
      );
      final navigationLabel = tester.element(find.text('首页').last);
      final navigationText = DefaultTextStyle.of(navigationLabel).style;
      expect(navigationText.fontFamily, isNot('monospace'));
      expect(navigationText.decoration, isNot(TextDecoration.underline));
      await tester.drag(find.byType(ListView).first, const Offset(0, -450));
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        tester
            .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
            .inline,
        true,
      );
      await captureScreenshot(tester, 'beta7-home-collapsed');
      await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().last);
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        tester
            .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
            .inline,
        false,
      );
      await captureScreenshot(tester, 'beta7-search-expanded');
      await tester.enterText(find.byType(CupertinoTextField).last, '薛之谦');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), null);
      final searchField = tester.getRect(find.byType(CupertinoTextField).last);
      final keyboardTop = tester.view.physicalSize.height - 280;
      expect(searchField.bottom, lessThanOrEqualTo(keyboardTop));
      expect(searchField.bottom, greaterThan(keyboardTop - 120));
      await captureScreenshot(tester, 'beta7-search-keyboard');
      tester.view.resetViewInsets();
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta7 quality dialog and every player appearance share the entry',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        viewport(tester);
        await prepare();
        await pump(tester, const BetaNowPlayingPage());
        await tester.tap(find.byKey(const ValueKey('player-quality-button')));
        await tester.pump(const Duration(milliseconds: 400));
        for (var frame = 0; frame < 5; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        for (final label in ['标准', '高品质', '无损', 'Hi-Res']) {
          expect(find.text(label), findsOneWidget);
        }
        await captureScreenshot(tester, 'beta7-quality-dialog');
        for (final style in PlayerVisualStyle.values) {
          await container
              .read(playerVisualStyleProvider.notifier)
              .select(style);
          await pump(tester, NowPlayingPage(key: ValueKey(style.id)));
          expect(
            find.byKey(const ValueKey('player-quality-button')),
            findsOneWidget,
            reason: style.displayName,
          );
          expect(find.byType(ApplePlayerControls), findsOneWidget);
          final seek = tester.widget<Slider>(
            find.byKey(const ValueKey('playback-seek-slider')),
          );
          final volume = tester.widget<Slider>(
            find.byKey(const ValueKey('system-media-volume')),
          );
          expect(seek.semanticFormatterCallback!(37000), '0分37秒，共4分19秒');
          expect(volume.semanticFormatterCallback!(.55), '55%');
          final seekNode = tester
              .getSemantics(
                find.byKey(const ValueKey('playback-seek-semantics')),
              )
              .getSemanticsData();
          final volumeNode = tester
              .getSemantics(
                find.byKey(const ValueKey('media-volume-semantics')),
              )
              .getSemanticsData();
          expect(seekNode.label, '播放进度');
          expect(seekNode.value, '0分37秒，共4分19秒');
          expect(seekNode.hasAction(ui.SemanticsAction.increase), true);
          expect(volumeNode.label, '系统媒体音量');
          expect(volumeNode.value, '55%');
          expect(volumeNode.hasAction(ui.SemanticsAction.decrease), true);
          expect(
            find.byKey(const ValueKey('system-media-volume')),
            findsOneWidget,
          );
          expect(find.byTooltip('歌曲评论'), findsOneWidget);
          expect(find.byTooltip('播放队列'), findsOneWidget);
          await captureScreenshot(tester, 'beta7-player-${style.name}');
        }
        await disposeFixture(tester);
      } finally {
        semantics.dispose();
      }
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta7 dress-up keeps progress characters and removes retired controls',
    (tester) async {
      viewport(tester);
      await prepare();
      await pump(
        tester,
        const ThemeGalleryPage(),
        capture: 'beta7-dress-up-top',
      );
      expect(find.text('品牌套装'), findsNothing);
      expect(find.text('经典皮肤'), findsNothing);
      expect(find.text('蜡笔小新'), findsNothing);
      expect(find.text('春日部晴空'), findsNothing);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('背景显示强度'), findsNothing);
      expect(find.text('动态效果性能'), findsNothing);
      expect(find.text('IP 角色装饰'), findsNothing);
      expect(find.text('跟随皮肤'), findsNothing);
      expect(find.text('Hello Kitty'), findsWidgets);
      expect(find.text('库洛米'), findsWidgets);
      await captureScreenshot(tester, 'beta7-dress-up-progress');
      expect(tester.takeException(), null);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta8 standard-only song hides unsupported tiers and permission hints',
    (tester) async {
      viewport(tester);
      await prepare(standardOnly: true);
      await pump(tester, const BetaNowPlayingPage());
      await tester.tap(find.byKey(const ValueKey('player-quality-button')));
      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('标准'), findsOneWidget);
      for (final label in ['高品质', '无损', 'Hi-Res', '需要会员／相应权限']) {
        expect(find.text(label), findsNothing);
      }
      await captureScreenshot(tester, 'beta8-quality-standard-only');
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta8 unknown quality metadata exposes retry instead of fabricated options',
    (tester) async {
      viewport(tester);
      await prepare(qualityUnknown: true);
      await pump(tester, const BetaNowPlayingPage());
      await tester.tap(find.byKey(const ValueKey('player-quality-button')));
      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('暂未获取到歌曲音质信息'), findsOneWidget);
      expect(find.byKey(const ValueKey('quality-option-128')), findsNothing);
      final before = paths.where((p) => p == '/audio').length;
      await tester.tap(find.text('重新加载'));
      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(paths.where((p) => p == '/audio').length, before + 1);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );
  testWidgets(
    'beta7 shared status HUD replaces stale actions at the top',
    (tester) async {
      viewport(tester);
      await prepare();
      await pump(
        tester,
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showMusicNotice(
                context,
                icon: Icons.check_rounded,
                title: '单曲循环',
                message: '播放模式已切换',
              ),
              child: const Text('显示提示'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('显示提示'));
      await tester.pump(const Duration(milliseconds: 300));
      await captureScreenshot(tester, 'beta7-status-hud-light');
      final context = tester.element(find.text('显示提示'));
      showMusicNotice(
        context,
        icon: Icons.favorite_rounded,
        title: '已添加到喜欢',
        message: '',
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('单曲循环'), findsNothing);
      expect(find.text('已添加到喜欢'), findsOneWidget);
      await captureScreenshot(tester, 'beta7-status-hud-replaced');
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );
  testWidgets(
    'beta7 standalone search also excludes local recommendation scoring',
    (tester) async {
      viewport(tester);
      await prepare();
      await pump(tester, const MusicSearchPage());
      expect(find.byType(PlatformSearchLanding), findsOneWidget);
      expect(find.text('猜你喜欢'), findsNothing);
      expect(find.text('我的热榜'), findsNothing);
      expect(find.text('热门搜索'), findsOneWidget);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta8 search builds a viewport of 480 rows and retains actions',
    (tester) async {
      viewport(tester);
      await prepare();
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final songs = [
        for (var i = 0; i < 480; i++)
          Track(
            id: 'kugou_HASH$i',
            title: ['演员', '天外来物', '认真的雪'][i % 3],
            artist: '薛之谦',
            album: '音乐作品',
            duration: _track.duration,
            audioAsset: _track.audioAsset,
            coverAsset: _track.coverAsset,
            lyricsAsset: '',
            source: TrackSource.kugou,
          ),
      ];
      final state = MusicSearchState(
        query: '薛之谦',
        onlineTracks: songs,
        total: 480,
      );
      for (final dark in [false, true]) {
        await pump(
          tester,
          AppleSearchResults(state: state, controller: scroll),
          dark: dark,
          capture: 'beta8-search-results-${dark ? 'dark' : 'light'}',
        );
        final built = find.byType(TrackArtwork).evaluate().length;
        expect(built, lessThan(25));
        // ignore: avoid_print
        print('BETA8_SEARCH_BENCH catalogue=480 visibleArtworkWidgets=$built');
        expect(find.byTooltip('歌曲操作'), findsWidgets);
      }
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta8 anchored more menu stays grouped at phone and large-text widths',
    (tester) async {
      viewport(tester);
      await prepare();
      await container
          .read(playerVisualStyleProvider.notifier)
          .select(PlayerVisualStyle.classic);
      for (final narrow in [false, true]) {
        tester.view.physicalSize = narrow
            ? const Size(320, 640)
            : const Size(390, 844);
        await pump(tester, const BetaNowPlayingPage(), scale: narrow ? 1.6 : 1);
        await tester.tap(find.byTooltip('更多操作'));
        for (var frame = 0; frame < 5; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.text('查看歌词'), findsOneWidget);
        expect(find.text('黑胶唱片'), findsOneWidget);
        expect(tester.takeException(), null);
        await captureScreenshot(
          tester,
          narrow ? 'beta8-more-narrow' : 'beta8-more-phone',
        );
        await tester.tapAt(const Offset(20, 160));
        await tester.pump(const Duration(milliseconds: 300));
      }
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta8 detail navigation keeps the tab that opened it',
    (tester) async {
      viewport(tester);
      await prepare();
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                MusicShell(location: state.uri.toString(), child: child),
            routes: [
              for (final path in [
                '/profile',
                '/music/library',
                '/music',
                '/music/settings',
                '/player',
              ])
                GoRoute(path: path, builder: (_, _) => const SizedBox.expand()),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: LiquidGlassWidgets.wrap(
            brightnessResolver: Theme.maybeBrightnessOf,
            child: MaterialApp.router(
              theme: buildMestingTheme(musicThemePresetById('classic')),
              routerConfig: router,
            ),
          ),
        ),
      );
      Future<void> settle() async {
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      int selected() => tester
          .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
          .selectedIndex;
      await settle();
      expect(selected(), 3);
      router.push('/music?view=favorites');
      await settle();
      expect(selected(), 3);
      for (final overlay in ['/music/settings', '/player']) {
        router.push(overlay);
        await settle();
        expect(
          tester
              .widget<BetaMusicShell>(find.byType(BetaMusicShell))
              .chromeVisible,
          false,
        );
        expect(find.byType(BetaMusicBottomBar), findsOneWidget);
        router.pop();
        await settle();
        expect(selected(), 3);
      }
      router.pop();
      await settle();
      expect(selected(), 3);
      router.go('/music/library');
      await settle();
      expect(selected(), 2);
      router.push('/music?view=favorites');
      await settle();
      expect(selected(), 2);
      router.push('/music/settings');
      await settle();
      expect(
        tester
            .widget<BetaMusicShell>(find.byType(BetaMusicShell))
            .chromeVisible,
        false,
      );
      expect(find.byType(BetaMusicBottomBar), findsOneWidget);
      router.pop();
      await settle();
      expect(selected(), 2);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta8 playing vinyl stays on grooves and year menu is rounded',
    (tester) async {
      viewport(tester);
      await prepare(playing: true);
      await container
          .read(playerVisualStyleProvider.notifier)
          .select(PlayerVisualStyle.classic);
      await pump(
        tester,
        const BetaNowPlayingPage(),
        capture: 'beta8-vinyl-playing',
      );
      await pump(tester, const ListeningReplayPage());
      await tester.tap(find.byTooltip('选择年份'));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('${DateTime.now().year} 年'), findsOneWidget);
      await captureScreenshot(tester, 'beta8-replay-year-menu');
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta9 both search edges and Router system Back follow result, landing, origin',
    (tester) async {
      viewport(tester);
      await prepare();
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                MusicShell(location: state.uri.toString(), child: child),
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const MusicLandingPage(),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: LiquidGlassWidgets.wrap(
            brightnessResolver: Theme.maybeBrightnessOf,
            child: MaterialApp.router(
              theme: buildMestingTheme(musicThemePresetById('classic')),
              routerConfig: router,
            ),
          ),
        ),
      );
      Future<void> frames() async {
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      Future<void> openResults() async {
        await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().last);
        await frames();
        await tester.enterText(find.byType(CupertinoTextField).last, '薛之谦');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await frames();
        expect(find.text('搜索结果'), findsNothing);
        expect(
          find.byKey(const ValueKey('search-kind-albums')),
          findsOneWidget,
        );
      }

      await frames();
      final bar = tester.element(find.byType(BetaMusicBottomBar));
      await openResults();
      await tester.dragFrom(const Offset(5, 240), const Offset(140, 0));
      await frames();
      expect(find.byType(PlatformSearchLanding), findsOneWidget);
      await tester.dragFrom(const Offset(385, 240), const Offset(-140, 0));
      await frames();
      expect(find.byType(PlatformSearchLanding), findsNothing);
      expect(
        tester
            .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
            .selectedIndex,
        3,
      );
      expect(
        identical(tester.element(find.byType(BetaMusicBottomBar)), bar),
        true,
      );
      await openResults();
      await tester.binding.handlePopRoute();
      await frames();
      expect(find.byType(PlatformSearchLanding), findsOneWidget);
      await tester.binding.handlePopRoute();
      await frames();
      expect(find.byType(PlatformSearchLanding), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/profile');
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta9 comment filters share one row and composer uses sibling liquid glass',
    (tester) async {
      viewport(tester);
      await prepare();
      for (final dark in [false, true]) {
        await pump(
          tester,
          PlatformCommentsPage(
            resource: _resource,
            repository: PlatformCommentsRepository(api, _identity),
          ),
          dark: dark,
          capture: 'beta9-comments-${dark ? 'dark' : 'light'}',
        );
        final sort = find.byTooltip('评论排序');
        final scope = find.byTooltip('评论范围');
        expect(
          (tester.getCenter(sort).dy - tester.getCenter(scope).dy).abs(),
          lessThan(1),
        );
        expect(find.byType(ChoiceChip), findsNothing);
        expect(
          find.byKey(const ValueKey('comment-liquid-glass-input')),
          findsOneWidget,
        );
        final send = find.byKey(const ValueKey('comment-blue-glass-send'));
        expect(tester.getSize(send), const Size(48, 48));
        expect(tester.getSize(find.byType(TextField)).height, lessThan(60));
        await tester.tap(sort);
        await tester.pumpAndSettle();
        expect(find.text('最新'), findsOneWidget);
        await tester.tap(find.text('最新').hitTestable());
        await tester.pumpAndSettle();
        expect(find.text('最新'), findsOneWidget);
        expect(find.byType(PlatformCommentComposer), findsOneWidget);
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.getBottomRight(send).dy, lessThan(844 - 280));
        expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 2);
        tester.view.resetViewInsets();
      }
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta9 playback pill position events do not rebuild the glass control',
    (tester) async {
      viewport(tester);
      final events = StreamController<PlaybackState>.broadcast(sync: true);
      await prepare(playbackEvents: events.stream);
      await pump(tester, const MusicLandingPage(), shell: true);
      events.add(
        PlaybackState(
          playing: true,
          processingState: AudioProcessingState.ready,
        ),
      );
      await tester.pump();
      var rebuilds = 0;
      final previous = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (element, builtOnce) {
        previous?.call(element, builtOnce);
        if (element.widget is FloatingPlaybackPill) rebuilds++;
      };
      try {
        for (var i = 0; i < 100; i++) {
          events.add(
            PlaybackState(
              playing: true,
              processingState: AudioProcessingState.ready,
              updatePosition: Duration(milliseconds: i * 100),
            ),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
      } finally {
        debugOnRebuildDirtyWidget = previous;
      }
      // ignore: avoid_print
      print(
        'BETA9_PILL_BENCH positionEvents=100 glassControlRebuilds=$rebuilds',
      );
      if (!const bool.fromEnvironment('BETA_BENCHMARK_BASELINE')) {
        expect(rebuilds, lessThanOrEqualTo(1));
      }
      await disposeFixture(tester);
      await events.close();
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta9 narrow comment keyboard and long title remain usable',
    (tester) async {
      viewport(tester, const Size(320, 640));
      await prepare();
      await pump(
        tester,
        PlatformCommentsPage(
          resource: _resource,
          repository: PlatformCommentsRepository(api, _identity),
        ),
        scale: 1.6,
        capture: 'beta9-comments-narrow-large',
      );
      await tester.enterText(
        find.byType(TextField),
        '每一段旋律，都留下自己的故事。\n今天也在认真听歌。',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pump(const Duration(milliseconds: 300));
      final send = find.byKey(const ValueKey('comment-blue-glass-send'));
      expect(tester.getBottomRight(send).dy, lessThan(360));
      expect(send.hitTestable(), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 2);
      expect(tester.takeException(), null);
      await captureScreenshot(tester, 'beta9-comments-keyboard-large');
      tester.view.resetViewInsets();
      await pump(
        tester,
        const PlatformPageFrame(
          title: '暖场小曲：深夜酒吧的走心时刻',
          child: Center(child: Text('歌曲列表')),
        ),
        capture: 'beta9-title-start',
      );
      final title = find.text('暖场小曲：深夜酒吧的走心时刻');
      final start = tester.getTopLeft(title).dx;
      await tester.pump(const Duration(seconds: 3));
      expect(tester.getTopLeft(title).dx, lessThan(start));
      await captureScreenshot(
        tester,
        'beta9-title-scrolling',
        settle: Duration.zero,
      );
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta10 search and production routes keep opaque middle frames in both themes',
    (tester) async {
      viewport(tester);
      for (final dark in [false, true]) {
        await prepare();
        await pump(tester, const MusicLandingPage(), shell: true, dark: dark);
        await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 90));
        final surface = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('beta10-search-surface')),
        );
        expect(surface.color.a, 1);
        await captureScreenshot(
          tester,
          'beta10-search-enter-middle-${dark ? 'dark' : 'light'}',
          settle: Duration.zero,
        );
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.byType(MusicLandingPage), findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 90));
        await captureScreenshot(
          tester,
          'beta10-search-exit-middle-${dark ? 'dark' : 'light'}',
          settle: Duration.zero,
        );
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.byType(MusicLandingPage), findsOneWidget);
        await disposeFixture(tester);
      }
      await prepare();
      production.appRouter.go('/music/recommend');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: production.appRouter,
            theme: buildMestingTheme(musicThemePresetById('classic')),
            builder: (context, child) => RepaintBoundary(
              key: const ValueKey('beta5-capture'),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      final pushed = production.appRouter.push('/music/search');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      expect(
        tester
            .widget<ColoredBox>(
              find.byKey(const ValueKey('beta10-route-surface')).last,
            )
            .color
            .a,
        1,
      );
      await captureScreenshot(
        tester,
        'beta10-route-push-middle',
        settle: Duration.zero,
      );
      production.appRouter.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      await captureScreenshot(
        tester,
        'beta10-route-pop-middle',
        settle: Duration.zero,
      );
      await tester.pump(const Duration(milliseconds: 450));
      await pushed;
      expect(tester.takeException(), isNull);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta10 real player keeps transport through paired content transitions',
    (tester) async {
      viewport(tester);
      await prepare();
      await pump(tester, const BetaNowPlayingPage());
      final transport = tester.element(find.byType(ApplePlayerControls));
      Future<void> middle(String label) async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 90));
        expect(
          identical(
            transport,
            tester.element(find.byType(ApplePlayerControls)),
          ),
          true,
        );
        expect(tester.takeException(), isNull);
        await captureScreenshot(tester, label, settle: Duration.zero);
      }

      await tester.tap(find.bySemanticsLabel('查看歌词'));
      await middle('beta10-lyrics-enter-middle');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('返回封面'));
      await middle('beta10-lyrics-exit-middle');
      await tester.pump(const Duration(milliseconds: 400));
      // Use the production menu callback, rather than replacing the page.
      await tester.tap(find.byTooltip('更多操作'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      await captureScreenshot(
        tester,
        'beta10-more-enter-middle',
        settle: Duration.zero,
      );
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.text('黑胶唱片'));
      await middle('beta10-style-switch-middle');
      await tester.pump(const Duration(milliseconds: 450));
      for (final next in [true, false]) {
        await tester.tap(find.bySemanticsLabel(next ? '下一首' : '上一首'));
        // This UI fixture replaces metadata only; playback itself is covered
        // by deterministic audio-engine tests, without a second audio owner.
        container
            .read(_qaRecordingProvider.notifier)
            .select(
              next
                  ? Track.fromJson({
                      ..._track.toJson(),
                      'id': 'next-recording',
                      'title': '下一段旋律',
                    })
                  : _track,
            );
        await middle('beta10-song-${next ? 'next' : 'previous'}-middle');
        final transitions = tester.widgetList<PlayerContentTransition>(
          find.byType(PlayerContentTransition),
        );
        expect(transitions.every((w) => w.direction == (next ? 1 : -1)), true);
        await tester.pump(const Duration(milliseconds: 450));
      }
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta11 five categories retain results and destination navigation ends search',
    (tester) async {
      viewport(tester);
      await prepare(guest: true);
      for (final dark in [false, true]) {
        await pump(tester, const BetaCategorySearchResults(), dark: dark);
        await container
            .read(musicSearchControllerProvider.notifier)
            .submit('薛之谦');
        for (final kind in PlatformSearchKind.values) {
          await tester.tap(find.byKey(ValueKey('search-kind-${kind.name}')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 450));
          expect(find.text('搜索结果'), findsNothing);
          expect(tester.takeException(), isNull);
          await captureScreenshot(
            tester,
            'beta11-search-${kind.name}-${dark ? 'dark' : 'light'}',
          );
        }
      }
      await pump(tester, const MusicLandingPage(), shell: true);
      await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.enterText(find.byType(CupertinoTextField).last, '薛之谦');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byKey(const ValueKey('search-kind-albums')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      final bar = tester.widget<BetaMusicBottomBar>(
        find.byType(BetaMusicBottomBar),
      );
      bar.onTabSelected(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(container.read(musicSearchControllerProvider).query, '');
      expect(
        container.read(categorySearchProvider).selected,
        PlatformSearchKind.songs,
      );
      expect(container.read(categorySearchProvider).pages, isEmpty);
      await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.byType(PlatformSearchLanding), findsOneWidget);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta11 guest writes are blocked while playback remains available',
    (tester) async {
      viewport(tester);
      await prepare(guest: true);
      // Check the actual provider guard, not the fixture repository override.
      final guestRepo = LibraryRepository(
        database,
        ownerId: legacyLibraryOwnerId,
        canWrite: () => false,
      );
      await expectLater(guestRepo.toggleFavorite(_track), throwsStateError);
      await expectLater(
        guestRepo.createPlaylist(id: 'forbidden', name: 'guest'),
        throwsStateError,
      );
      expect(await guestRepo.isFavorite(_track.id), false);
      bool? allowed;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildMestingTheme(musicThemePresetById('classic')),
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => TextButton(
                  onPressed: () async => allowed = await ensureLibraryAccess(
                    context,
                    ref,
                    reason: '登录后收藏',
                    redirect: '/music',
                  ),
                  child: const Text('收藏'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('收藏'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('手机号登录'), findsOneWidget);
      Navigator.of(tester.element(find.text('手机号登录'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(allowed, false);
      guestRepo.dispose();
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta11 result offsets survive categories/details but never a new same-query session',
    (tester) async {
      viewport(tester, const Size(320, 640));
      await prepare(guest: true);
      production.appRouter.go('/music/recommend');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: production.appRouter,
            theme: buildMestingTheme(musicThemePresetById('classic')),
          ),
        ),
      );
      Future<void> settle() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }

      await settle();
      Future<void> openAlbums() async {
        await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().last);
        await settle();
        await tester.enterText(find.byType(CupertinoTextField).last, '薛之谦');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await settle();
        await tester.tap(find.byKey(const ValueKey('search-kind-albums')));
        await settle();
      }

      ScrollController activeScroll() => tester
          .widget<CustomScrollView>(
            find
                .descendant(
                  of: find.byType(BetaCategorySearchResults),
                  matching: find.byType(CustomScrollView),
                )
                .last,
          )
          .controller!;
      await openAlbums();
      activeScroll().jumpTo(50);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('search-kind-songs')));
      await settle();
      await tester.tap(find.byKey(const ValueKey('search-kind-albums')));
      await settle();
      expect(activeScroll().offset, closeTo(50, 1));
      final detail = production.appRouter.push(
        '/music/catalog/albums/0',
        extra: PlatformSearchHit(
          kind: PlatformSearchKind.albums,
          id: '0',
          title: '意外',
          cover: _track.coverAsset,
        ),
      );
      await settle();
      expect(
        find.byType(BetaCategorySearchResults).hitTestable(),
        findsNothing,
      );
      production.appRouter.pop();
      await settle();
      await detail;
      expect(
        find.byKey(const ValueKey('search-kind-albums')).hitTestable(),
        findsOneWidget,
      );
      expect(activeScroll().offset, closeTo(50, 1));
      tester
          .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
          .onTabSelected(0);
      await settle();
      await openAlbums();
      expect(activeScroll().offset, 0);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta12 embedded search advertises and consumes real system back history for every category',
    (tester) async {
      viewport(tester);
      await prepare(guest: true);
      production.appRouter.go('/music/recommend');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: production.appRouter,
            theme: buildMestingTheme(musicThemePresetById('classic')),
          ),
        ),
      );
      Future<void> settle() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }

      await settle();
      expect(production.appRouter.canPop(), false);
      await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().last);
      await settle();
      // Android needs a real Navigator target, not only a Dart dispatcher hook.
      expect(production.appRouter.canPop(), true);
      for (final kind in PlatformSearchKind.values) {
        await tester.enterText(find.byType(CupertinoTextField).last, '薛之谦');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await settle();
        await tester.tap(find.byKey(ValueKey('search-kind-${kind.name}')));
        await settle();
        expect(production.appRouter.canPop(), true);
        if (kind == PlatformSearchKind.albums) {
          expect(await production.appRouter.routerDelegate.popRoute(), true);
        } else {
          await tester.binding.handlePopRoute();
        }
        await settle();
        expect(container.read(musicSearchControllerProvider).query, isEmpty);
        expect(find.byType(PlatformSearchLanding), findsOneWidget);
        expect(production.appRouter.canPop(), true);
      }
      await tester.binding.handlePopRoute();
      await settle();
      expect(find.byType(PlatformSearchLanding), findsNothing);
      expect(production.appRouter.canPop(), false);
      expect(
        production.appRouter.routeInformationProvider.value.uri.path,
        '/music/recommend',
      );
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta12 handle drives one real route exit and a cancelled drag rebounds without popping',
    (tester) async {
      viewport(tester);
      await prepare(playing: true);
      production.appRouter.go('/music/recommend');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: production.appRouter,
            theme: buildMestingTheme(musicThemePresetById('classic')),
            builder: (context, child) => RepaintBoundary(
              key: const ValueKey('beta5-capture'),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final pushed = production.appRouter.push('/player');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final player = find.byType(BetaNowPlayingPage);
      final route = ModalRoute.of(tester.element(player))!;
      final handle = find.byKey(const ValueKey('player-dismiss-handle'));
      var drag = await tester.startGesture(tester.getCenter(handle));
      await drag.moveBy(const Offset(0, 20));
      await drag.moveBy(const Offset(0, 70));
      await tester.pump();
      expect(tester.getTopLeft(player).dy, greaterThan(40));
      await drag.cancel();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));
      expect(tester.getTopLeft(player).dy, closeTo(0, .1));
      expect(route.isCurrent, true);
      drag = await tester.startGesture(tester.getCenter(handle));
      await drag.moveBy(const Offset(0, 20));
      await drag.moveBy(const Offset(0, 260));
      await tester.pump();
      final releasedAt = tester.getTopLeft(player).dy;
      expect(releasedAt, greaterThan(200));
      await captureScreenshot(
        tester,
        'beta12-player-drag-held',
        settle: Duration.zero,
      );
      await drag.up();
      await tester.pump();
      var previous = releasedAt;
      for (var frame = 0; frame < 24; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (player.evaluate().isNotEmpty) {
          final top = tester.getTopLeft(player).dy;
          expect(top, greaterThanOrEqualTo(previous - .5));
          previous = top;
        }
        if (frame == 4) {
          await captureScreenshot(
            tester,
            'beta12-player-drag-finishing',
            settle: Duration.zero,
          );
        }
      }
      expect(player, findsNothing);
      expect(
        production.appRouter.routeInformationProvider.value.uri.path,
        '/music/recommend',
      );
      expect(production.appRouter.canPop(), false);
      await pushed;
      await captureScreenshot(
        tester,
        'beta12-player-drag-complete',
        settle: Duration.zero,
      );
      expect(tester.takeException(), null);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta12 glass background and compact matrix plus responsive startup and edit controls',
    (tester) async {
      for (final scenario in [
        (false, false, const Size(390, 844)),
        (false, true, const Size(390, 844)),
        (true, false, const Size(390, 844)),
        (true, true, const Size(390, 844)),
        (false, true, const Size(900, 740)),
      ]) {
        final (dark, detailed, size) = scenario;
        viewport(tester, size);
        await prepare(playing: true);
        final scroll = ScrollController();
        final page = ListView.builder(
          controller: scroll,
          itemExtent: 96,
          itemCount: 30,
          itemBuilder: (context, index) => detailed
              ? Container(
                  color: index.isEven
                      ? const Color(0xFF496ABD)
                      : const Color(0xFFAB5148),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      TrackArtwork(track: _track, width: 64, height: 64),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          '认真的雪\n薛之谦 · 玻璃背景测试',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.expand(),
        );
        final name =
            'beta12-glass-${dark ? "dark" : "light"}-${detailed ? "content" : "plain"}-${size.width.toInt()}';
        await pump(
          tester,
          page,
          shell: true,
          dark: dark,
          capture: '$name-expanded',
        );
        scroll.jumpTo(300);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        await captureScreenshot(tester, '$name-morph', settle: Duration.zero);
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          tester
              .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
              .inline,
          true,
        );
        await captureScreenshot(tester, '$name-compact', settle: Duration.zero);
        await disposeFixture(tester);
        scroll.dispose();
      }
      for (final dark in [false, true]) {
        viewport(tester, const Size(320, 640));
        await prepare();
        await pump(
          tester,
          const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: StartupStylePicker(),
            ),
          ),
          dark: dark,
          scale: 1.6,
          capture: 'beta12-startup-picker-${dark ? "dark" : "light"}-large',
        );
        expect(tester.takeException(), null);
        await disposeFixture(tester);
        viewport(tester);
        await prepare();
        await pump(
          tester,
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showPlaylistEditorDialog(
                  context,
                  initialName: '我的歌单',
                  initialDescription: '把喜欢的音乐留在这里',
                ),
                child: const Text('编辑'),
              ),
            ),
          ),
          dark: dark,
        );
        await tester.tap(find.text('编辑'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await captureScreenshot(
          tester,
          'beta12-playlist-edit-${dark ? "dark" : "light"}',
        );
        expect(tester.takeException(), null);
        await disposeFixture(tester);
      }
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta12 rendered comment action stays saturated blue across scrolling backdrops',
    (tester) async {
      viewport(tester);
      for (final dark in [false, true]) {
        await prepare();
        final scroll = ScrollController();
        final text = TextEditingController();
        await pump(
          tester,
          Scaffold(
            extendBody: true,
            body: ListView.builder(
              controller: scroll,
              itemExtent: 200,
              itemCount: 12,
              itemBuilder: (context, index) => index.isEven
                  ? ColoredBox(
                      color: dark ? const Color(0xFF11141B) : Colors.white,
                    )
                  : TrackArtwork(
                      track: _track,
                      width: 390,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            bottomNavigationBar: PlatformCommentComposer(
              controller: text,
              sending: false,
              keyboardVisible: false,
              onSend: () {},
            ),
          ),
          dark: dark,
        );
        for (var step = 0; step < 3; step++) {
          scroll.jumpTo(step * 280.0);
          await tester.pump(const Duration(milliseconds: 16));
          final rect = tester.getRect(
            find.byKey(const ValueKey('comment-blue-glass-send')),
          );
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('beta5-capture')),
          );
          final rgb = await tester.runAsync(() async {
            final picture = await boundary.toImage();
            final bytes = await picture.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            final offset =
                ((rect.center.dy.floor() * picture.width) +
                    rect.left.floor() +
                    12) *
                4;
            final sample = [
              bytes!.getUint8(offset),
              bytes.getUint8(offset + 1),
              bytes.getUint8(offset + 2),
            ];
            picture.dispose();
            return sample;
          });
          expect(rgb![2] - rgb[0], greaterThan(80));
          expect(rgb[2] - rgb[1], greaterThan(30));
          // ignore: avoid_print
          print('BETA12_BLUE_SAMPLE ${dark ? "dark" : "light"} $step $rgb');
          await captureScreenshot(
            tester,
            'beta12-blue-scroll-${dark ? "dark" : "light"}-$step',
            settle: Duration.zero,
          );
        }
        await disposeFixture(tester);
        scroll.dispose();
        text.dispose();
      }
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta11 playing-scroll compact rebuild benchmark',
    (tester) async {
      viewport(tester);
      await prepare(playing: true);
      await pump(tester, const MusicLandingPage(), shell: true);
      final counts = <String, int>{};
      final previous = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (element, _) {
        final name = element.widget.runtimeType.toString();
        if ([
          'BetaMusicShell',
          'BetaMusicBottomBar',
          'FloatingPlaybackPill',
          'MusicLandingPage',
        ].contains(name)) {
          counts[name] = (counts[name] ?? 0) + 1;
        }
      };
      try {
        final context = tester.element(find.byType(ListView).first);
        // Same sequence, same clocks, one notification per simulated rendered
        // frame; this measures rebuild scope, not Android GPU frame rate.
        for (var frame = 0; frame < 120; frame++) {
          ScrollUpdateNotification(
            metrics: FixedScrollMetrics(
              minScrollExtent: 0,
              maxScrollExtent: 2000,
              pixels: frame.isEven ? 300 : 0,
              viewportDimension: 700,
              axisDirection: AxisDirection.down,
              devicePixelRatio: 1,
            ),
            context: context,
            scrollDelta: frame.isEven ? 300 : -300,
          ).dispatch(context);
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pump(const Duration(milliseconds: 500));
      } finally {
        debugOnRebuildDirtyWidget = previous;
      }
      // ignore: avoid_print
      print('BETA11_COMPACT_BENCH $counts');
      expect(counts['BetaMusicShell'] ?? 0, 0);
      expect(
        tester
            .widget<BetaMusicBottomBar>(find.byType(BetaMusicBottomBar))
            .inline,
        false,
      );
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );

  testWidgets(
    'beta9 capsule uses the shared live toggle for rapid taps',
    (tester) async {
      viewport(tester);
      await prepare(playing: true);
      await pump(tester, const MusicLandingPage(), shell: true);
      final handler = container.read(audioHandlerProvider) as _Handler;
      final pause = find.bySemanticsLabel('暂停').first;
      await tester.tap(pause);
      await tester.pump(const Duration(milliseconds: 40));
      await tester.tap(pause);
      await tester.pump();
      expect(handler.toggles, 2);
      await disposeFixture(tester);
    },
    skip: !DistributionChannel.isBeta,
  );
}
