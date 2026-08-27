import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/persistence/app_preferences.dart';
import '../../auth/auth_providers.dart';
import '../../player/presentation/music_page_transition.dart';
import '../domain/chat_message_actions.dart';
import '../domain/social_models.dart';
import 'social_widgets.dart';

/// Personal message collection backed by the signed-in user's local storage.
///
/// Saved snapshots keep their own readable copy so removing a message from a
/// conversation never makes a deliberately saved item disappear here.
class SavedMessagesPage extends ConsumerWidget {
  const SavedMessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;
    final currentUser = ref.watch(currentUserProvider);
    final messages = currentUser == null
        ? const <SavedChatMessage>[]
        : readSavedChatMessages(
            ref.watch(sharedPreferencesProvider),
            currentUser.uid,
          );
    return Column(
      children: [
        SizedBox(height: top + 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SocialPageHeader(title: '收藏消息', subtitle: '长按消息后收藏的内容会保存在这里'),
        ),
        const SizedBox(height: 17),
        Expanded(
          child: messages.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 170),
                  children: const [
                    SocialEmptyState(
                      icon: Icons.bookmark_outline_rounded,
                      title: '还没有收藏消息',
                      message: '在好友聊天中长按一条消息，选择“收藏”后就会出现在这里。',
                    ),
                  ],
                )
              : ListView.separated(
                  key: const ValueKey('saved-messages-list'),
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 170),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 9),
                  itemBuilder: (context, index) =>
                      _SavedMessageRow(message: messages[index]),
                ),
        ),
      ],
    );
  }
}

class _SavedMessageRow extends StatelessWidget {
  const _SavedMessageRow({required this.message});

  final SavedChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SocialGlass(
      radius: 18,
      child: InkWell(
        onTap: () => context.push(
          '/social/chat/${Uri.encodeComponent(message.conversationUid)}',
          extra: const MusicPageTransitionIntent.messagesConversation(),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _kindIcon(message.kind),
                  size: 22,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _messagePreview(message),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _savedMessageTime(message.sentAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _kindIcon(SocialMessageKind kind) => switch (kind) {
  SocialMessageKind.text => Icons.chat_bubble_outline_rounded,
  SocialMessageKind.emoji => Icons.sentiment_satisfied_alt_rounded,
  SocialMessageKind.image => Icons.image_outlined,
  SocialMessageKind.video => Icons.videocam_outlined,
  SocialMessageKind.voice => Icons.graphic_eq_rounded,
};

String _messagePreview(SavedChatMessage message) {
  if (message.kind == SocialMessageKind.text) {
    final quote = decodeChatMessageQuote(message.text);
    if (quote != null && quote.content.trim().isNotEmpty) {
      return quote.content;
    }
    return message.text.trim().isEmpty ? '文字消息' : message.text;
  }
  return switch (message.kind) {
    SocialMessageKind.text => '文字消息',
    SocialMessageKind.emoji => message.text,
    SocialMessageKind.image => '[图片]',
    SocialMessageKind.video => '[视频]',
    SocialMessageKind.voice => '[语音消息]',
  };
}

String _savedMessageTime(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  if (now.difference(local).inDays == 0) {
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
  return '${local.month}/${local.day}';
}
