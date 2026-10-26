import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../data/music_platform_api.dart';
import '../music_platform_providers.dart';

/// Uses Mesting's inherited theme, with account state owned entirely outside
/// CloudBase. Closing this route cancels scans without affecting either login.
class PlatformAccountPage extends ConsumerStatefulWidget {
  const PlatformAccountPage({super.key});

  @override
  ConsumerState<PlatformAccountPage> createState() =>
      _PlatformAccountPageState();
}

class _PlatformAccountPageState extends ConsumerState<PlatformAccountPage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  PlatformLoginMethod _method = PlatformLoginMethod.phone;
  PlatformQrChallenge? _challenge;
  String? _message;
  bool _busy = false;
  int _generation = 0;
  int _countdown = 0;
  Timer? _countdownTimer;

  PlatformLoginService get _login =>
      PlatformLoginService(ref.read(musicPlatformApiProvider));

  @override
  void dispose() {
    ++_generation;
    _countdownTimer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _select(PlatformLoginMethod method) async {
    final generation = ++_generation;
    setState(() {
      _method = method;
      _challenge = null;
      _message = null;
      _busy = method != PlatformLoginMethod.phone;
    });
    if (method == PlatformLoginMethod.phone) return;
    try {
      await ref.read(platformAccountProvider.future);
      final challenge = await _login.createQr(method);
      if (!mounted || generation != _generation) return;
      setState(() {
        _challenge = challenge;
        _busy = false;
        _message = '请使用${_label(method)}完成扫码并确认';
      });
      unawaited(_poll(challenge, generation));
    } on Object catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _busy = false;
          _message = _error(error);
        });
      }
    }
  }

  Future<void> _poll(PlatformQrChallenge challenge, int generation) async {
    // Sequential bounded polling prevents overlapping requests; every await
    // is followed by a generation guard before a credential can be persisted.
    final expires = DateTime.now().add(const Duration(minutes: 3));
    while (mounted &&
        generation == _generation &&
        DateTime.now().isBefore(expires)) {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted || generation != _generation) return;
      try {
        final result = await _login.poll(challenge);
        if (!mounted || generation != _generation) return;
        if (result != null) {
          await ref.read(platformAccountProvider.notifier).accept(result);
          if (!mounted || generation != _generation) return;
          Navigator.of(context).pop(true);
          return;
        }
      } on Object catch (error) {
        if (mounted && generation == _generation) {
          setState(() => _message = _error(error));
        }
        return;
      }
    }
    if (mounted && generation == _generation) {
      setState(() => _message = '二维码已过期，请刷新');
    }
  }

  Future<void> _sendCode() async {
    if (!RegExp(r'^1\d{10}$').hasMatch(_phone.text.trim())) {
      setState(() => _message = '请输入正确的 11 位手机号');
      return;
    }
    final generation = _generation;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref.read(platformAccountProvider.future);
      await _login.sendCode(_phone.text.trim());
      if (!mounted || generation != _generation) return;
      setState(() {
        _countdown = 60;
        _message = '验证码已发送';
      });
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _countdown <= 1) {
          timer.cancel();
          if (mounted) setState(() => _countdown = 0);
        } else {
          setState(() => --_countdown);
        }
      });
    } on Object catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _message = _error(error));
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  Future<void> _phoneLogin() async {
    final phone = _phone.text.trim();
    final code = _code.text.trim();
    if (!RegExp(r'^1\d{10}$').hasMatch(phone) ||
        !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _message = '请填写正确的手机号和 6 位验证码');
      return;
    }
    final generation = _generation;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref.read(platformAccountProvider.future);
      var result = await _login.phoneLogin(phone, code);
      if (!mounted || generation != _generation) return;
      var data = MusicPlatformApi.objectMap(result['data']);
      if ('${result['error_code']}' == '34175') {
        final rows = data['info_list'];
        if (rows is! List || rows.isEmpty) {
          throw const MusicPlatformException('此手机号的账号列表暂时不可用');
        }
        final selected = await showLiquidGlassBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const ListTile(title: Text('选择音乐平台账号')),
                for (final row in rows.whereType<Map>())
                  ListTile(
                    title: Text(
                      '${row['nickname'] ?? row['userid'] ?? '酷狗账号'}',
                    ),
                    onTap: () =>
                        Navigator.pop(context, '${row['userid'] ?? ''}'),
                  ),
              ],
            ),
          ),
        );
        if (!mounted ||
            generation != _generation ||
            selected == null ||
            selected.isEmpty) {
          return;
        }
        result = await _login.phoneLogin(phone, code, userId: selected);
        data = MusicPlatformApi.objectMap(result['data']);
      }
      if (!mounted || generation != _generation) return;
      if ('${result['status']}' != '1') {
        throw const MusicPlatformException('登录未成功，请核对验证码或稍后重试');
      }
      await ref.read(platformAccountProvider.notifier).accept(data);
      if (mounted && generation == _generation) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _message = _error(error));
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  String _error(Object error) =>
      error is MusicPlatformException ? error.message : '音乐平台暂时不可用，请重试或返回先体验';

  String _label(PlatformLoginMethod method) => switch (method) {
    PlatformLoginMethod.phone => '手机验证码',
    PlatformLoginMethod.kugouQr => '酷狗扫码',
    PlatformLoginMethod.wechatQr => '微信扫码',
    PlatformLoginMethod.qqQr => 'QQ 扫码',
  };

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(platformAccountProvider);
    final session = account.value;
    return Scaffold(
      appBar: AppBar(title: const Text('音乐平台账号')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('酷狗音乐', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '与 Mesting 账号分别登录。Mesting 云服务暂不可用时，你仍可使用音乐平台功能。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (account.isLoading)
                  const LinearProgressIndicator()
                else if (session != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.account_circle_outlined),
                    title: Text(
                      session.nickname.isEmpty ? '酷狗账号' : session.nickname,
                    ),
                    subtitle: Text('ID：${session.userId}'),
                  ),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            try {
                              await ref
                                  .read(platformAccountProvider.notifier)
                                  .signOut();
                            } on Object {
                              if (mounted) {
                                setState(() => _message = '退出未完成，请重试');
                              }
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    child: const Text('退出音乐平台账号'),
                  ),
                ] else ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final method in PlatformLoginMethod.values)
                        ChoiceChip(
                          label: Text(_label(method)),
                          selected: _method == method,
                          onSelected: _busy ? null : (_) => _select(method),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_method == PlatformLoginMethod.phone) ...[
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      enabled: !_busy,
                      maxLength: 11,
                      autofillHints: const [
                        AutofillHints.telephoneNumberNational,
                      ],
                      decoration: const InputDecoration(labelText: '酷狗账号手机号'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      enabled: !_busy,
                      maxLength: 6,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      decoration: const InputDecoration(labelText: '验证码'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _busy || _countdown > 0 ? null : _sendCode,
                      child: Text(
                        _countdown > 0 ? '${_countdown}s 后重试' : '获取验证码',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _busy ? null : _phoneLogin,
                      child: const Text('登录音乐平台'),
                    ),
                  ] else ...[
                    if (_challenge != null)
                      Center(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(12),
                          child: Image.memory(
                            base64Decode(_challenge!.imageBase64),
                            width: 220,
                            height: 220,
                            semanticLabel: '${_label(_method)}登录二维码',
                            errorBuilder: (_, error, stack) =>
                                const Text('二维码无法显示，请刷新'),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _select(_method),
                      icon: const Icon(Icons.refresh),
                      label: const Text('刷新二维码'),
                    ),
                    if (_method == PlatformLoginMethod.qqQr)
                      const Text('QQ 扫码可能受平台风控影响，失败时可选择其他方式。'),
                  ],
                ],
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(liveRegion: true, child: Text(_message!)),
                  ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'Mesting 音乐 Beta',
                  ),
                  child: const Text('开源许可与致谢'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
