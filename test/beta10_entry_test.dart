import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mesting_music/core/persistence/app_preferences.dart';
import 'package:mesting_music/core/platform/distribution_channel.dart';
import 'package:mesting_music/features/auth/auth_providers.dart';
import 'package:mesting_music/features/auth/domain/auth_models.dart';
import 'package:mesting_music/features/auth/beta_entry_flow.dart';
import 'package:mesting_music/features/auth/presentation/beta_entry_coordinator.dart';
import 'package:mesting_music/features/auth/presentation/beta_welcome_page.dart';
import 'package:mesting_music/features/auth/presentation/beta_onboarding_page.dart';
import 'package:mesting_music/features/auth/presentation/mesting_music_companions.dart';
import 'package:mesting_music/features/music_platform/music_platform_providers.dart';
import 'package:mesting_music/features/music_platform/domain/platform_session.dart';
import 'package:mesting_music/features/player/player_visual_style.dart';
import 'package:mesting_music/features/themes/app_theme.dart';
import 'package:mesting_music/features/themes/music_theme_preset.dart';
import 'package:mesting_music/shared/widgets/beta_success_feedback.dart';

class _Auth extends AuthController {
  @override
  Future<AuthSession?> build() async => null;
}

class _Platform extends PlatformAccountController {
  @override
  Future<PlatformSession?> build() async => null;
}

const _captureKey = ValueKey('beta10-capture');
void main() {
  setUpAll(() async {
    await LiquidGlassWidgets.initialize();
    if (const bool.fromEnvironment('EXPORT_BETA_SCREENSHOTS')) {
      final font = File('C:/Windows/Fonts/msyh.ttc');
      for (final family in [
        'BetaQACJK',
        'Roboto',
        'CupertinoSystemText',
        'CupertinoSystemDisplay',
      ]) {
        await (FontLoader(
          family,
        )..addFont(font.readAsBytes().then(ByteData.sublistView))).load();
      }
      await (FontLoader('MaterialIcons')..addFont(
            File(
              'D:/flutter/mesting-beta5/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
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
  Future<ProviderContainer> prepare(
    WidgetTester tester,
    Widget page, {
    Size size = const Size(390, 844),
    bool dark = false,
    double scale = 1,
    Map<String, Object> values = const {},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authControllerProvider.overrideWith(_Auth.new),
        platformAccountProvider.overrideWith(_Platform.new),
      ],
    );
    addTearDown(container.dispose);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var theme = buildMestingTheme(
      musicThemePresetById(dark ? 'classic-dark' : 'classic'),
    );
    if (const bool.fromEnvironment('EXPORT_BETA_SCREENSHOTS')) {
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'BetaQACJK'),
      );
    }
    if (const bool.fromEnvironment('EXPORT_BETA_SCREENSHOTS')) {
      theme = theme.copyWith(
        chipTheme: theme.chipTheme.copyWith(
          labelStyle: theme.chipTheme.labelStyle?.copyWith(
            fontFamily: 'BetaQACJK',
          ),
          secondaryLabelStyle: theme.chipTheme.secondaryLabelStyle?.copyWith(
            fontFamily: 'BetaQACJK',
          ),
        ),
      );
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: _captureKey,
          child: MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: page,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return container;
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('EXPORT_BETA_SCREENSHOTS')) return;
    final context = tester.element(find.byType(MaterialApp).first);
    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    await tester.runAsync(() async {
      await Future.wait(
        images.map((image) => precacheImage(image.image, context)),
      );
    });
    await tester.pump();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_captureKey),
    );
    await tester.runAsync(() async {
      // Raster export is real engine I/O, outside the widget fake clock.
      final image = await boundary.toImage(pixelRatio: 1.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File(
        '${const String.fromEnvironment('BETA10_CAPTURE_DIR')}/$name.png',
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
      'welcome has living companions, both primary entries and guest ($dark)',
      (tester) async {
        await prepare(tester, const BetaWelcomePage(), dark: dark);
        expect(find.text('手机号登录'), findsOneWidget);
        expect(find.text('微信扫码登录'), findsOneWidget);
        expect(find.text('游客体验'), findsOneWidget);
        expect(find.byType(MestingMusicCompanions), findsOneWidget);
        await capture(tester, 'welcome-${dark ? 'dark' : 'light'}');
        await tester.tap(find.text('其他登录方式'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Mesting 账号登录 / 注册'), findsOneWidget);
        expect(find.text('酷狗扫码登录'), findsOneWidget);
        expect(find.text('QQ 扫码登录'), findsOneWidget);
        await capture(tester, 'other-logins-${dark ? 'dark' : 'light'}');
        await tester.pumpWidget(const SizedBox());
      },
    );
    testWidgets(
      'eight guide pages move both ways and real player choice persists ($dark)',
      (tester) async {
        var finished = 0;
        final container = await prepare(
          tester,
          BetaOnboardingPage(onFinish: () => finished++),
          dark: dark,
        );
        for (var i = 0; i < 8; i++) {
          expect(
            find.text(betaGuidePages[i].title),
            i == 3 ? findsNothing : findsOneWidget,
          );
          await capture(tester, 'guide-${i + 1}-${dark ? 'dark' : 'light'}');
          if (i == 6) {
            await tester.tap(find.text('流光唱片'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 450));
            expect(
              container.read(playerVisualStyleProvider),
              PlayerVisualStyle.aurora,
            );
            expect(
              container
                  .read(sharedPreferencesProvider)
                  .getString(
                    DistributionChannel.isBeta
                        ? 'player_visual_style_beta5'
                        : 'player_visual_style',
                  ),
              'aurora',
            );
          }
          if (i < 7) {
            await tester.tap(find.byKey(const ValueKey('guide-next')));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 420));
          }
        }
        await tester.tap(find.bySemanticsLabel('上一页'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 420));
        expect(find.text('五种播放器风格'), findsOneWidget);
        await tester.tap(find.text('跳过'));
        expect(finished, 1);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('small large-text welcome and guide keep actions reachable', (
    tester,
  ) async {
    await prepare(
      tester,
      const BetaWelcomePage(),
      size: const Size(320, 640),
      scale: 1.6,
    );
    expect(tester.takeException(), isNull);
    await capture(tester, 'welcome-small-large-text');
    await prepare(
      tester,
      BetaOnboardingPage(onFinish: () {}),
      size: const Size(320, 640),
      scale: 1.6,
    );
    for (var i = 0; i < 8; i++) {
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byKey(const ValueKey('guide-next'))).bottom,
        lessThanOrEqualTo(640),
      );
      if (i < 7) {
        await tester.tap(find.byKey(const ValueKey('guide-next')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 420));
      }
    }
    await capture(tester, 'guide-small-large-text');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('wide welcome and success card have bounded compositions', (
    tester,
  ) async {
    await prepare(tester, const BetaWelcomePage(), size: const Size(1000, 760));
    await capture(tester, 'welcome-wide');
    expect(tester.takeException(), isNull);
    var completed = 0;
    await prepare(
      tester,
      Scaffold(body: BetaLoginSuccess(onComplete: () => completed++)),
    );
    await capture(tester, 'login-success');
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 300));
    expect(completed, 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'each fresh login shows success and guide; skip returns to app; logout resets',
    (tester) async {
      var reset = 0;
      final c = await prepare(
        tester,
        BetaEntryCoordinator(
          onLogout: () => reset++,
          child: const Scaffold(body: Text('应用主页')),
        ),
        values: {BetaEntryFlow.completedKey: true},
      );
      expect(find.text('应用主页'), findsOneWidget);
      c.read(betaEntryFlowProvider.notifier).authenticated();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BetaLoginSuccess), findsOneWidget);
      c.read(betaEntryFlowProvider.notifier).authenticated();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BetaOnboardingPage), findsOneWidget);
      await tester.tap(find.text('跳过'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(c.read(betaEntryFlowProvider), BetaEntryStage.app);
      await c.read(betaEntryFlowProvider.notifier).welcome();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(reset, 1);
      expect(find.byType(BetaWelcomePage), findsOneWidget);
      c.read(betaEntryFlowProvider.notifier).authenticated();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BetaLoginSuccess), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
