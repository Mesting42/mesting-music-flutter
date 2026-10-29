import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
import '../../../shared/widgets/beta_page_motion.dart';
import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../../auth/presentation/beta_account_card.dart';
import '../../downloads/audio_downloads_page.dart';
import '../../experience/presentation/editorial_widgets.dart';
import '../../library/library_providers.dart';
import '../data/cloud_library_repository.dart';
import '../music_platform_providers.dart';
import '../platform_backend_providers.dart';
import '../platform_profile_provider.dart';
import '../netease/netease_library_repository.dart';
import '../netease/netease_features_page.dart';
import '../netease/netease_membership_page.dart';
import '../netease/full/netease_full_page.dart';
import 'platform_account_page.dart';
import 'platform_avatar.dart';
import 'platform_design.dart';
import 'platform_feedback.dart';
import 'platform_library_page.dart';
import 'platform_login_options_page.dart';
import 'platform_profile_edit_page.dart';
import 'platform_reward_calendar.dart';
import '../../../shared/widgets/music_notice.dart';

/// Personal library composition is independent of the account card used by
/// Settings. Only real library/profile data is shown; reference statistics are
/// never copied from the supplied screenshot.
class BetaPersonalProfile extends ConsumerStatefulWidget {
  const BetaPersonalProfile({super.key});
  @override
  ConsumerState<BetaPersonalProfile> createState() =>
      _BetaPersonalProfileState();
}

class _BetaPersonalProfileState extends ConsumerState<BetaPersonalProfile> {
  bool _signing = false;
  void _open(Widget page) =>
      Navigator.of(context).push(betaContentRoute<void>(page));
  Future<void> _sign() async {
    if (!ref.read(usesNeteaseProvider)) {
      _open(const PlatformRewardCalendar());
      return;
    }
    if (_signing) return;
    setState(() => _signing = true);
    try {
      final owner = ref.read(platformAccountProvider).value?.ownerId;
      final message = await ref.read(neteaseFeaturesProvider).signIn();
      if (mounted &&
          ref.read(platformAccountProvider).value?.ownerId == owner) {
        showMusicNotice(
          context,
          icon: CupertinoIcons.check_mark_circled,
          title: message,
          message: '',
        );
      }
    } catch (e) {
      if (mounted) showPlatformFailure(context, e);
    } finally {
      if (mounted) setState(() => _signing = false);
    }
  }

  Future<void> _account() async {
    final action = await showLiquidGlassBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in [
              ('edit', '编辑个人资料', CupertinoIcons.person_crop_circle),
              ('switch', '切换音乐平台', CupertinoIcons.arrow_2_circlepath),
              (
                'account',
                '管理当前账号',
                CupertinoIcons.person_crop_circle_badge_checkmark,
              ),
            ])
              ListTile(
                leading: Icon(entry.$3),
                title: Text(entry.$2),
                onTap: () => Navigator.pop(sheet, entry.$1),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'edit') _open(const PlatformProfileEditPage());
    if (action == 'switch') _open(const MusicPlatformSwitchPage());
    if (action == 'account') {
      final session = ref.read(platformAccountProvider).value;
      if (session != null) {
        _open(PlatformAccountPage(platform: session.platform));
      }
    }
  }

  Widget _quick(
    String title,
    IconData icon,
    VoidCallback? action, {
    bool loading = false,
  }) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: BetaGlassButton(
        onPressed: action,
        loading: loading,
        height: 62,
        horizontalPadding: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(platformAccountProvider).value;
    final profile = ref.watch(platformProfileProvider).value;
    final playlists = ref.watch(playlistsProvider);
    final favorites = ref.watch(favoriteTracksProvider).value ?? const [];
    final repository = ref.watch(libraryRepositoryProvider);
    final lists = playlists.value ?? const <UserPlaylist>[];
    final liked = repository is NeteaseLibraryRepository
        ? repository.likedPlaylistId
        : null;
    final owned = lists
        .where(
          (p) =>
              p.id != liked &&
              (repository is! CloudLibraryRepository ||
                  repository.canManage(p.id)),
        )
        .toList();
    final saved = lists
        .where(
          (p) =>
              p.id != liked &&
              repository is CloudLibraryRepository &&
              !repository.canManage(p.id),
        )
        .toList();
    final scheme = Theme.of(context).colorScheme;
    Widget group(String title, List<UserPlaylist> items) => SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: EditorialSection('$title · ${items.length}')),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Text(
                '还没有$title',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 7,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ArtworkImage(
                  uri: item.coverAsset ?? '',
                  width: 64,
                  height: 64,
                  retryOnNetworkError: true,
                  persistentNetworkCacheKey:
                      'playlist-cover:${session?.ownerId}:${item.id}',
                ),
              ),
              title: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(title == '创建的歌单' ? '我的歌单' : '收藏的歌单'),
              trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
              onTap: () => context.push(
                '/music/playlists/${Uri.encodeComponent(item.id)}',
              ),
            );
          },
        ),
      ],
    );
    return PlatformStyle(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 14,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 18, 12),
                    child: Row(
                      children: [
                        Text(
                          '我的',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (session != null)
                          BetaGlassButton(
                            label: '账号选项',
                            width: 48,
                            height: 48,
                            onPressed: _account,
                            child: const Icon(CupertinoIcons.ellipsis),
                          ),
                        const SizedBox(width: 12),
                        BetaGlassButton(
                          label: '设置',
                          width: 48,
                          height: 48,
                          onPressed: () => context.push('/music/settings'),
                          child: const Icon(CupertinoIcons.gear_alt),
                        ),
                      ],
                    ),
                  ),
                  if (session == null)
                    const Padding(
                      padding: EdgeInsets.all(22),
                      child: BetaAccountCard(),
                    )
                  else ...[
                    GestureDetector(
                      onTap: () => _open(const PlatformProfileEditPage()),
                      child: Semantics(
                        button: true,
                        label: '编辑个人资料',
                        child: PlatformAvatar(
                          url: profile?.avatarUrl ?? session.avatarUrl,
                          size: 104,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        profile?.nickname ?? session.nickname,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const NeteaseLocalSvipBadge(),
                    const SizedBox(height: 9),
                    Text(
                      '${session.platformLabel}账号',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (profile?.signature?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 10, 32, 0),
                        child: Text(
                          profile!.signature!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      '${favorites.length} 首喜欢  ·  ${lists.length} 个歌单',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        _quick(
                          '最近',
                          CupertinoIcons.clock,
                          () => context.push('/music/library?view=recent'),
                        ),
                        _quick(
                          '已下载',
                          CupertinoIcons.arrow_down_circle,
                          () =>
                              openAudioDownloads(context, downloadedOnly: true),
                        ),
                        _quick(
                          '签到',
                          CupertinoIcons.calendar,
                          session == null || _signing ? null : _sign,
                          loading: _signing,
                        ),
                        _quick(
                          '会员',
                          CupertinoIcons.star_circle,
                          session == null
                              ? null
                              : () => _open(
                                  ref.read(usesNeteaseProvider)
                                      ? const NeteaseMembershipPage()
                                      : const PlatformRewardCalendar(),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  EditorialSection(
                    '我的音乐',
                    actionLabel: '新建歌单',
                    onTap: session == null
                        ? null
                        : () => createPlatformPlaylist(context, ref),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox.square(
                        dimension: 64,
                        child: favorites.isNotEmpty
                            ? ArtworkImage(
                                uri: favorites.first.coverAsset,
                                retryOnNetworkError: true,
                              )
                            : ColoredBox(
                                color: scheme.surfaceContainerLow,
                                child: Icon(
                                  CupertinoIcons.heart_fill,
                                  color: scheme.primary,
                                ),
                              ),
                      ),
                    ),
                    title: const Text(
                      '我喜欢的音乐',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${favorites.length} 首歌曲'),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                    ),
                    onTap: () => context.push('/music?view=favorites'),
                  ),
                ],
              ),
            ),
          ),
          if (playlists.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: BetaActivityIndicator(),
              ),
            ),
          if (playlists.hasError)
            SliverToBoxAdapter(
              child: EditorialEmpty(
                '歌单暂时无法加载',
                onRetry: () => ref.invalidate(playlistsProvider),
              ),
            ),
          group('创建的歌单', owned),
          group('收藏的歌单', saved),
          if (ref.watch(usesNeteaseProvider))
            const SliverToBoxAdapter(child: NeteaseFullNavigation(tab: '我的')),
          const SliverToBoxAdapter(
            child: SizedBox(height: editorialBottomClearance),
          ),
        ],
      ),
    );
  }
}
