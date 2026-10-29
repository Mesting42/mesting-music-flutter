import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/playback_providers.dart';
import '../../../../shared/models/track.dart';
import '../../../../shared/widgets/beta_glass_controls.dart';
import '../../../experience/presentation/editorial_widgets.dart';
import '../../../player/presentation/beta_playback_actions.dart';
import '../../music_platform_providers.dart';
import '../../platform_backend_providers.dart';
import '../../presentation/platform_design.dart';
import '../netease_music_repository.dart';
import 'netease_entity_picker.dart';
import 'netease_manual_routes.dart';

/// An explicit foreground room owns heartbeats and playback reporting. Leaving
/// the page stops synchronization, without silently terminating a remote room.
/// Commands are never replayed after an uncertain response or account switch.
class NeteaseTogetherPage extends ConsumerStatefulWidget {
  const NeteaseTogetherPage({super.key});
  @override
  ConsumerState<NeteaseTogetherPage> createState() =>
      _NeteaseTogetherPageState();
}

class _NeteaseTogetherPageState extends ConsumerState<NeteaseTogetherPage>
    with WidgetsBindingObserver {
  final _invitation = TextEditingController();
  final _inviter = TextEditingController();
  late final NeteaseMusicRepository _music;
  String? _owner, _token, _room, _error, _message;
  final _members = <String>[];
  final _tracks = <Track>[];
  Timer? _timer;
  StreamSubscription<String>? _commands;
  bool _busy = false, _sync = false, _reporting = false;
  int _sequence = 1;
  bool get _current =>
      mounted &&
      ref.read(usesNeteaseProvider) &&
      ref.read(platformAccountProvider).value?.ownerId == _owner &&
      ref.read(platformAccountProvider).value?.token == _token;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final account = ref.read(platformAccountProvider).value;
    _owner = account?.ownerId;
    _token = account?.token;
    _music = ref.read(neteaseMusicRepositoryProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(_commands?.cancel());
    _invitation.dispose();
    _inviter.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _timer?.cancel();
      unawaited(_commands?.cancel());
      _commands = null;
      _sync = false;
    }
  }

  Future<Map<String, dynamic>> _call(
    String route, [
    Map<String, Object?> q = const {},
  ]) async {
    if (!_current) throw StateError('账号已变化');
    final c = neteaseCompleteContract(route, q)!;
    return _music.api.request(
      c.path,
      c.data,
      weapi: c.weapi,
      expectedCredential: _music.credential,
    );
  }

  Future<bool> _confirm(String action, String description) async =>
      await showCupertinoDialog<bool>(
        context: context,
        builder: (c) => CupertinoAlertDialog(
          title: Text(action),
          content: Text(description),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('取消'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('确认'),
            ),
          ],
        ),
      ) ==
      true;
  Future<void> _action(Future<void> Function() action) async {
    if (_busy || !_current) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      if (_current) setState(() => _error = '操作未获平台确认，请先刷新房间状态核对后再操作。');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    if (!await _confirm('创建一起听房间？', '创建后可邀请朋友，共享网易云音乐。') || !_current) return;
    await _action(() async {
      final data = NeteaseMusicRepository.object(
        (await _call('/listentogether/room/create'))['data'],
      );
      final room = NeteaseMusicRepository.object(data['roomInfo']);
      final id = '${room['roomId'] ?? data['roomId'] ?? ''}';
      if (id.isEmpty) throw StateError('未返回房间号');
      if (!_current) return;
      setState(() => _room = id);
      await _refresh();
      _startSync();
    });
  }

  Future<void> _join() async {
    final input = _invitation.text.trim();
    final uri = Uri.tryParse(input);
    final room = uri?.queryParameters['roomId'] ?? input;
    final inviter = uri?.queryParameters['inviterId'] ?? _inviter.text.trim();
    if (room.isEmpty || inviter.isEmpty) {
      setState(() => _error = '请粘贴邀请链接，或填写房间号和邀请人编号');
      return;
    }
    if (!await _confirm('加入一起听房间？', '你将加入所选房间，并可读取共享歌单。') || !_current) return;
    await _action(() async {
      await _call('/listentogether/accept', {
        'roomId': room,
        'inviterId': inviter,
      });
      if (!_current) return;
      setState(() => _room = room);
      await _refresh();
      await _loadQueue();
      _startSync();
    });
  }

  Future<void> _refresh() async {
    final response = await _call('/listentogether/status');
    final data = NeteaseMusicRepository.object(response['data']);
    var room = NeteaseMusicRepository.object(data['roomInfo']);
    if (_room != null) {
      room = {
        ...room,
        ...NeteaseMusicRepository.object(
          (await _call('/listentogether/room/check', {
            'roomId': _room,
          }))['data'],
        ),
      };
    }
    if (!_current) return;
    final users = NeteaseMusicRepository.rows(
      room['roomUsers'] ?? data['roomUsers'],
    );
    setState(() {
      _room = '${room['roomId'] ?? _room ?? ''}'.isEmpty
          ? null
          : '${room['roomId'] ?? _room}';
      _members
        ..clear()
        ..addAll(
          users.map(
            (u) =>
                '${u['nickname'] ?? NeteaseMusicRepository.object(u['user'])['nickname'] ?? '房间成员'}',
          ),
        );
      _message = data['inRoom'] == false ? '当前账号暂未加入房间' : '房间状态已刷新';
      if (data['inRoom'] == false) {
        _room = null;
        _stopSync();
      }
    });
  }

  Future<void> _loadQueue() async {
    if (_room == null) return;
    final data = NeteaseMusicRepository.object(
      (await _call('/listentogether/sync/playlist/get', {
        'roomId': _room,
      }))['data'],
    );
    final playlist = NeteaseMusicRepository.object(data['playlist']);
    final display = NeteaseMusicRepository.object(playlist['displayList']);
    final ids = (display['result'] as List? ?? const [])
        .map((v) => '$v')
        .toList();
    final tracks = <Track>[];
    for (var i = 0; i < ids.length; i += 500) {
      final result = await _music.call('/song/detail', {
        'ids': ids.sublist(i, (i + 500).clamp(0, ids.length)),
      });
      tracks.addAll(NeteaseMusicRepository.tracks(result['songs']));
    }
    if (_current) {
      setState(() {
        _tracks
          ..clear()
          ..addAll(tracks);
        _message = '共享歌单已刷新';
      });
    }
  }

  void _stopSync() {
    _timer?.cancel();
    _timer = null;
    unawaited(_commands?.cancel());
    _commands = null;
    _sync = false;
  }

  void _startSync() {
    if (!_current || _room == null) return;
    _stopSync();
    setState(() => _sync = true);
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _report(heartbeat: true),
    );
    _commands = ref.read(audioHandlerProvider).userCommandStream.listen((
      command,
    ) {
      // Scheduled by one event loop so the player's position/state has settled.
      Future<void>.delayed(Duration.zero, () {
        if (_current && _sync) _report(command: command);
      });
    });
  }

  Future<void> _report({bool heartbeat = false, String? command}) async {
    if (!_current || !_sync || _room == null || _reporting) return;
    final handler = ref.read(audioHandlerProvider);
    final track = handler.trackForId(handler.mediaItem.value?.id ?? '');
    if (track?.source != TrackSource.netease) return;
    _reporting = true;
    try {
      final playing = handler.playbackState.value.playing;
      final action = command == 'seek'
          ? 'seek'
          : command == 'pause'
          ? 'PAUSE'
          : command == 'play'
          ? 'PLAY'
          : 'GOTO';
      await _call(
        heartbeat ? '/listentogether/heatbeat' : '/listentogether/play/command',
        {
          'roomId': _room,
          'songId': track!.platformSongId,
          'progress': handler.currentPosition.inMilliseconds,
          'playStatus': playing ? 'PLAY' : 'PAUSE',
          if (!heartbeat) ...{
            'commandType': action,
            'formerSongId': '-1',
            'targetSongId': track.platformSongId,
            'clientSeq': _sequence++,
          },
        },
      );
    } catch (_) {
      if (_current) {
        _stopSync();
        setState(() => _error = '同步未获确认，已停止自动同步。刷新房间后可重新开启。');
      }
    } finally {
      _reporting = false;
    }
  }

  Future<void> _choosePlaylist() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const NeteaseEntityPicker(kind: 'playlist'),
      ),
    );
    if (id == null || !_current || _room == null) return;
    if (!await _confirm('更换房间共享歌单？', '房间成员将看到你选择的歌曲列表。') || !_current) return;
    await _action(() async {
      final tracks = await _music.playlist(id);
      if (!_current) return;
      final ids = tracks.map((t) => t.platformSongId).join(',');
      if (ids.isEmpty) throw StateError('歌单为空');
      await _call('/listentogether/sync/list/command', {
        'roomId': _room,
        'commandType': 'REPLACE',
        'userId': _music.api.session?.userId,
        'version': _sequence++,
        'randomList': ids,
        'displayList': ids,
      });
      if (_current) {
        setState(
          () => _tracks
            ..clear()
            ..addAll(tracks),
        );
      }
    });
  }

  Future<void> _end() async {
    if (!await _confirm('结束一起听？', '这会退出或结束当前网易云一起听房间。') || !_current) return;
    await _action(() async {
      await _call('/listentogether/end', {'roomId': _room});
      if (_current) {
        _stopSync();
        setState(() {
          _room = null;
          _tracks.clear();
          _members.clear();
          _message = '一起听已结束';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(platformAccountProvider);
    if (!_current) {
      _stopSync();
      return const PlatformPageFrame(
        title: '一起听',
        child: Center(child: Text('账号已变化，请返回')),
      );
    }
    return PlatformPageFrame(
      title: '一起听',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          if (_room == null) ...[
            BetaGlassButton(
              onPressed: _busy ? null : _create,
              loading: _busy,
              child: const Text('创建房间'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _invitation,
              decoration: const InputDecoration(labelText: '邀请链接或房间号'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _inviter,
              decoration: const InputDecoration(labelText: '邀请人编号（粘贴链接时可留空）'),
            ),
            const SizedBox(height: 14),
            BetaGlassButton(
              onPressed: _busy ? null : _join,
              child: const Text('加入房间'),
            ),
          ] else ...[
            Text('房间 $_room', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            BetaGlassButton(
              onPressed: () => Clipboard.setData(
                ClipboardData(
                  text:
                      Uri.https('st.music.163.com', '/listen-together/share/', {
                        'songId': _tracks.firstOrNull?.platformSongId ?? '0',
                        'roomId': _room!,
                        'inviterId': _music.api.session!.userId,
                      }).toString(),
                ),
              ),
              child: const Text('复制邀请链接'),
            ),
            for (final member in _members)
              ListTile(
                leading: const Icon(CupertinoIcons.person),
                title: Text(member),
              ),
            SwitchListTile.adaptive(
              title: const Text('同步当前播放'),
              subtitle: const Text('在此页面共享当前网易云歌曲的播放、暂停与进度。'),
              value: _sync,
              onChanged: _busy
                  ? null
                  : (value) {
                      if (value) {
                        _startSync();
                      } else {
                        setState(_stopSync);
                      }
                    },
            ),
            const Text('离开页面或切到后台会停止同步。需要退出房间时，请点“结束一起听”。'),
            const SizedBox(height: 16),
            BetaGlassButton(
              onPressed: _busy ? null : _choosePlaylist,
              child: const Text('选择共享歌单'),
            ),
            const SizedBox(height: 12),
            BetaGlassButton(
              onPressed: _busy ? null : () => _action(_loadQueue),
              child: const Text('读取共享歌单'),
            ),
            for (final track in _tracks)
              EditorialTrackRow(
                track: track,
                contextTracks: _tracks,
                onPlay: () => playBetaSelection(context, ref, track),
              ),
            const SizedBox(height: 14),
            BetaGlassButton(
              onPressed: _busy ? null : _end,
              child: const Text('结束一起听'),
            ),
          ],
          const SizedBox(height: 18),
          BetaGlassButton(
            onPressed: _busy ? null : () => _action(_refresh),
            child: const Text('刷新房间状态'),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_message!),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_error!),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
