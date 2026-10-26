import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/track.dart';
import '../data/platform_comments_repository.dart';
import '../data/music_platform_api.dart';
import '../music_platform_providers.dart';
import '../../auth/account_capabilities.dart';
import 'platform_avatar.dart';
import 'platform_feedback.dart';

Future<void> openPlatformSongComments(
  BuildContext context,
  WidgetRef ref,
  Track track,
) async {
  final session = ref.read(platformAccountProvider).value;
  if (!ref.read(showPlatformFeaturesProvider) || session == null) return;
  final repository = PlatformCommentsRepository(
    ref.read(musicPlatformApiProvider),
    session,
  );
  try {
    final resource = await repository.songResource(track);
    if (!context.mounted || !ref.read(showPlatformFeaturesProvider)) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PlatformCommentsPage(resource: resource, repository: repository),
      ),
    );
  } catch (error) {
    if (context.mounted) showPlatformFailure(context, error);
  }
}

void openPlatformPlaylistComments(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String name,
}) {
  final session = ref.read(platformAccountProvider).value;
  if (!ref.read(showPlatformFeaturesProvider) || session == null) return;
  if (id.isEmpty) {
    showPlatformFailure(context, const MusicPlatformException('平台未返回歌单评论标识'));
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PlatformCommentsPage(
        resource: PlatformCommentResource(
          kind: PlatformCommentKind.playlist,
          id: id,
          name: name,
        ),
        repository: PlatformCommentsRepository(
          ref.read(musicPlatformApiProvider),
          session,
        ),
      ),
    ),
  );
}

/// Independent opaque route so account/mini-player surfaces cannot show
/// through. No write is issued until the user presses its explicit action.
class PlatformCommentsPage extends ConsumerStatefulWidget {
  const PlatformCommentsPage({
    required this.resource,
    required this.repository,
    this.thread,
    super.key,
  });
  final PlatformCommentResource resource;
  final PlatformCommentsRepository repository;
  final PlatformComment? thread;
  @override
  ConsumerState<PlatformCommentsPage> createState() =>
      _PlatformCommentsPageState();
}

class _PlatformCommentsPageState extends ConsumerState<PlatformCommentsPage> {
  final _text = TextEditingController();
  List<PlatformComment> _comments = [];
  int _page = 0;
  int _generation = 0;
  bool _loading = false;
  bool _writing = false;
  bool _hasMore = false;
  String? _error;
  PlatformComment? _reply;

  bool get _current =>
      ref.read(showPlatformFeaturesProvider) &&
      ref.read(platformAccountProvider).value?.userId ==
          widget.repository.identity.userId &&
      ref.read(platformAccountProvider).value?.token ==
          widget.repository.identity.token;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _generation++;
    _text.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (!_current || (_loading && !reset)) return;
    final generation = ++_generation;
    final page = reset ? 1 : _page + 1;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.repository.load(
        widget.resource,
        page: page,
        thread: widget.thread,
      );
      if (!mounted || generation != _generation || !_current) return;
      setState(() {
        final merged = <String, PlatformComment>{
          for (final row in reset ? <PlatformComment>[] : _comments)
            row.id: row,
        };
        for (final row in result.comments) {
          merged[row.id] = row;
        }
        final progressed = reset || merged.length > _comments.length;
        _comments = merged.values.toList();
        _page = page;
        _hasMore = result.hasMore && progressed;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(
          () => _error = error is MusicPlatformException
              ? error.message
              : '评论暂时无法加载，请重试',
        );
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _send() async {
    if (_writing || !_current || _text.text.trim().isEmpty) return;
    setState(() => _writing = true);
    try {
      await widget.repository.send(
        widget.resource,
        _text.text,
        replyTo: _reply,
        thread: widget.thread,
      );
      if (!mounted || !_current) return;
      _text.clear();
      setState(() => _reply = null);
      await _load(reset: true);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已提交到酷狗，显示时间以平台审核为准')));
      }
    } catch (error) {
      if (mounted) showPlatformFailure(context, error);
    } finally {
      if (mounted) setState(() => _writing = false);
    }
  }

  Future<void> _delete(PlatformComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除这条酷狗评论？'),
        content: const Text('将删除你在酷狗发布的评论。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || !_current || _writing) return;
    setState(() => _writing = true);
    try {
      await widget.repository.delete(
        widget.resource,
        comment,
        thread: widget.thread,
      );
      await _load(reset: true);
    } catch (error) {
      if (mounted) showPlatformFailure(context, error);
    } finally {
      if (mounted) setState(() => _writing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(showPlatformFeaturesProvider);
    ref.watch(platformAccountProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.thread == null ? '酷狗评论 · ${widget.resource.name}' : '评论回复',
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: !_current
          ? const Center(child: Text('账号已变化，请返回当前账号页面'))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _load(reset: true),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (widget.thread != null)
                            ListTile(
                              title: Text(widget.thread!.nickname),
                              subtitle: Text(widget.thread!.content),
                            ),
                          if (_loading) const LinearProgressIndicator(),
                          if (_error != null)
                            TextButton(
                              onPressed: () => _load(reset: _page == 0),
                              child: Text(
                                '$_error\n点击重试',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (!_loading && _error == null && _comments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('暂时没有评论'),
                            ),
                          for (final comment in _comments)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      PlatformAvatar(
                                        url: comment.avatar,
                                        size: 36,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          comment.nickname,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (comment.userId ==
                                          widget.repository.identity.userId)
                                        IconButton(
                                          tooltip: '删除自己的评论',
                                          onPressed: _writing
                                              ? null
                                              : () => _delete(comment),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(comment.content),
                                  ),
                                  Wrap(
                                    spacing: 12,
                                    children: [
                                      TextButton(
                                        onPressed: _writing
                                            ? null
                                            : () => setState(
                                                () => _reply = comment,
                                              ),
                                        child: const Text('回复'),
                                      ),
                                      if (widget.thread == null)
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      PlatformCommentsPage(
                                                        resource:
                                                            widget.resource,
                                                        repository:
                                                            widget.repository,
                                                        thread: comment,
                                                      ),
                                                ),
                                              ),
                                          child: Text(
                                            '查看回复（${comment.replies}）',
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          if (_hasMore && !_loading)
                            TextButton(
                              onPressed: _load,
                              child: const Text('加载更多'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_reply != null)
                    ListTile(
                      dense: true,
                      title: Text(
                        '回复 ${_reply!.nickname}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: '取消回复',
                        onPressed: () => setState(() => _reply = null),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            maxLength: 1000,
                            minLines: 1,
                            maxLines: 4,
                            enabled: !_writing,
                            decoration: InputDecoration(
                              labelText: widget.thread == null && _reply == null
                                  ? '发表酷狗评论'
                                  : '回复评论',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _writing ? null : _send,
                          child: Text(_writing ? '提交中' : '发送'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
