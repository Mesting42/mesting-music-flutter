// THESIS: A coral music duo welcomes users into their chosen account or guest.
// OWN-WORLD: Existing Mesting type, coral accent, premium navigation glass.
// STORY: Meet the companions, choose a real login, then explore eight pages.
// FIRST VIEWPORT: Art and brand above; phone, WeChat and auxiliary actions below.
// FORM: User-specified native reference composition; no random seed or AI comp.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
// finish review, the verdict, and DESIGN.md.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/app_preferences.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
import '../../../shared/widgets/music_notice.dart';
import '../../../shared/widgets/beta_page_motion.dart';
import '../../../shared/widgets/beta_edge_back.dart';
import '../../legal/presentation/disclaimer_dialog.dart';
import '../../legal/presentation/legal_documents_page.dart';
import '../../legal/domain/legal_documents.dart';
import '../../music_platform/music_platform_providers.dart';
import '../../music_platform/presentation/platform_account_page.dart';
import '../beta_account_choice.dart';
import '../beta_entry_flow.dart';
import 'mesting_music_companions.dart';
import 'beta_consent_row.dart';

/// Every entry/form uses a painted page with reversible spatial movement.
Route<T> betaEntryRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 340),
  reverseTransitionDuration: const Duration(milliseconds: 260),
  pageBuilder: (_, _, _) => BetaEdgeBack(child: page),
  // Move the opaque page surface together with its body in both directions.
  // A transparent Scaffold would expose the previous login during the push.
  transitionsBuilder: (context, animation, secondary, child) =>
      BetaPageMotion(animation: animation, child: child),
);

class BetaWelcomePage extends ConsumerStatefulWidget {
  const BetaWelcomePage({this.onExperience, super.key});
  final VoidCallback? onExperience;
  @override
  ConsumerState<BetaWelcomePage> createState() => _BetaWelcomePageState();
}

class _BetaWelcomePageState extends ConsumerState<BetaWelcomePage> {
  late bool _accepted = hasAcceptedLegalDocuments(
    ref.read(sharedPreferencesProvider),
  );
  bool _opening = false;
  Future<bool> _consent() async {
    if (!_accepted) {
      showMusicNotice(
        context,
        icon: Icons.info_outline,
        title: '请先阅读并同意协议与隐私政策',
        message: '',
      );
      return false;
    }
    await saveLegalDocumentConsent(ref.read(sharedPreferencesProvider));
    return mounted;
  }

  Future<void> _platform(PlatformLoginMethod method) async {
    if (_opening || !await _consent() || !mounted) return;
    setState(() => _opening = true);
    final result = await Navigator.of(
      context,
    ).push<bool>(betaEntryRoute(PlatformAccountPage(initialMethod: method)));
    if (!mounted) return;
    setState(() => _opening = false);
    if (result == true) widget.onExperience?.call();
  }

  Future<void> _other() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '其他登录方式',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              for (final item in [
                ('kugou', '酷狗扫码登录'),
                ('qq', 'QQ 扫码登录'),
                ('mesting', 'Mesting 账号登录 / 注册 · 暂不可用'),
              ]) ...[
                BetaGlassButton(
                  onPressed: item.$1 == 'mesting'
                      ? null
                      : () => Navigator.pop(sheet, item.$1),
                  child: Text(item.$2),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'kugou':
        await _platform(PlatformLoginMethod.kugouQr);
      case 'qq':
        await _platform(PlatformLoginMethod.qqQr);
    }
  }

  Future<void> _guest() async {
    await ref
        .read(betaAccountChoiceProvider.notifier)
        .select(BetaAccountChoice.guest);
    await ref.read(betaEntryFlowProvider.notifier).finish();
    if (mounted) widget.onExperience?.call();
  }

  void _legal(LegalDocumentType type) => Navigator.of(
    context,
  ).push(betaEntryRoute(Scaffold(body: LegalDocumentPage(documentType: type))));
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: const ValueKey('beta10-welcome-page'),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [
                    Color(0xFF291B20),
                    Color(0xFF111216),
                    Color(0xFF181316),
                  ]
                : const [
                    Color(0xFFFFE6DE),
                    Color(0xFFFFF6EE),
                    Color(0xFFFFFDFB),
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, bounds) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (bounds.maxHeight - 40).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 2),
                          MestingMusicCompanions(
                            height: (bounds.maxHeight * .32).clamp(180, 260),
                          ),
                          const Text(
                            'Mesting Music',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '让喜欢的音乐，陪你多一会儿。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: .7),
                            ),
                          ),
                          const Spacer(flex: 3),
                          const SizedBox(height: 38),
                          BetaGlassButton(
                            key: const ValueKey('welcome-phone-login'),
                            accent: true,
                            onPressed: _opening
                                ? null
                                : () => _platform(PlatformLoginMethod.phone),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.smartphone_rounded, size: 23),
                                SizedBox(width: 9),
                                Text('手机号登录'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          BetaGlassButton(
                            key: const ValueKey('welcome-wechat-login'),
                            onPressed: _opening
                                ? null
                                : () => _platform(PlatformLoginMethod.wechatQr),
                            child: const Text('微信扫码登录'),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: BetaGlassButton(
                                  height: 46,
                                  onPressed: _opening ? null : _guest,
                                  child: const Text('游客体验'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BetaGlassButton(
                                  height: 46,
                                  onPressed: _opening ? null : _other,
                                  child: const Text('其他登录方式'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          BetaConsentRow(
                            accepted: _accepted,
                            onChanged: (value) =>
                                setState(() => _accepted = value),
                            onAgreement: () =>
                                _legal(LegalDocumentType.userAgreement),
                            onPrivacy: () =>
                                _legal(LegalDocumentType.privacyPolicy),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
