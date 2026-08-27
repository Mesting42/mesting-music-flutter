import 'package:shared_preferences/shared_preferences.dart';

import 'social_models.dart';

const _quotePrefix = '「引用」';
const _quoteDivider = '\n——\n';
const _savedMessageIdsPrefix = 'social_saved_message_ids_v1_';

/// A compact, readable representation of the message being quoted.
///
/// Quotes remain understandable in clients that have not yet upgraded: the
/// encoded text starts with the human-readable `「引用」` label rather than an
/// opaque machine payload.
class ChatMessageQuote {
  const ChatMessageQuote({required this.excerpt, required this.content});

  final String excerpt;
  final String content;
}

String savedChatMessageIdsKey(String uid) =>
    '$_savedMessageIdsPrefix${uid.trim()}';

Set<String> readSavedChatMessageIds(SharedPreferences preferences, String uid) {
  if (uid.trim().isEmpty) return <String>{};
  return preferences
          .getStringList(savedChatMessageIdsKey(uid))
          ?.map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet() ??
      <String>{};
}

Future<void> writeSavedChatMessageIds(
  SharedPreferences preferences,
  String uid,
  Set<String> messageIds,
) {
  final normalizedUid = uid.trim();
  if (normalizedUid.isEmpty) return Future<void>.value();
  final values = messageIds.toList()..sort();
  return preferences.setStringList(
    savedChatMessageIdsKey(normalizedUid),
    values,
  );
}

String chatMessageQuoteExcerpt(SocialMessage message) {
  final source = switch (message.kind) {
    SocialMessageKind.voice => '语音消息',
    SocialMessageKind.image => '图片',
    SocialMessageKind.video => '视频',
    SocialMessageKind.emoji => message.text,
    SocialMessageKind.text => message.text,
  };
  final compact = source.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= 56) return compact.isEmpty ? '消息' : compact;
  return '${compact.substring(0, 55)}…';
}

String encodeChatMessageQuote({
  required String excerpt,
  required String content,
}) => '$_quotePrefix${excerpt.trim()}$_quoteDivider${content.trim()}';

ChatMessageQuote? decodeChatMessageQuote(String raw) {
  if (!raw.startsWith(_quotePrefix)) return null;
  final dividerIndex = raw.indexOf(_quoteDivider, _quotePrefix.length);
  if (dividerIndex < 0) return null;
  final excerpt = raw.substring(_quotePrefix.length, dividerIndex).trim();
  final content = raw.substring(dividerIndex + _quoteDivider.length).trim();
  if (excerpt.isEmpty || content.isEmpty) return null;
  return ChatMessageQuote(excerpt: excerpt, content: content);
}
