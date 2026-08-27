import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/persistence/app_preferences.dart';
import '../../auth/auth_providers.dart';
import '../domain/chat_message_actions.dart';
import '../domain/social_models.dart';
import '../domain/track_share.dart';
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

/// A saved message stays readable in its own collection view instead of
/// reopening the live conversation it originally came from.
class SavedMessageDetailPage extends ConsumerWidget {
  const SavedMessageDetailPage({required this.messageId, super.key});

  final String messageId;

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
    final message = _savedMessageWithId(messages, messageId);
    return Column(
      children: [
        SizedBox(height: top + 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SocialPageHeader(title: '收藏详情', subtitle: '已保存的独立消息快照'),
        ),
        const SizedBox(height: 17),
        Expanded(
          child: message == null
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 170),
                  children: const [
                    SocialEmptyState(
                      icon: Icons.bookmark_remove_outlined,
                      title: '收藏内容不可用',
                      message: '这条收藏可能已被移除，请返回收藏消息查看其他内容。',
                    ),
                  ],
                )
              : ListView(
                  key: const ValueKey('saved-message-detail'),
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 170),
                  children: [
                    Semantics(
                      label:
                          '收藏详情：${message.authorName}的${_savedMessageKindLabel(message.kind)}',
                      child: SocialGlass(
                        radius: 22,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 19, 20, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SavedMessageDetailMeta(message: message),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant
                                      .withValues(alpha: .42),
                                ),
                              ),
                              Text(
                                _savedMessageKindLabel(message.kind),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 11),
                              _SavedMessageDetailContent(message: message),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
        key: ValueKey('saved-message-row-${message.id}'),
        onTap: () => context.push(
          '/social/saved-messages/${Uri.encodeComponent(message.id)}',
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

class _SavedMessageDetailMeta extends StatelessWidget {
  const _SavedMessageDetailMeta({required this.message});

  final SavedChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(_kindIcon(message.kind), color: scheme.primary),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '收藏于 ${_savedMessageDateTime(message.sentAt)}',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SavedMessageDetailContent extends StatelessWidget {
  const _SavedMessageDetailContent({required this.message});

  final SavedChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (message.kind == SocialMessageKind.text) {
      final track = decodeTrackShareMessage(message.text);
      if (track != null) {
        return Container(
          key: const ValueKey('saved-message-track-preview'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      final quote = decodeChatMessageQuote(message.text);
      final content = quote?.content ?? message.text.trim();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (quote != null) ...[
            Text(
              '回复 ${quote.excerpt}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
          ],
          SelectableText(
            content.isEmpty ? '文字消息' : content,
            style: const TextStyle(fontSize: 16, height: 1.55),
          ),
        ],
      );
    }
    if (message.kind == SocialMessageKind.emoji) {
      return Text(message.text, style: const TextStyle(fontSize: 44));
    }
    if (message.kind == SocialMessageKind.voice) {
      return _SavedMessageAttachmentPreview(
        icon: Icons.graphic_eq_rounded,
        label: _savedVoiceDurationLabel(message.text),
      );
    }
    return _SavedMessageAttachmentPreview(
      icon: message.kind == SocialMessageKind.image
          ? Icons.image_outlined
          : Icons.videocam_outlined,
      label: message.kind == SocialMessageKind.image ? '已保存图片' : '已保存视频',
    );
  }
}

class _SavedMessageAttachmentPreview extends StatelessWidget {
  const _SavedMessageAttachmentPreview({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
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
    final track = decodeTrackShareMessage(message.text);
    if (track != null) return '🎵 ${track.title} · ${track.artist}';
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

SavedChatMessage? _savedMessageWithId(
  Iterable<SavedChatMessage> messages,
  String id,
) {
  for (final message in messages) {
    if (message.id == id) return message;
  }
  return null;
}

String _savedMessageKindLabel(SocialMessageKind kind) => switch (kind) {
  SocialMessageKind.text => '文字消息',
  SocialMessageKind.emoji => '表情',
  SocialMessageKind.image => '图片',
  SocialMessageKind.video => '视频',
  SocialMessageKind.voice => '语音消息',
};

String _savedMessageDateTime(DateTime value) {
  final local = value.toLocal();
  return '${local.year}/${local.month.toString().padLeft(2, '0')}/'
      '${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String _savedVoiceDurationLabel(String rawDuration) {
  final milliseconds = int.tryParse(rawDuration);
  if (milliseconds == null || milliseconds <= 0) return '语音消息';
  final totalSeconds = (milliseconds / Duration.millisecondsPerSecond)
      .ceil()
      .clamp(1, 3599);
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
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
