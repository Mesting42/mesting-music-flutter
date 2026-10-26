import '../../../shared/models/track.dart';
import '../domain/platform_session.dart';
import 'music_platform_api.dart';
import 'platform_playback_resolver.dart';

enum PlatformCommentKind { song, playlist }

class PlatformCommentResource {
  const PlatformCommentResource({
    required this.kind,
    required this.id,
    required this.name,
  });
  final PlatformCommentKind kind;

  /// A song mixsongid or playlist global_collection_id, never a local UUID.
  final String id;
  final String name;
  String get code => kind == PlatformCommentKind.song
      ? 'fc4be23b4e972707f36b8a828a93ba8a'
      : 'ca53b96fe5a1d9c22d71c8f522ef7c4f';
}

class PlatformComment {
  const PlatformComment({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.content,
    this.avatar = '',
    this.specialId = '',
    this.replies = 0,
  });
  final String id;
  final String userId;
  final String nickname;
  final String content;
  final String avatar;
  final String specialId;
  final int replies;

  factory PlatformComment.fromJson(
    Map<String, dynamic> row, {
    String childrenId = '',
  }) {
    final user = MusicPlatformApi.objectMap(row['user']);
    return PlatformComment(
      id: '${row['commentid'] ?? row['id'] ?? row['comment_id'] ?? ''}',
      userId:
          '${row['user_id'] ?? row['userid'] ?? row['kugouid'] ?? user['userid'] ?? user['id'] ?? ''}',
      nickname:
          '${row['user_name'] ?? row['username'] ?? row['nickname'] ?? user['name'] ?? user['nickname'] ?? '酷狗用户'}',
      avatar: PlatformSession.picture(
        row['user_pic'] ??
            row['user_img'] ??
            row['avatar'] ??
            user['avatar'] ??
            user['pic'],
      ),
      content: '${row['content'] ?? row['comment_text'] ?? ''}',
      specialId:
          '${row['special_child_id'] ?? row['special_id'] ?? row['childrenid'] ?? childrenId}',
      replies:
          int.tryParse('${row['reply_num'] ?? row['reply_count'] ?? 0}') ?? 0,
    );
  }
}

class PlatformCommentPage {
  const PlatformCommentPage(this.comments, this.hasMore);
  final List<PlatformComment> comments;
  final bool hasMore;
}

/// The repository is pinned to a real platform credential. Mesting credentials
/// are not accepted here. Remote permission checks remain authoritative; local
/// ownership checks additionally keep delete controls off other users' comments.
class PlatformCommentsRepository {
  PlatformCommentsRepository(this.api, this.identity);
  final MusicPlatformApi api;
  final PlatformSession identity;

  Future<PlatformCommentResource> songResource(Track track) async {
    if (track.source != TrackSource.kugou || !track.id.startsWith('kugou_')) {
      throw const MusicPlatformException('此歌曲不属于酷狗评论区');
    }
    final result = await api.get(
      '/audio',
      query: {'hash': track.id.substring(6)},
      expectedSession: identity,
    );
    final data = PlatformPlaybackResolver.audioData(result);
    final base = MusicPlatformApi.objectMap(data['base']);
    final audio = MusicPlatformApi.objectMap(data['audio_info']);
    final id =
        '${data['album_audio_id'] ?? data['mixsongid'] ?? data['MixSongID'] ?? base['album_audio_id'] ?? base['mixsongid'] ?? audio['album_audio_id'] ?? ''}';
    if (int.tryParse(id) == null || id == '0') {
      throw const MusicPlatformException('平台未返回歌曲评论标识，请稍后重试');
    }
    return PlatformCommentResource(
      kind: PlatformCommentKind.song,
      id: id,
      name: track.title,
    );
  }

  Future<PlatformCommentPage> load(
    PlatformCommentResource resource, {
    int page = 1,
    PlatformComment? thread,
  }) async {
    final reply = thread != null;
    if (reply && thread.specialId.isEmpty) {
      throw const MusicPlatformException('此评论缺少回复标识，请刷新评论区');
    }
    final payload = await api.get(
      reply
          ? '/comment/floor'
          : resource.kind == PlatformCommentKind.song
          ? '/comment/music'
          : '/comment/playlist',
      query: {
        'page': '$page',
        'pagesize': '30',
        if (reply) ...{
          'special_id': thread.specialId,
          'tid': thread.id,
          'resource_type': resource.kind.name,
          'code': resource.code,
        } else if (resource.kind == PlatformCommentKind.song)
          'mixsongid': resource.id
        else
          'id': resource.id,
      },
      expectedSession: identity,
    );
    final data = MusicPlatformApi.objectMap(payload['data'] ?? payload);
    final raw = data['list'] ?? data['comments'] ?? const [];
    if (raw is! List) throw const MusicPlatformException('评论数据格式异常，请重试');
    final childrenId =
        '${data['childrenid'] ?? payload['childrenid'] ?? thread?.specialId ?? ''}';
    final comments = raw
        .whereType<Map>()
        .map(
          (row) => PlatformComment.fromJson(
            MusicPlatformApi.objectMap(row),
            childrenId: childrenId,
          ),
        )
        .where((row) => row.id.isNotEmpty)
        .toList();
    final total = int.tryParse(
      '${data['total'] ?? data['count'] ?? data['comment_count'] ?? data['comments_num'] ?? ''}',
    );
    return PlatformCommentPage(
      comments,
      total == null ? raw.length == 30 : page * 30 < total,
    );
  }

  Future<void> _write(String path, Map<String, String> query) async {
    final result = await api.post(
      path,
      query: query,
      expectedSession: identity,
    );
    final code = '${result['error_code'] ?? result['err_code'] ?? '0'}';
    if ('${result['status']}' == '1' && code == '0') return;
    // Do not echo upstream text: it may contain credentials or request content.
    if (code == '20028' || code == '60045') {
      throw const MusicPlatformException('酷狗要求安全验证，请先在酷狗客户端完成验证后重试');
    }
    if (code == '20018' || code == '20017') {
      throw const MusicPlatformException('酷狗登录状态已失效，请退出后重新登录');
    }
    throw MusicPlatformException('酷狗未确认此次操作成功（错误码 $code），请刷新后核对，勿连续重复提交');
  }

  Future<void> send(
    PlatformCommentResource resource,
    String content, {
    PlatformComment? replyTo,
    PlatformComment? thread,
  }) async {
    final text = content.trim();
    if (text.isEmpty || text.length > 1000) {
      throw const MusicPlatformException('评论请输入 1 至 1000 个字符');
    }
    final root = thread ?? replyTo;
    if (root != null && root.specialId.isEmpty) {
      throw const MusicPlatformException('缺少回复标识，请刷新评论区');
    }
    await _write(
      root != null
          ? '/comment/floor/send'
          : resource.kind == PlatformCommentKind.song
          ? '/comment/music/send'
          : '/comment/playlist/send',
      {
        'content': text,
        'name': resource.name,
        if (root != null) ...{
          'special_id': root.specialId,
          'tid': root.id,
          'resource_type': resource.kind.name,
          'code': resource.code,
          if (thread != null && replyTo != null && replyTo.id != thread.id)
            'pid': replyTo.id,
        } else if (resource.kind == PlatformCommentKind.song)
          'mixsongid': resource.id
        else
          'id': resource.id,
      },
    );
  }

  Future<void> delete(
    PlatformCommentResource resource,
    PlatformComment comment, {
    PlatformComment? thread,
  }) async {
    if (comment.userId.isEmpty || comment.userId != identity.userId) {
      throw const MusicPlatformException('只能删除当前酷狗账号发布的评论');
    }
    if (comment.specialId.isEmpty) {
      throw const MusicPlatformException('缺少删除标识，请刷新评论区');
    }
    await _write('/comment/music/del', {
      'cid': comment.id,
      'special_id': comment.specialId,
      'resource_type': resource.kind.name,
      'code': resource.code,
      if (thread != null) 'tid': thread.id,
      if (resource.kind == PlatformCommentKind.song) 'mixsongid': resource.id,
    });
  }
}
