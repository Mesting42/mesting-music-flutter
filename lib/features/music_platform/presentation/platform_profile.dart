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
import 'platform_design.dart';
import '../../themes/music_theme_tokens.dart';

/// Shared current-account entry for profile and settings. It never offers a
/// second login while the platform credential is active.
class PlatformAccountTile extends ConsumerWidget {
  const PlatformAccountTile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(platformAccountProvider).value;
    final profile = ref.watch(platformProfileProvider).value;
    return PlatformPanel(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontSize: 19),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
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
      ),
    );
  }
}

class PlatformProfile extends ConsumerWidget {
  const PlatformProfile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => PlatformStyle(
    child: ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        140,
      ),
      children: [
        const MusicHubTopBar(title: '我的', subtitle: '酷狗概念版'),
        const SizedBox(height: 24),
        const PlatformAccountTile(),
        const SizedBox(height: 28),
        const PlatformSectionTitle('我的音乐', subtitle: '收藏与歌单跟随当前酷狗账号'),
        PlatformPanel(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            children: [
              _ProfileLink(
                icon: Icons.favorite_rounded,
                title: '我的喜欢',
                subtitle: '酷狗云端收藏',
                onTap: () => context.push('/music?view=favorites'),
              ),
              _ProfileLink(
                icon: Icons.library_music_rounded,
                title: '我的歌单',
                subtitle:
                    '${ref.watch(playlistsProvider).value?.length ?? 0} 个酷狗云端歌单',
                onTap: () => context.push('/music?view=playlists'),
              ),
              _ProfileLink(
                icon: Icons.add_rounded,
                title: '新建云端歌单',
                onTap: () => createPlatformPlaylist(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const PlatformSectionTitle('应用与外观'),
        PlatformPanel(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            children: [
              _ProfileLink(
                icon: Icons.palette_outlined,
                title: '装扮',
                subtitle: '皮肤与主题',
                onTap: () => showDressUpCenterSheet(context),
              ),
              _ProfileLink(
                icon: Icons.tune_rounded,
                title: '设置',
                onTap: () => context.push('/music/settings'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
