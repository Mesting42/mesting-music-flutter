import 'package:flutter_test/flutter_test.dart';
import 'package:mesting_music/features/social/domain/chat_message_actions.dart';
import 'package:mesting_music/features/social/domain/social_models.dart';

void main() {
  test('quoted messages keep a readable fallback and decode safely', () {
    final encoded = encodeChatMessageQuote(excerpt: '原始消息', content: '这是我的回复');

    expect(encoded, '「引用」原始消息\n——\n这是我的回复');
    expect(
      decodeChatMessageQuote(encoded),
      isA<ChatMessageQuote>()
          .having((quote) => quote.excerpt, 'excerpt', '原始消息')
          .having((quote) => quote.content, 'content', '这是我的回复'),
    );
    expect(decodeChatMessageQuote('普通文字'), isNull);
  });

  test('quoted voice uses a concise semantic excerpt', () {
    final voice = SocialMessage(
      id: 'voice',
      senderUid: 'friend',
      receiverUid: 'me',
      kind: SocialMessageKind.voice,
      text: '3200',
      sentAt: DateTime(2026, 8, 27),
    );

    expect(chatMessageQuoteExcerpt(voice), '语音消息');
    expect(savedChatMessageIdsKey(' me '), 'social_saved_message_ids_v1_me');
  });
}
