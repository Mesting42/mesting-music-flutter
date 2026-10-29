import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/artwork_image.dart';
import '../../../../shared/widgets/beta_glass_controls.dart';
import '../../../../shared/widgets/beta_bottom_search.dart';
import '../../../../shared/widgets/beta_page_search_layout.dart';
import '../../music_platform_providers.dart';
import '../../platform_backend_providers.dart';
import '../../presentation/platform_design.dart';
import '../netease_music_repository.dart';

/// IDs remain an advanced option in task forms, but normal users can choose a
/// real song, collection or person. The picker returns an ID only; it neither
/// changes playback nor writes account data.
class NeteaseEntityPicker extends ConsumerStatefulWidget {
  const NeteaseEntityPicker({required this.kind, super.key});
  final String kind;
  @override
  ConsumerState<NeteaseEntityPicker> createState() =>
      _NeteaseEntityPickerState();
}

class _NeteaseEntityPickerState extends ConsumerState<NeteaseEntityPicker> {
  late final _bottomSearch = BetaPageSearchController(
    hintText: '搜索并选择内容',
    onSubmitted: (_) => _load(),
    onCleared: _clear,
  );
  TextEditingController get _search => _bottomSearch.text;
  void _clear() {
    _epoch++;
    if (mounted) {
      setState(() {
        _rows.clear();
        _error = null;
        _busy = false;
        _more = false;
        _page = 0;
      });
    }
  }

  final _rows = <Map<String, dynamic>>[];
  String? _owner, _token, _error;
  bool _busy = false;
  int _epoch = 0, _page = 0;
  bool _more = false;
  bool get _current =>
      ref.read(usesNeteaseProvider) &&
      ref.read(platformAccountProvider).value?.ownerId == _owner &&
      ref.read(platformAccountProvider).value?.token == _token;
  @override
  void initState() {
    super.initState();
    final account = ref.read(platformAccountProvider).value;
    _owner = account?.ownerId;
    _token = account?.token;
  }

  @override
  void dispose() {
    _epoch++;
    _bottomSearch.dispose();
    super.dispose();
  }

  Future<void> _load({bool next = false}) async {
    if (_busy || !_current || _search.text.trim().isEmpty) return;
    final epoch = ++_epoch;
    final page = next ? _page : 0;
    setState(() {
      _busy = true;
      _error = null;
      if (!next) _rows.clear();
    });
    try {
      final (type, field) = switch (widget.kind) {
        'playlist' => (1000, 'playlists'),
        'album' => (10, 'albums'),
        'artist' => (100, 'artists'),
        'user' => (1002, 'userprofiles'),
        _ => (1, 'songs'),
      };
      final payload = await ref.read(neteaseMusicRepositoryProvider).call(
        '/search',
        {'keywords': _search.text.trim(), 'type': type, 'offset': page * 30},
      );
      if (!mounted || epoch != _epoch || !_current) return;
      final result = NeteaseMusicRepository.object(payload['result']);
      final rows = NeteaseMusicRepository.rows(result[field]);
      setState(() {
        final ids = _rows.map((r) => '${r['id'] ?? r['userId']}').toSet();
        _rows.addAll(rows.where((r) => ids.add('${r['id'] ?? r['userId']}')));
        _page = page + 1;
        _more = rows.length >= 30;
      });
    } catch (_) {
      if (mounted && epoch == _epoch && _current) {
        setState(() => _error = '搜索未完成，请重试');
      }
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(platformAccountProvider);
    final label =
        const {
          'song': '歌曲',
          'playlist': '歌单',
          'album': '专辑',
          'artist': '歌手',
          'user': '用户',
        }[widget.kind] ??
        '内容';
    return BetaPageSearchLayout(
      controller: _bottomSearch,
      child: PlatformPageFrame(
        title: '选择$label',
        child: !_current
            ? const Center(child: Text('账号已变化，请返回'))
            : Column(
                children: [
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.all(14),
                      child: BetaActivityIndicator(),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_error!),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 30),
                      itemCount: _rows.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _rows.length) {
                          return _more
                              ? Padding(
                                  padding: const EdgeInsets.all(22),
                                  child: BetaGlassButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _load(next: true),
                                    child: const Text('加载更多'),
                                  ),
                                )
                              : _rows.isEmpty && !_busy
                              ? const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('输入名称，选择要操作的内容'),
                                )
                              : const SizedBox.shrink();
                        }
                        final row = _rows[index];
                        final album = NeteaseMusicRepository.object(
                          row['al'] ?? row['album'],
                        );
                        final creators = NeteaseMusicRepository.rows(
                          row['ar'] ?? row['artists'],
                        );
                        final creator = NeteaseMusicRepository.object(
                          row['creator'] ?? row['artist'],
                        );
                        final subtitle = creators.isNotEmpty
                            ? creators.map((a) => a['name']).join(' / ')
                            : '${creator['nickname'] ?? creator['name'] ?? row['signature'] ?? ''}';
                        final cover =
                            '${row['coverImgUrl'] ?? row['avatarUrl'] ?? row['picUrl'] ?? album['picUrl'] ?? ''}';
                        return ListTile(
                          leading: cover.isEmpty
                              ? const Icon(CupertinoIcons.music_note)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ArtworkImage(
                                    uri: cover,
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                          title: Text(
                            '${row['name'] ?? row['nickname'] ?? ''}',
                          ),
                          subtitle: subtitle.isEmpty ? null : Text(subtitle),
                          onTap: () => Navigator.pop(
                            context,
                            '${row['id'] ?? row['userId']}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
