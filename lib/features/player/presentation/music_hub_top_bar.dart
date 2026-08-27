import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/artwork_image.dart';
import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../../auth/auth_providers.dart';
import '../../legal/presentation/disclaimer_dialog.dart';
import '../../social/social_providers.dart';
import '../../social/social_attention.dart';
import '../../themes/mesting_palette.dart';
import '../../themes/music_theme_tokens.dart';
import 'music_page_transition.dart';

class MusicHubTopBar extends StatelessWidget {
  const MusicHubTopBar({
    required this.title,
    required this.subtitle,
    this.showBack = false,
    this.onBack,
    this.animateTitle = false,
    this.titleKey,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final bool animateTitle;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    return Row(
      children: [
        _TopAction(
          tooltip: showBack ? '返回' : '个人中心与设置',
          icon: showBack
              ? Icons.arrow_back_ios_new_rounded
              : Icons.menu_rounded,
          onTap: showBack
              ? onBack ?? Navigator.of(context).maybePop
              : () => showMusicHubPanel(context),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBarTitle(
                title: title,
                titleKey: titleKey,
                animate: animateTitle,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        _TopAction(
          tooltip: '搜索音乐',
          icon: Icons.search_rounded,
          onTap: () => context.push(
            '/music/search',
            extra: const MusicPageTransitionIntent.forward(),
          ),
        ),
      ],
    );
  }
}

class _TopBarTitle extends StatelessWidget {
  const _TopBarTitle({
    required this.title,
    required this.titleKey,
    required this.animate,
  });

  final String title;
  final Key? titleKey;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title,
      key: titleKey,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: context.musicThemeTokens.textPrimary,
        fontSize: 20,
        height: 1.12,
        fontWeight: FontWeight.w900,
      ),
    );
    if (!animate) return text;
    return ClipRect(
      child: AnimatedSwitcher(
        key: const ValueKey('music-hub-title-switcher'),
        duration: const Duration(milliseconds: 360),
        switchInCurve: Curves.easeOutCubic,
        layoutBuilder: (current, previous) =>
            current ?? const SizedBox.shrink(),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, .18),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: text,
      ),
    );
  }
}

class _TopAction extends StatefulWidget {
  const _TopAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_TopAction> createState() => _TopActionState();
}

class _TopActionState extends State<_TopAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Keep the top actions coupled to the live page background. An opaque
    // purple-black base is conspicuous on the classic pure-black theme and
    // also fights illustrated themes, while this neutral translucent layer
    // retains the glass boundary without introducing a blur pass.
    final surface = dark
        ? Colors.white.withValues(alpha: .07)
        : Colors.black.withValues(alpha: .035);
    final pressedSurface = dark
        ? Colors.white.withValues(alpha: .045)
        : Colors.black.withValues(alpha: .06);
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? .95 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: RepaintBoundary(
              child: AnimatedContainer(
                key: ValueKey('textured-solid-${widget.tooltip}'),
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutCubic,
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _pressed ? pressedSurface : surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: dark
                        ? Colors.white.withValues(alpha: .14)
                        : Colors.black.withValues(alpha: .09),
                    width: .9,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: _pressed
                            ? (dark ? .08 : .035)
                            : (dark ? .18 : .08),
                      ),
                      blurRadius: _pressed ? 3 : 8,
                      offset: Offset(0, _pressed ? 1 : 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(widget.icon, color: tokens.textPrimary, size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showMusicHubPanel(BuildContext pageContext) {
  return showGeneralDialog<void>(
    context: pageContext,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: '关闭个人中心',
    barrierColor: const Color(0x730D0B12),
    transitionDuration: const Duration(milliseconds: 310),
    pageBuilder: (dialogContext, animation, secondaryAnimation) => Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: .86,
        child: _MusicHubPanel(pageContext: pageContext),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class _MusicHubPanel extends ConsumerStatefulWidget {
  const _MusicHubPanel({required this.pageContext});

  final BuildContext pageContext;

  @override
  ConsumerState<_MusicHubPanel> createState() => _MusicHubPanelState();
}

class _MusicHubPanelState extends ConsumerState<_MusicHubPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(authControllerProvider).value?.user == null) {
        return;
      }
      ref.invalidate(socialSummaryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final auth = ref.watch(authControllerProvider);
    final user = auth.value?.user;
    final unreadCount = user == null
        ? 0
        : ref.watch(socialAttentionControllerProvider).unreadCount;
    final size = MediaQuery.sizeOf(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 360, minHeight: size.height),
      child: LiquidGlassSurface(
        key: liquidGlassSidePanelSurfaceKey,
        blurSigma: 0,
        showShadow: false,
        showDecorativeGlow: false,
        surfaceColorBuilder: (surfaceContext) =>
            surfaceContext.musicThemeTokens.glassStrong.withValues(alpha: 1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            right: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MESTING SPACE',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '关闭',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _AccountCard(
                    nickname: user?.nickname ?? '登录后收藏你的音乐',
                    caption: user?.bio.trim().isNotEmpty == true
                        ? user!.bio
                        : user == null
                        ? '同步收藏、歌单和个人资料'
                        : '欢迎回到你的音乐空间',
                    avatarUrl: user?.avatarUrl,
                    signedIn: user != null,
                  ),
                ),
                const SizedBox(height: 26),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PanelLabel('好友与消息'),
                        _PanelSection(
                          children: [
                            _PanelTile(
                              key: const ValueKey('music-hub-my-messages'),
                              icon: Icons.mail_outline_rounded,
                              title: '我的消息',
                              subtitle: '互相关注好友的私信与会话',
                              unreadCount: unreadCount,
                              onTap: () => _openMessages(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _PanelLabel('应用设置'),
                        _PanelSection(
                          children: [
                            _PanelTile(
                              icon: Icons.tune_rounded,
                              title: '设置',
                              subtitle: '主题、账号、安全与云端',
                              highlighted: true,
                              onTap: () => _openSettings(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _PanelLabel('关于应用'),
                        _PanelSection(
                          children: [
                            _PanelTile(
                              key: const ValueKey('music-hub-legal-documents'),
                              icon: Icons.policy_outlined,
                              title: '用户协议与隐私政策',
                              subtitle: '服务规则、数据处理与个人权利',
                              onTap: () => _openLegalDocuments(context),
                            ),
                            _PanelTile(
                              icon: Icons.policy_outlined,
                              title: '免责声明',
                              subtitle: '在线音乐、版权与账号数据说明',
                              onTap: () =>
                                  showDisclaimerDialog(widget.pageContext),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '主题、账号绑定与登录安全已统一放在“设置”，收藏和歌单仍在“我的”页面。',
                            style: TextStyle(
                              color: tokens.textMuted,
                              fontSize: 10,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext panelContext) {
    Navigator.of(panelContext).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageContext.mounted) {
        widget.pageContext.push(
          '/music/settings',
          extra: const MusicPageTransitionIntent.forward(),
        );
      }
    });
  }

  void _openLegalDocuments(BuildContext panelContext) {
    Navigator.of(panelContext).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageContext.mounted) {
        widget.pageContext.push(
          '/legal',
          extra: const MusicPageTransitionIntent.forward(),
        );
      }
    });
  }

  Future<void> _openMessages(BuildContext panelContext) async {
    final panelRoute = ModalRoute.of(panelContext);
    Navigator.of(panelContext).pop();
    await panelRoute?.completed;
    // Let the drawer's removed overlay commit for one frame before starting the
    // messages-route transition. Without this boundary, some Android
    // compositors can briefly retain the drawer and the incoming page in the
    // same frame.
    await WidgetsBinding.instance.endOfFrame;
    if (!widget.pageContext.mounted) return;
    widget.pageContext.push(
      '/social/messages',
      extra: const MusicPageTransitionIntent.forward(),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.nickname,
    required this.caption,
    required this.avatarUrl,
    required this.signedIn,
  });

  final String nickname;
  final String caption;
  final String? avatarUrl;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final accent = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: .18), tokens.glassSubtle],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.borderStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            ClipOval(
              child: avatarUrl?.isNotEmpty == true
                  ? ArtworkImage(
                      uri: avatarUrl!,
                      width: 52,
                      height: 52,
                      retryOnNetworkError: true,
                    )
                  : Container(
                      width: 52,
                      height: 52,
                      color: accent.withValues(alpha: .17),
                      child: Icon(
                        signedIn
                            ? Icons.person_rounded
                            : Icons.music_note_rounded,
                        color: accent,
                        size: 25,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.musicThemeTokens.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

class _PanelSection extends StatelessWidget {
  const _PanelSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.glassSubtle,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.border),
      ),
      child: Column(children: children),
    );
  }
}

class _PanelTile extends StatelessWidget {
  const _PanelTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
    this.unreadCount = 0,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.musicThemeTokens;
    final accent = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: highlighted
                    ? accent.withValues(alpha: .16)
                    : tokens.glass,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: highlighted ? accent : tokens.textSecondary,
                size: 19,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: highlighted ? accent : tokens.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: tokens.textMuted, fontSize: 9),
                  ),
                ],
              ),
            ),
            if (unreadCount > 0)
              _UnreadMessagesBadge(count: unreadCount)
            else
              Icon(
                Icons.chevron_right_rounded,
                color: tokens.textMuted,
                size: 19,
              ),
          ],
        ),
      ),
    );
  }
}

class _UnreadMessagesBadge extends StatelessWidget {
  const _UnreadMessagesBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Semantics(
      label: '$count 条未读消息',
      child: Container(
        key: const ValueKey('music-hub-unread-badge'),
        constraints: const BoxConstraints(minWidth: 24, minHeight: 22),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: MestingPalette.heart,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x36CC3F56),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}
