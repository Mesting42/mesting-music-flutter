import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/track.dart';
import '../data/platform_comments_repository.dart';
import '../data/music_platform_api.dart';
import '../music_platform_providers.dart';
import '../../auth/account_capabilities.dart';
import 'platform_comment_card.dart';
import 'platform_feedback.dart';
import 'platform_design.dart';
import '../../themes/music_theme_tokens.dart';

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
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          PlatformSongCommentsPage(track: track, repository: repository),
    ),
  );
}

/// Open the route immediately. Resolving old hash-only rows is visible and
/// retryable, rather than silently preventing entry with a toast.
class PlatformSongCommentsPage extends StatefulWidget {
  const PlatformSongCommentsPage({
    required this.track,
    required this.repository,
    super.key,
  });
  final Track track;
  final PlatformCommentsRepository repository;
  @override
  State<PlatformSongCommentsPage> createState() =>
      _PlatformSongCommentsPageState();
}

class _PlatformSongCommentsPageState extends State<PlatformSongCommentsPage> {
  late Future<PlatformCommentResource> _resource;
  @override
  void initState() {
    super.initState();
    _resource = widget.repository.songResource(widget.track);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<PlatformCommentResource>(
    future: _resource,
    builder: (context, snapshot) => snapshot.hasData
        ? PlatformCommentsPage(
            resource: snapshot.data!,
            repository: widget.repository,
          )
        : PlatformPageFrame(
            title: '歌曲评论',
            subtitle: widget.track.title,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: PlatformFeedbackState(
                  loading: !snapshot.hasError,
                  message: snapshot.error is MusicPlatformException
                      ? (snapshot.error as MusicPlatformException).message
                      : '评论暂时无法加载',
                  retry: snapshot.hasError
                      ? () => setState(() {
                          _resource = widget.repository.songResource(
                            widget.track,
                          );
                        })
                      : null,
                ),
              ),
            ),
          ),
  );
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
  PlatformCommentSort _sort = PlatformCommentSort.hottest;
  PlatformCommentScope _scope = PlatformCommentScope.all;
  List<PlatformComment> _singers = [];
  String _childrenId = '';
  bool _nativeHot = false;
  String? _sortNotice;
  final _scroll = ScrollController();

  bool get _current =>
      ref.read(showPlatformFeaturesProvider) &&
      ref.read(platformAccountProvider).value?.userId ==
          widget.repository.identity.userId &&
      ref.read(platformAccountProvider).value?.token ==
          widget.repository.identity.token;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.extentAfter < 300 &&
          _hasMore &&
          _error == null) {
        _load();
      }
    });
    _load(reset: true);
  }

  @override
  void dispose() {
    _generation++;
    _text.dispose();
    _scroll.dispose();
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
      final requestedSort = _sort;
      var singers = _singers;
      var childrenId = _childrenId;
      var nativeHot = _nativeHot;
      String? sortNotice;
      var result = await widget.repository.load(
        widget.resource,
        page: page,
        thread: widget.thread,
        hottestChildrenId: !reset && _nativeHot ? _childrenId : null,
      );
      if (reset) {
        singers = result.singerComments;
        childrenId = result.childrenId.isNotEmpty
            ? result.childrenId
            : result.comments.isNotEmpty
            ? result.comments.first.specialId
            : '';
        nativeHot = false;
        if (requestedSort == PlatformCommentSort.hottest &&
            widget.thread == null &&
            widget.resource.kind == PlatformCommentKind.song &&
            childrenId.isNotEmpty) {
          try {
            result = await widget.repository.load(
              widget.resource,
              hottestChildrenId: childrenId,
            );
            nativeHot = true;
          } catch (_) {
            // Keep a usable list when the optional ranking endpoint fails.
            sortNotice = '最热列表暂不可用，当前按已加载评论的赞数排序';
          }
        }
      }
      if (!mounted || generation != _generation || !_current) return;
      setState(() {
        _singers = singers;
        _childrenId = childrenId;
        _nativeHot = nativeHot;
        if (reset) _sortNotice = sortNotice;
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
    final entries =
        <String, PlatformComment>{
              if (widget.thread == null)
                for (final row in _singers) row.id: row,
              for (final row in _comments) row.id: row,
            }.values
            .where(
              (row) => switch (_scope) {
                PlatformCommentScope.all => true,
                PlatformCommentScope.singer =>
                  row.isSinger || _singers.any((singer) => singer.id == row.id),
                PlatformCommentScope.mine =>
                  row.userId == widget.repository.identity.userId,
              },
            )
            .toList();
    // Like upstream, time sorting and scope filters cover loaded pages only.
    // Song hottest uses the dedicated global ranking endpoint when available.
    entries.sort(
      (a, b) => switch (_sort) {
        PlatformCommentSort.hottest => b.likes.compareTo(a.likes),
        PlatformCommentSort.newest => (b.time ?? DateTime(1970)).compareTo(
          a.time ?? DateTime(1970),
        ),
        PlatformCommentSort.oldest => (a.time ?? DateTime(1970)).compareTo(
          b.time ?? DateTime(1970),
        ),
      },
    );
    return PlatformPageFrame(
      title: widget.thread == null ? '酷狗评论' : '评论回复',
      subtitle: widget.resource.name,
      child: !_current
          ? const Center(child: Text('账号已变化，请返回当前账号页面'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final sort in PlatformCommentSort.values)
                            ChoiceChip(
                              label: Text(switch (sort) {
                                PlatformCommentSort.hottest => '最热',
                                PlatformCommentSort.newest => '最新',
                                PlatformCommentSort.oldest => '最早',
                              }),
                              selected: _sort == sort,
                              onSelected: (_) {
                                if (_sort == sort) return;
                                setState(() => _sort = sort);
                                _load(reset: true);
                              },
                            ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final scope in PlatformCommentScope.values)
                            FilterChip(
                              label: Text(switch (scope) {
                                PlatformCommentScope.all => '全部',
                                PlatformCommentScope.singer => '歌手',
                                PlatformCommentScope.mine => '我的',
                              }),
                              selected: _scope == scope,
                              onSelected: (_) => setState(() => _scope = scope),
                            ),
                        ],
                      ),
                      Text(
                        _sortNotice ??
                            (_sort != PlatformCommentSort.hottest ||
                                    !_nativeHot ||
                                    _scope != PlatformCommentScope.all
                                ? '排序与筛选作用于已加载评论，可继续向下加载'
                                : '按平台最热评论排序'),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.musicThemeTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _load(reset: true),
                    child: ListView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                      children: [
                        if (widget.thread != null)
                          PlatformPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.thread!.nickname,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(widget.thread!.content),
                              ],
                            ),
                          ),
                        if (_loading)
                          const PlatformFeedbackState(loading: true),
                        if (_error != null)
                          PlatformFeedbackState(
                            message: _error!,
                            retry: () => _load(reset: _page == 0),
                          ),
                        if (!_loading && _error == null && entries.isEmpty)
                          PlatformFeedbackState(
                            message: _scope == PlatformCommentScope.all
                                ? '暂时没有评论，来写下你的感受'
                                : '已加载评论中暂无此类内容',
                          ),
                        for (final comment in entries)
                          PlatformCommentCard(
                            comment: comment,
                            onReply: _writing
                                ? null
                                : () => setState(() => _reply = comment),
                            onDelete:
                                !_writing &&
                                    comment.userId ==
                                        widget.repository.identity.userId
                                ? () => _delete(comment)
                                : null,
                            onThread: widget.thread == null
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => PlatformCommentsPage(
                                        resource: widget.resource,
                                        repository: widget.repository,
                                        thread: comment,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        if (_hasMore && !_loading)
                          TextButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.expand_more_rounded),
                            label: const Text('加载更多'),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: PlatformPanel(
                    padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reply != null)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '回复 ${_reply!.nickname}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                tooltip: '取消回复',
                                onPressed: () => setState(() => _reply = null),
                                icon: const Icon(Icons.close_rounded, size: 18),
                              ),
                            ],
                          ),
                        Row(
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
                                  labelText:
                                      widget.thread == null && _reply == null
                                      ? '发表酷狗评论'
                                      : '回复评论',
                                  counterText: '',
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _writing ? null : _send,
                              child: Text(_writing ? '提交中' : '发送'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
