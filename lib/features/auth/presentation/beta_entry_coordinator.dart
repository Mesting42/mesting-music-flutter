import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/app_preferences.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
import '../../../shared/widgets/beta_success_feedback.dart';
import '../auth_providers.dart';
import '../beta_entry_flow.dart';
import '../../music_platform/music_platform_providers.dart';
import 'beta_welcome_page.dart';
import 'beta_onboarding_page.dart';
import '../../../core/audio/login_success_sound.dart';
import '../../../core/haptics/app_haptics.dart';

/// Owns entry presentation above the router, so a session publication cannot
/// unmount the login before its success HUD and tour have finished. Credentials
/// remain in their existing controllers; restoration never emits login events.
class BetaEntryCoordinator extends ConsumerStatefulWidget {
  const BetaEntryCoordinator({
    required this.child,
    this.onLogout,
    this.backDispatcher,
    super.key,
  });
  final Widget child;
  final VoidCallback? onLogout;
  final BackButtonDispatcher? backDispatcher;
  @override
  ConsumerState<BetaEntryCoordinator> createState() =>
      _BetaEntryCoordinatorState();
}

class _BetaEntryCoordinatorState extends ConsumerState<BetaEntryCoordinator> {
  final _navigator = GlobalKey<NavigatorState>();
  final _guide = GlobalKey<BetaOnboardingPageState>();
  ChildBackButtonDispatcher? _back;
  bool _guideRevealed = false;

  @override
  void initState() {
    super.initState();
    // This entry navigator lives above Router, so BackButtonListener cannot
    // discover its dispatcher. Inject a child dispatcher from the app boundary.
    _back = widget.backDispatcher?.createChildBackButtonDispatcher();
    _back?.addCallback(_handleBack);
    // MaterialApp.builder mounts this coordinator before its Router child.
    // Taking priority now asserts in debug and races router registration in
    // release. Claim it only after the owning Router has installed callbacks.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (widget.backDispatcher?.hasCallbacks ?? false)) {
        _back?.takePriority();
      }
    });
  }

  Future<bool> _handleBack() async {
    final stage = ref.read(betaEntryFlowProvider);
    if (stage == BetaEntryStage.success) return true;
    if (stage == BetaEntryStage.guide) {
      _guide.currentState?.goBack();
      return true;
    }
    final navigator = _navigator.currentState;
    if (navigator != null && navigator.canPop()) return navigator.maybePop();
    return false;
  }

  @override
  void dispose() {
    _back?.removeCallback(_handleBack);
    if (_back != null) widget.backDispatcher?.forget(_back!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(betaEntryFlowProvider, (previous, next) {
      if (next == BetaEntryStage.success && previous != next) {
        _guideRevealed = false;
        // An explicit authentication event owns the one-shot UI sound.
        // Restoration/refresh never enters this stage.
        LoginSuccessSound.play();
        appHaptic(context, AppHapticEvent.success);
      }
      if (next == BetaEntryStage.welcome && previous != next) {
        // Let the welcome surface cover the old route before its stack resets.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onLogout?.call();
        });
      }
    });
    final stage = ref.watch(betaEntryFlowProvider);
    final auth = ref.watch(authControllerProvider);
    final platform = ref.watch(platformAccountProvider);
    final completed =
        ref
            .read(sharedPreferencesProvider)
            .getBool(BetaEntryFlow.completedKey) ==
        true;
    final restored = auth.value?.user != null || platform.value != null;
    final first =
        stage == BetaEntryStage.idle &&
        !completed &&
        !restored &&
        !platform.hasError;
    Widget overlay = const SizedBox.shrink(key: ValueKey('entry-app'));
    if (stage == BetaEntryStage.welcome || first) {
      // Music login and guest entry remain available if CloudBase restoration
      // is offline. Only the platform's local credential read gates this frame.
      overlay = first && platform.isLoading
          ? const Center(
              key: ValueKey('entry-restoring'),
              child: BetaActivityIndicator(label: '正在恢复账号'),
            )
          : Navigator(
              key: _navigator,
              onGenerateRoute: (_) =>
                  betaEntryRoute<void>(const BetaWelcomePage()),
            );
    } else if (stage == BetaEntryStage.success ||
        stage == BetaEntryStage.guide) {
      // A single stable subtree owns success + guide. No outgoing/incoming
      // transparent cross-fade can expose the routed home for even one frame.
      overlay = Stack(
        fit: StackFit.expand,
        children: [
          ExcludeFocus(
            excluding: stage == BetaEntryStage.success,
            child: ExcludeSemantics(
              excluding: stage == BetaEntryStage.success,
              child: IgnorePointer(
                ignoring: stage == BetaEntryStage.success,
                // Pause the decorative guide behind the opaque success cover.
                child: TickerMode(
                  enabled: stage == BetaEntryStage.guide || _guideRevealed,
                  child: BetaOnboardingPage(
                    key: _guide,
                    onFinish: () =>
                        ref.read(betaEntryFlowProvider.notifier).finish(),
                  ),
                ),
              ),
            ),
          ),
          if (stage == BetaEntryStage.success)
            Positioned.fill(
              child: AbsorbPointer(
                child: BetaLoginSuccess(
                  key: const ValueKey('entry-success'),
                  onReveal: () {
                    if (mounted) setState(() => _guideRevealed = true);
                  },
                  onComplete: () =>
                      ref.read(betaEntryFlowProvider.notifier).showGuide(),
                ),
              ),
            ),
        ],
      );
    } else if (platform.isLoading || platform.hasError) {
      // An unreadable credential is not a guest account. Keep the music app
      // mounted, but expose an honest, retryable restoration state.
      overlay = Center(
        child: platform.isLoading
            ? const BetaActivityIndicator(label: '正在恢复账号')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('账号暂未恢复，登录信息已保留'),
                  const SizedBox(height: 16),
                  BetaGlassButton(
                    onPressed: () => ref.invalidate(platformAccountProvider),
                    child: const Text('重试恢复'),
                  ),
                  const SizedBox(height: 12),
                  BetaGlassButton(
                    onPressed: () =>
                        ref.read(betaEntryFlowProvider.notifier).welcome(),
                    child: const Text('重新登录'),
                  ),
                ],
              ),
      );
    }
    final active =
        stage == BetaEntryStage.welcome ||
        first ||
        stage == BetaEntryStage.success ||
        stage == BetaEntryStage.guide ||
        platform.isLoading ||
        platform.hasError;
    return Stack(
      fit: StackFit.expand,
      children: [
        TickerMode(
          enabled: !active,
          child: ExcludeFocus(
            excluding: active,
            child: ExcludeSemantics(
              excluding: active,
              child: IgnorePointer(ignoring: active, child: widget.child),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !active,
            child: active
                ? ColoredBox(
                    key: ValueKey(
                      stage == BetaEntryStage.success ||
                              stage == BetaEntryStage.guide
                          ? 'tour'
                          : stage == BetaEntryStage.idle
                          ? 'first'
                          : stage.name,
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    child: overlay,
                  )
                : overlay,
          ),
        ),
      ],
    );
  }
}
