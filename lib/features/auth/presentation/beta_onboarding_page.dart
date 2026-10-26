import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
import '../../themes/theme_controller.dart';
import '../../music_platform/music_platform_providers.dart';
import 'mesting_music_companions.dart';
import 'beta_player_style_previews.dart';
import '../../../shared/widgets/player_comment_glyph.dart';

/// Content is deliberately grounded in the Beta's current capabilities.
/// Demonstrations never write to cloud accounts or start a second player.
const betaGuidePages = <({String title, String body, List<String> tags})>[
  (
    title: '发现你的音乐',
    body: '在发现页听每日推荐、新歌与精选内容。轻点搜索，找到你此刻想听的歌。',
    tags: ['每日推荐', '搜索发现', '新歌速递'],
  ),
  (
    title: '播放与歌词',
    body: '轻点小播放条展开播放器。点击封面查看歌词，再轻点上方封面返回，音乐始终连贯。',
    tags: ['完整播放器', '同步歌词', '双向切换'],
  ),
  (
    title: '顺手的播放器操作',
    body: '从顶部灰条下拉收起。底部可打开评论、音质与队列；更多菜单里切换播放模式与外观。',
    tags: ['灰条下拉', '音质选择', '评论与队列'],
  ),
  (
    title: '私人 FM 与收藏',
    body: '在发现页探索私人 FM。轻点爱心收藏喜欢的音乐，云端收藏与歌单跟随当前账号。',
    tags: ['发现推荐', '爱心收藏', '账号歌单'],
  ),
  (
    title: '让音乐接着播放',
    body: '单击只播放所选歌曲，播放全部才加入整组。手动待播优先，耗尽后推荐续播；上一首返回真实历史。',
    tags: ['手动优先', '推荐续播', '真实历史'],
  ),
  (
    title: '调成你的样子',
    body: '浅色、深色或跟随系统，由你选择。装扮里还可设置自定义背景和进度条样式。',
    tags: ['外观模式', '自定义背景', '进度条'],
  ),
  (
    title: '五种播放器风格',
    body: '选一个喜欢的舞台，音乐照常继续。这里的选择会保存，也可随时从装扮或播放器更多菜单更换。',
    tags: [],
  ),
  (title: '开始你的音乐之旅', body: '喜欢的音乐与熟悉的操作，都已准备好。以后也能在设置中的“使用指南”重新查看。', tags: []),
];

class BetaOnboardingPage extends ConsumerStatefulWidget {
  const BetaOnboardingPage({required this.onFinish, super.key});
  final VoidCallback onFinish;
  @override
  ConsumerState<BetaOnboardingPage> createState() => _BetaOnboardingPageState();
}

class _BetaOnboardingPageState extends ConsumerState<BetaOnboardingPage> {
  final _pager = PageController();
  int _index = 0;
  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _page(int index) => _pager.animateToPage(
    index,
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 380),
    curve: Curves.easeInOutCubic,
  );
  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_index > 0) {
            _page(_index - 1);
          } else {
            widget.onFinish();
          }
        }
      },
      child: Scaffold(
        key: const ValueKey('beta10-onboarding'),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [Color(0xFF22181D), Color(0xFF101114)]
                  : const [Color(0xFFFFF0E9), Color(0xFFFFFDFB)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Mesting Music',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFDE5757),
                              ),
                            ),
                          ),
                          BetaGlassButton(
                            height: 42,
                            onPressed: widget.onFinish,
                            child: const Text('跳过'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pager,
                        itemCount: betaGuidePages.length,
                        onPageChanged: (value) =>
                            setState(() => _index = value),
                        itemBuilder: (_, index) => TickerMode(
                          enabled: index == _index,
                          child: _GuideContent(index: index),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 8; i++)
                            Semantics(
                              label: '第 ${i + 1} 页，共 8 页',
                              selected: i == _index,
                              child: GestureDetector(
                                onTap: () => _page(i),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 240),
                                    width: i == _index ? 26 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(9),
                                      color: i == _index
                                          ? const Color(0xFFDE5757)
                                          : ink.withValues(alpha: .22),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          if (_index > 0) ...[
                            BetaGlassButton(
                              width: 52,
                              height: 52,
                              label: '上一页',
                              onPressed: () => _page(_index - 1),
                              child: const Icon(CupertinoIcons.chevron_back),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: BetaGlassButton(
                              accent: true,
                              key: const ValueKey('guide-next'),
                              onPressed: () => _index == 7
                                  ? widget.onFinish()
                                  : _page(_index + 1),
                              child: Text(_index == 7 ? '开始使用' : '下一步'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideContent extends ConsumerWidget {
  const _GuideContent({required this.index});
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = betaGuidePages[index];
    final platform = ref.watch(platformAccountProvider).value;
    final body = index == 3 && platform == null
        ? '在发现页探索推荐，轻点爱心收藏。收藏与歌单按当前账号管理，登录酷狗后可使用对应的云端歌单与私人 FM。'
        : page.body;
    return LayoutBuilder(
      builder: (context, bounds) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 14),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (bounds.maxHeight - 22).clamp(0, double.infinity),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (index == 7)
                const MestingMusicCompanions(height: 225)
              else if (index == 6)
                const SizedBox(
                  width: double.infinity,
                  child: BetaPlayerStylePreviews(),
                )
              else
                GuideAnimatedScene(index: index),
              const SizedBox(height: 26),
              Text(
                index == 3 && platform == null ? '推荐与收藏' : page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .8),
                ),
              ),
              const SizedBox(height: 24),
              if (index == 5)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final mode in [
                      ('classic', '浅色'),
                      ('classic-dark', '深色'),
                      ('classic-system', '跟随系统'),
                    ])
                      ChoiceChip(
                        label: Text(mode.$2),
                        selected: ref.watch(musicThemeProvider).id == mode.$1,
                        onSelected: (_) => ref
                            .read(musicThemeProvider.notifier)
                            .select(mode.$1),
                      ),
                  ],
                )
              else if (index == 6)
                const SizedBox.shrink()
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final tag in page.tags)
                      Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        side: BorderSide.none,
                        backgroundColor: const Color(
                          0xFFDE5757,
                        ).withValues(alpha: .12),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Each page owns one bounded, interactive scene. It pauses through TickerMode
/// when PageView keeps an adjacent page alive; no global frame notifications.
class GuideAnimatedScene extends StatefulWidget {
  const GuideAnimatedScene({required this.index, super.key});
  final int index;
  @override
  State<GuideAnimatedScene> createState() => _GuideAnimatedSceneState();
}

class _GuideAnimatedSceneState extends State<GuideAnimatedScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();
  bool _alternate = false;
  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '轻点体验${betaGuidePages[widget.index].title}',
    child: GestureDetector(
      onTap: () => setState(() => _alternate = !_alternate),
      child: RepaintBoundary(
        child: SizedBox(
          height: 224,
          width: 320,
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, _) => CustomPaint(
              painter: _GuidePainter(
                widget.index,
                MediaQuery.disableAnimationsOf(context) ? .2 : _motion.value,
                _alternate,
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _GuidePainter extends CustomPainter {
  _GuidePainter(this.index, this.time, this.alternate, this.ink);
  final int index;
  final double time;
  final bool alternate;
  final Color ink;
  static const accent = Color(0xFFDE5757);
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.translate(s.width / 2, s.height / 2);
    final wave = math.sin(time * math.pi * 2);
    final pen = Paint()..isAntiAlias = true;
    void icon(IconData data, Offset p, double size, Color color) {
      final t = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(data.codePoint),
          style: TextStyle(
            fontFamily: data.fontFamily,
            package: data.fontPackage,
            fontSize: size,
            color: color,
          ),
        ),
      )..layout();
      t.paint(c, p - Offset(t.width / 2, t.height / 2));
    }

    void panel(Rect r, Color color) => c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(18)),
      pen
        ..color = color
        ..style = PaintingStyle.fill,
    );
    if (index == 0 || index == 3) {
      for (var i = 0; i < 3; i++) {
        c.drawCircle(
          Offset.zero,
          67 + i * 17,
          pen
            ..color = accent.withValues(alpha: .13 + i * .04)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
      c.drawCircle(
        Offset.zero,
        52,
        pen
          ..color = accent.withValues(alpha: .22)
          ..style = PaintingStyle.fill,
      );
      icon(
        index == 0
            ? CupertinoIcons.compass_fill
            : CupertinoIcons.antenna_radiowaves_left_right,
        Offset.zero,
        46,
        accent,
      );
      for (var i = 0; i < 4; i++) {
        final a = time * math.pi * 2 + i * math.pi / 2;
        icon(
          index == 3
              ? (alternate ? CupertinoIcons.heart_fill : CupertinoIcons.heart)
              : CupertinoIcons.music_note,
          Offset(math.cos(a) * 91, math.sin(a) * 91),
          alternate ? 25 : 20,
          i.isEven ? accent : ink.withValues(alpha: .65),
        );
      }
    } else if (index == 1) {
      final expanded = alternate ? 1.0 : (wave + 1) / 2;
      panel(
        Rect.fromCenter(
          center: Offset(0, -expanded * 19),
          width: 222,
          height: 68 + expanded * 121,
        ),
        ink.withValues(alpha: .08),
      );
      panel(
        Rect.fromLTWH(-91, -21 - expanded * 57, 48, 48),
        accent.withValues(alpha: .3),
      );
      icon(
        CupertinoIcons.music_note,
        Offset(-67, 3 - expanded * 57),
        25,
        accent,
      );
      for (var i = 0; i < 3; i++) {
        panel(
          Rect.fromLTWH(-25, -12 + i * 15 + expanded * 5, 95 - i * 12, 5),
          i == (time * 3).floor() % 3 ? accent : ink.withValues(alpha: .2),
        );
      }
      icon(
        alternate ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
        Offset(75, 1 + expanded * 56),
        23,
        ink,
      );
    } else if (index == 2) {
      c.save();
      c.translate(0, alternate ? 12 : (wave + 1) * 4);
      panel(
        const Rect.fromLTWH(-97, -91, 194, 181),
        ink.withValues(alpha: .07),
      );
      panel(const Rect.fromLTWH(-26, -81, 52, 4), ink.withValues(alpha: .38));
      panel(
        const Rect.fromLTWH(-68, -59, 136, 66),
        accent.withValues(alpha: .22),
      );
      icon(CupertinoIcons.music_note, const Offset(0, -27), 30, accent);
      panel(const Rect.fromLTWH(-68, 20, 136, 4), ink.withValues(alpha: .16));
      panel(Rect.fromLTWH(-68, 20, 60 + wave * 12, 4), accent);
      paintPlayerCommentGlyph(c, const Rect.fromLTWH(-65, 47, 25, 25), accent);
      icon(CupertinoIcons.hifispeaker_fill, const Offset(0, 60), 24, ink);
      icon(CupertinoIcons.list_bullet, const Offset(53, 60), 25, ink);
      if (alternate) {
        panel(const Rect.fromLTWH(27, -68, 90, 91), ink.withValues(alpha: .9));
        for (var i = 0; i < 3; i++) {
          panel(Rect.fromLTWH(41, -48 + i * 23, 60 - i * 9, 4), Colors.white70);
        }
      }
      c.restore();
      icon(
        CupertinoIcons.hand_point_left_fill,
        Offset(14, -81 + (wave + 1) * 20),
        26,
        accent,
      );
    } else if (index == 4) {
      for (var i = 0; i < 3; i++) {
        final selected = ((time * 3).floor() + (alternate ? 1 : 0)) % 3 == i;
        final y = -72.0 + i * 61 + (alternate && index == 4 ? -6 : 0);
        panel(Rect.fromLTWH(-119, y, 238, 52), ink.withValues(alpha: .07));
        if (index == 2 && i == 2) {
          paintPlayerCommentGlyph(
            c,
            Rect.fromCenter(center: Offset(-87, y + 26), width: 25, height: 25),
            accent,
          );
        } else {
          icon(
            index == 4
                ? CupertinoIcons.music_note
                : [
                    CupertinoIcons.chevron_down,
                    CupertinoIcons.hifispeaker_fill,
                    CupertinoIcons.text_quote,
                  ][i],
            Offset(-87, y + 26),
            24,
            selected ? accent : ink.withValues(alpha: .5),
          );
        }
        panel(
          Rect.fromLTWH(-55, y + 17, selected ? 116 : 85, 6),
          selected ? accent : ink.withValues(alpha: .25),
        );
        panel(Rect.fromLTWH(-55, y + 31, 68, 4), ink.withValues(alpha: .15));
        if (selected) {
          icon(
            CupertinoIcons.hand_point_left_fill,
            Offset(103 + wave * 4, y + 39),
            25,
            accent,
          );
        }
      }
    } else {
      final background = Rect.fromCenter(
        center: Offset(0, -43),
        width: 174,
        height: 105,
      );
      panel(
        background,
        alternate ? const Color(0xFF34313C) : const Color(0xFFF2D6C9),
      );
      c.drawCircle(
        Offset(48 + wave * 4, -62),
        15,
        pen
          ..color = alternate
              ? const Color(0xFFF1DCB3)
              : const Color(0xFFDE5757),
      );
      final hills = Path()
        ..moveTo(-87, 9)
        ..quadraticBezierTo(-40, -58, 0, -9)
        ..quadraticBezierTo(44, -52, 87, 9)
        ..close();
      c.drawPath(
        hills,
        pen
          ..color = alternate
              ? const Color(0xFF705C7F)
              : const Color(0xFFCC8981),
      );
      c.translate(0, 64);
      for (var i = 0; i < 3; i++) {
        final x = (i - 1) * 91.0;
        c.drawCircle(
          Offset(x, wave * (i - 1) * 7),
          34,
          pen
            ..style = PaintingStyle.fill
            ..color = [
              const Color(0xFFFFE7DD),
              const Color(0xFF34313C),
              accent,
            ][i],
        );
        icon(
          [
            CupertinoIcons.sun_max_fill,
            CupertinoIcons.moon_fill,
            CupertinoIcons.circle_lefthalf_fill,
          ][i],
          Offset(x, wave * (i - 1) * 7),
          27,
          i == 0 ? accent : Colors.white,
        );
      }
    }
    c.restore();
  }

  @override
  bool shouldRepaint(_GuidePainter old) =>
      old.time != time ||
      old.index != index ||
      old.alternate != alternate ||
      old.ink != ink;
}
