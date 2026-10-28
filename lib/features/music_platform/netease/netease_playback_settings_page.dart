import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../platform_backend_providers.dart';
import '../presentation/platform_design.dart';
import '../presentation/platform_feedback.dart';
import '../listening_sync/listening_sync_models.dart';
import 'netease_features_page.dart';
import 'netease_features_repository.dart';
import 'netease_fallback.dart';
import 'netease_listening_reporter.dart';

class NeteasePlaybackSettingsPage extends ConsumerWidget {
  const NeteasePlaybackSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(usesNeteaseProvider)) {
      return const PlatformPageFrame(
        title: '网易云播放设置',
        child: Center(child: Text('请返回并切换到网易云账号')),
      );
    }
    final rows = ref.watch(neteaseListeningJournalProvider).value ?? const [];
    final accepted = rows
        .where((r) => r.state == ListeningSyncState.accepted)
        .length;
    final uncertain = rows
        .where(
          (r) =>
              r.state == ListeningSyncState.unknown ||
              r.state == ListeningSyncState.dispatched,
        )
        .length;
    return PlatformPageFrame(
      title: '网易云播放与同步',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 190),
        children: [
          SwitchListTile.adaptive(
            title: const Text('备用音源'),
            subtitle: const Text('原曲不可播放或仅可试听时尝试补源，严格匹配同一录音版本'),
            value: ref.watch(neteaseFallbackEnabledProvider),
            onChanged: (value) async {
              try {
                await ref
                    .read(neteaseFallbackEnabledProvider.notifier)
                    .setEnabled(value);
              } catch (e) {
                if (context.mounted) showPlatformFailure(context, e);
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '优先使用当前网易云账号原音源；备用解析使用 BugPk，其次尝试酷狗、酷我公开音源。仅发送歌曲信息，不发送账号凭据。实际音质以音源返回为准。',
            ),
          ),
          SwitchListTile.adaptive(
            title: const Text('网易云播放记录上报'),
            subtitle: const Text('仅记录真实播放时间，暂停、缓冲与拖动进度不计入'),
            value: ref.watch(neteaseListeningEnabledProvider),
            onChanged: (value) async {
              try {
                await ref
                    .read(neteaseListeningEnabledProvider.notifier)
                    .setEnabled(value);
              } catch (e) {
                if (context.mounted) showPlatformFailure(context, e);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '接口已接收 $accepted 条 · 结果未确认 $uncertain 条\n接口接收不代表网易云官方累计时长已入账。未确认的请求不会自动重复发送。',
            ),
          ),
          for (final feed in [
            NeteaseFeed.recentSongs,
            NeteaseFeed.recentPlaylists,
            NeteaseFeed.recentAlbums,
            NeteaseFeed.week,
            NeteaseFeed.allTime,
          ])
            ListTile(
              title: Text(NeteaseFeaturesRepository.titles[feed]!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openNeteaseFeed(context, feed),
            ),
        ],
      ),
    );
  }
}
