import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/themes/mesting_backstage_theme.dart';

void main() {
  testWidgets('后台主题保留应用当前的明暗模式', (tester) async {
    for (final brightness in Brightness.values) {
      late ThemeData backstageTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          home: Builder(
            builder: (context) {
              backstageTheme = MestingBackstage.themeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(backstageTheme.brightness, brightness);
      expect(
        backstageTheme.extension<MestingBackstageColors>()?.brightness,
        brightness,
      );
    }
  });

  test('浅色后台使用暖白底和深色文字', () {
    final colors = MestingBackstage.forBrightness(Brightness.light);

    expect(colors.ink.computeLuminance(), greaterThan(0.75));
    expect(colors.bone.computeLuminance(), lessThan(0.1));
    expect(colors.dark, isFalse);
  });
}
