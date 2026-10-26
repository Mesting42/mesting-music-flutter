import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../library/library_providers.dart';
import '../../player/presentation/music_hub_top_bar.dart';
import '../../themes/theme_gallery_page.dart';
import '../music_platform_providers.dart';
import 'platform_account_page.dart';
import 'platform_library_page.dart';
import '../platform_profile_provider.dart';
import 'platform_avatar.dart';

/// Shared current-account entry for profile and settings. It never offers a
/// second login while the platform credential is active.
class PlatformAccountTile extends ConsumerWidget {
  const PlatformAccountTile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(platformAccountProvider).value;
    final profile = ref.watch(platformProfileProvider).value;
    return ListTile(
      leading: PlatformAvatar(
        url: profile?.avatarUrl ?? session?.avatarUrl ?? '',
      ),
      title: Text(
        (profile?.nickname ?? session?.nickname ?? '').isNotEmpty
            ? (profile?.nickname ?? session!.nickname)
            : '酷狗账号',
      ),
      subtitle: const Text('已登录酷狗 · 账号管理与退出'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PlatformAccountPage()),
      ),
    );
  }
}

class PlatformProfile extends ConsumerWidget {
  const PlatformProfile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: EdgeInsets.fromLTRB(
      16,
      MediaQuery.paddingOf(context).top + 12,
      16,
      140,
    ),
    children: [
      const MusicHubTopBar(title: '我的', subtitle: '酷狗概念版'),
      const SizedBox(height: 20),
      const PlatformAccountTile(),
      const SizedBox(height: 24),
      ListTile(
        leading: const Icon(Icons.favorite_outline),
        title: const Text('我的喜欢'),
        subtitle: const Text('酷狗云端收藏'),
        onTap: () => context.push('/music?view=favorites'),
      ),
      ListTile(
        leading: const Icon(Icons.queue_music),
        title: const Text('我的歌单'),
        subtitle: Text(
          '${ref.watch(playlistsProvider).value?.length ?? 0} 个酷狗云端歌单',
        ),
        onTap: () => context.push('/music?view=playlists'),
      ),
      ListTile(
        leading: const Icon(Icons.add),
        title: const Text('新建云端歌单'),
        onTap: () => createPlatformPlaylist(context, ref),
      ),
      ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: const Text('装扮'),
        onTap: () => showDressUpCenterSheet(context),
      ),
      ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: const Text('设置'),
        onTap: () => context.push('/music/settings'),
      ),
    ],
  );
}
