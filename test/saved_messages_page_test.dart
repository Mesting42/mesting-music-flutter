import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/core/persistence/app_preferences.dart';
import 'package:mesting_music/features/auth/auth_providers.dart';
import 'package:mesting_music/features/auth/domain/auth_models.dart';
import 'package:mesting_music/features/social/domain/chat_message_actions.dart';
import 'package:mesting_music/features/social/domain/social_models.dart';
import 'package:mesting_music/features/social/presentation/saved_messages_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('saved messages page exposes the stored message collection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    await writeSavedChatMessages(preferences, 'me', [
      SavedChatMessage(
        id: 'saved-message',
        conversationUid: 'friend',
        senderUid: 'friend',
        authorName: 'Mest',
        kind: SocialMessageKind.text,
        text: '这条消息已经被收藏',
        sentAt: DateTime(2026, 8, 27, 20, 20),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(
            const AuthUser(uid: 'me', nickname: 'Mesting'),
          ),
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: Scaffold(body: SavedMessagesPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('收藏消息'), findsOneWidget);
    expect(find.byKey(const ValueKey('saved-messages-list')), findsOneWidget);
    expect(find.text('Mest'), findsOneWidget);
    expect(find.text('这条消息已经被收藏'), findsOneWidget);
  });
}
