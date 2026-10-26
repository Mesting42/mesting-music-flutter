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

/// Owns entry presentation above the router, so a session publication cannot
/// unmount the login before its success HUD and tour have finished. Credentials
/// remain in their existing controllers; restoration never emits login events.
class BetaEntryCoordinator extends ConsumerStatefulWidget {
  const BetaEntryCoordinator({required this.child, this.onLogout, super.key});
  final Widget child;
  final VoidCallback? onLogout;
  @override
  ConsumerState<BetaEntryCoordinator> createState() =>
      _BetaEntryCoordinatorState();
}

class _BetaEntryCoordinatorState extends ConsumerState<BetaEntryCoordinator> {
  final _navigator = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    ref.listen(betaEntryFlowProvider, (previous, next) {
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
    final first = stage == BetaEntryStage.idle && !completed && !restored;
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
    } else if (stage == BetaEntryStage.success) {
      overlay = BetaLoginSuccess(
        key: const ValueKey('entry-success'),
        onComplete: () => ref.read(betaEntryFlowProvider.notifier).showGuide(),
      );
    } else if (stage == BetaEntryStage.guide) {
      overlay = BetaOnboardingPage(
        key: const ValueKey('entry-guide'),
        onFinish: () => ref.read(betaEntryFlowProvider.notifier).finish(),
      );
    }
    final active =
        stage == BetaEntryStage.welcome ||
        first ||
        stage == BetaEntryStage.success ||
        stage == BetaEntryStage.guide;
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              reverseDuration: const Duration(milliseconds: 240),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: active
                  ? ColoredBox(
                      key: ValueKey(
                        stage == BetaEntryStage.idle ? 'first' : stage.name,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: overlay,
                    )
                  : overlay,
            ),
          ),
        ),
      ],
    );
  }
}
