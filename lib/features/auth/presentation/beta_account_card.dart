import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
import '../../music_platform/music_platform_providers.dart';
import '../../music_platform/platform_profile_provider.dart';
import '../../music_platform/presentation/platform_account_page.dart';
import '../../music_platform/presentation/platform_avatar.dart';
import '../auth_providers.dart';
import 'beta_login_navigation.dart';
import 'beta_welcome_page.dart';

/// Shared account presentation; never creates a second credential store or
/// advertises unavailable Mesting registration/social capabilities.
class BetaAccountCard extends ConsumerWidget {
  const BetaAccountCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformAccountProvider).value;
    final user = ref.watch(currentUserProvider);
    final profile = platform == null
        ? null
        : ref.watch(platformProfileProvider).value;
    final signedIn = platform != null || user != null;
    final name =
        profile?.nickname ?? platform?.nickname ?? user?.nickname ?? '';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('beta11-unified-account'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PlatformAvatar(
                url:
                    profile?.avatarUrl ??
                    platform?.avatarUrl ??
                    user?.avatarUrl ??
                    '',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signedIn
                          ? (name.isEmpty ? '当前账号' : name)
                          : '登录 Mesting Music',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      signedIn
                          ? (platform != null
                                ? '酷狗账号 · 已登录'
                                : 'Mesting 账号 · 已登录')
                          : '登录后同步喜欢的音乐与歌单',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          BetaGlassButton(
            onPressed: () {
              if (platform != null) {
                Navigator.of(
                  context,
                ).push(betaEntryRoute<void>(const PlatformAccountPage()));
              } else if (user != null) {
                // Existing Mesting sessions remain intact; their logout stays in settings.
                final router = Navigator.of(context);
                router.push(betaEntryRoute<void>(const PlatformAccountPage()));
              } else {
                openBetaLogin(context);
              }
            },
            accent: !signedIn,
            child: Text(signedIn ? '管理当前账号' : '立即登录'),
          ),
        ],
      ),
    );
  }
}
