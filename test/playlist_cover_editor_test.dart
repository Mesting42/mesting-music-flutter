import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/playlists/presentation/playlist_editor_dialog.dart';

void main() {
  Future<void> openEditor(
    WidgetTester tester, {
    String? initialCoverAsset,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showPlaylistEditorDialog(
                context,
                initialCoverAsset: initialCoverAsset,
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
  }

  testWidgets('playlist editor exposes gallery and automatic cover', (
    tester,
  ) async {
    await openEditor(
      tester,
      initialCoverAsset: 'assets/images/theme_gallery/shinchan-avatar-v2.png',
    );

    expect(find.text('创建歌单'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.text('自动封面'), findsOneWidget);
    expect(find.text('也可以使用歌曲封面'), findsNothing);
    expect(
      find.byKey(const ValueKey('playlist-editor-cover-stage')),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('playlist-editor-sheet')),
        matching: find.byType(FilledButton),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'playlist editor displays a persisted local cover with FileImage',
    (tester) async {
      final localCover = File(
        '${Directory.current.path}${Platform.pathSeparator}'
        'assets${Platform.pathSeparator}images${Platform.pathSeparator}'
        'theme_gallery${Platform.pathSeparator}shinchan-avatar-v2.png',
      );
      expect(localCover.existsSync(), isTrue);

      await openEditor(tester, initialCoverAsset: localCover.path);

      final fileImages = tester
          .widgetList<Image>(find.byType(Image))
          .where((image) => image.image is FileImage);
      expect(fileImages, isNotEmpty);
    },
  );

  testWidgets('playlist editor saves through the custom action bar', (
    tester,
  ) async {
    PlaylistDraft? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showPlaylistEditorDialog(context);
              },
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    final nameField = find.descendant(
      of: find.byKey(const ValueKey('playlist-editor-name-field')),
      matching: find.byType(TextField),
    );
    await tester.enterText(nameField, '夜行电台');
    await tester.pump();
    expect(find.text('4/30'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('playlist-editor-save')));
    await tester.pumpAndSettle();

    expect(result?.name, '夜行电台');
    expect(find.byKey(const ValueKey('playlist-editor-sheet')), findsNothing);
  });

  testWidgets('playlist editor text sits in one clean aligned surface', (
    tester,
  ) async {
    await openEditor(tester);

    final nameField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('playlist-editor-name-field')),
        matching: find.byType(TextField),
      ),
    );
    final descriptionField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('playlist-editor-description-field')),
        matching: find.byType(TextField),
      ),
    );

    for (final field in [nameField, descriptionField]) {
      expect(field.decoration?.filled, isFalse);
      expect(field.decoration?.border, InputBorder.none);
      expect(field.decoration?.enabledBorder, InputBorder.none);
      expect(field.decoration?.focusedBorder, InputBorder.none);
      expect(field.decoration?.contentPadding?.horizontal, 0);
    }
    expect(nameField.textAlignVertical, TextAlignVertical.center);
    expect(descriptionField.textAlignVertical, TextAlignVertical.top);
    expect(
      descriptionField.decoration?.contentPadding,
      const EdgeInsets.only(top: 6, bottom: 4),
    );
    expect(descriptionField.decoration?.hintMaxLines, 2);
  });

  testWidgets('playlist editor fits a narrow dark screen without overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showPlaylistEditorDialog(
                context,
                initialName: '通勤',
                initialDescription: '让清晨慢慢醒来',
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.text('编辑歌单'), findsOneWidget);
    expect(find.text('保存修改'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
