import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/social/domain/social_models.dart';
import 'package:mesting_music/features/social/presentation/social_widgets.dart';

void main() {
  test(
    'legacy cloud avatar is retained as a migration id, not an image URL',
    () {
      final user = SocialUser.fromJson(const {
        'uid': 'friend-1',
        'nickname': '好友',
        'avatar_url': 'cloud://environment/user-avatars/friend-1/avatar.jpg',
      });

      expect(user.avatarUrl, isNull);
      expect(
        user.avatarCloudId,
        'cloud://environment/user-avatars/friend-1/avatar.jpg',
      );
    },
  );

  testWidgets('social avatar uses a person fallback for a legacy cloud id', (
    tester,
  ) async {
    final user = SocialUser.fromJson(const {
      'uid': 'friend-1',
      'nickname': '好友',
      'avatar_url': 'cloud://environment/user-avatars/friend-1/avatar.jpg',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SocialAvatar(user: user)),
      ),
    );

    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.album_rounded), findsNothing);
  });

  test('public avatar URL remains displayable', () {
    final user = SocialUser.fromJson(const {
      'uid': 'friend-2',
      'nickname': '好友',
      'avatar_url': 'https://media.example.test/avatars/friend-2.jpg',
    });

    expect(user.avatarUrl, 'https://media.example.test/avatars/friend-2.jpg');
    expect(user.avatarCloudId, isNull);
  });
}
