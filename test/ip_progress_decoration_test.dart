import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/player/presentation/ip_progress_decoration.dart';
import 'package:mesting_music/features/themes/music_theme_preset.dart';

void main() {
  test('every IP progress rail has an independent accent', () {
    final colors = MusicThemeIp.values.map(progressTrackColorForIp).toSet();

    expect(colors, hasLength(MusicThemeIp.values.length));
  });

  test('progress companions stay inside the available rail width', () {
    expect(
      progressCompanionLeft(
        progress: 0,
        availableWidth: 320,
        companionWidth: 68,
      ),
      0,
    );
    expect(
      progressCompanionLeft(
        progress: 1,
        availableWidth: 320,
        companionWidth: 68,
      ),
      252,
    );
    expect(
      progressCompanionLeft(
        progress: .5,
        availableWidth: 320,
        companionWidth: 68,
      ),
      126,
    );
  });

  test('head-only IP companions stay compact with a larger leading dot', () {
    expect(progressCompanionSize(MusicThemeIp.helloKitty), const Size(50, 42));
    expect(progressCompanionSize(MusicThemeIp.kuromi), const Size(48, 44));
    expect(ipProgressLeadingDotDiameter, greaterThan(ipProgressTrackHeight));
  });

  testWidgets('head-only IP companions use anchored badges instead of rides', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Row(
            children: [
              IpProgressCompanion(ip: MusicThemeIp.helloKitty, playing: true),
              IpProgressCompanion(ip: MusicThemeIp.kuromi, playing: true),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ip-progress-companion-helloKitty')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ip-progress-companion-kuromi')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hello-kitty-progress-character')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('kuromi-progress-character')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hello-kitty-progress-ribbon-medallion')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('kuromi-progress-mischief-crest')),
      findsOneWidget,
    );
    final kittyDot = find.byKey(
      const ValueKey('ip-progress-leading-dot-helloKitty'),
    );
    final kuromiDot = find.byKey(
      const ValueKey('ip-progress-leading-dot-kuromi'),
    );
    expect(kittyDot, findsOneWidget);
    expect(kuromiDot, findsOneWidget);
    expect(
      tester.getSize(kittyDot),
      const Size.square(ipProgressLeadingDotDiameter),
    );
    expect(
      tester.getSize(kuromiDot),
      const Size.square(ipProgressLeadingDotDiameter),
    );

    for (final dot in [kittyDot, kuromiDot]) {
      final stack = tester.widget<Stack>(
        find.ancestor(of: dot, matching: find.byType(Stack)).first,
      );
      expect(stack.children.last.key, tester.widget<Positioned>(dot).key);
    }

    final kittyImage = tester.widget<Image>(
      find.byKey(const ValueKey('hello-kitty-progress-character')),
    );
    final kuromiImage = tester.widget<Image>(
      find.byKey(const ValueKey('kuromi-progress-character')),
    );
    expect(kittyImage.fit, BoxFit.contain);
    expect(kuromiImage.fit, BoxFit.contain);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('hello-kitty-progress-character')),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('kuromi-progress-character')),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('themed progress rails paint at empty, partial and full values', (
    tester,
  ) async {
    for (final ip in [
      MusicThemeIp.shinchan,
      MusicThemeIp.helloKitty,
      MusicThemeIp.kuromi,
    ]) {
      for (final value in [0.0, .5, 1.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: ipProgressTrackHeight,
                      trackShape: IpProgressTrackShape(ip: ip),
                      activeTrackColor: progressTrackColorForIp(ip),
                      inactiveTrackColor: Colors.white24,
                      thumbShape: SliderComponentShape.noThumb,
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(value: value, onChanged: (_) {}),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$ip at $value');
      }
    }
  });
}
