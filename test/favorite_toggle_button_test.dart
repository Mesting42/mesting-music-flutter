import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/library/library_providers.dart';
import 'package:mesting_music/features/library/presentation/favorite_toggle_button.dart';

import 'support/test_tracks.dart';

void main() {
  Widget app({required bool favorite}) {
    final track = testTracks.first;
    return ProviderScope(
      overrides: [
        favoriteTrackIdsProvider.overrideWithValue({if (favorite) track.id}),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: FavoriteToggleButton(track: track, compact: true),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'unselected favorite button uses an outlined heart and glass base',
    (tester) async {
      final track = testTracks.first;
      await tester.pumpWidget(app(favorite: false));

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
      expect(find.bySemanticsLabel('收藏《${track.title}》'), findsOneWidget);

      final buttonFinder = find.byKey(ValueKey('favorite-button-${track.id}'));
      final container = tester.widget<AnimatedContainer>(buttonFinder);
      expect(tester.getSize(buttonFinder), const Size.square(38));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isNull);
    },
  );

  testWidgets('selected favorite button uses a filled heart and accent glow', (
    tester,
  ) async {
    final track = testTracks.first;
    await tester.pumpWidget(app(favorite: true));

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    expect(find.bySemanticsLabel('已收藏《${track.title}》'), findsOneWidget);

    final container = tester.widget<AnimatedContainer>(
      find.byKey(ValueKey('favorite-button-${track.id}')),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.gradient, isNotNull);
    expect(decoration.boxShadow, isNotEmpty);
  });
}
