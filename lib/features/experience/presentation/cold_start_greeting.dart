import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/app_preferences.dart';
import '../../auth/beta_entry_flow.dart';
import '../../auth/auth_providers.dart';
import '../../music_platform/music_platform_providers.dart';

/// Not auto-disposed: route changes and background/foreground must not replay
/// a cold-process greeting. A new ProviderScope on cold start gets a fresh flag.
final coldGreetingUsedProvider = NotifierProvider<_GreetingUsed, bool>(
  _GreetingUsed.new,
);

class _GreetingUsed extends Notifier<bool> {
  @override
  bool build() => false;
  void consume() => state = true;
}

class ColdStartGreeting extends ConsumerStatefulWidget {
  const ColdStartGreeting({super.key});
  @override
  ConsumerState<ColdStartGreeting> createState() => _ColdStartGreetingState();
}

class _ColdStartGreetingState extends ConsumerState<ColdStartGreeting> {
  Timer? _timer;
  bool _visible = false, _scheduled = false;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = ref.watch(betaEntryFlowProvider);
    final account = ref.watch(platformAccountProvider);
    final completed =
        ref
            .read(sharedPreferencesProvider)
            .getBool(BetaEntryFlow.completedKey) ==
        true;
    final ready =
        stage == BetaEntryStage.app ||
        stage == BetaEntryStage.idle && completed;
    if (!_scheduled &&
        ready &&
        !account.isLoading &&
        !account.hasError &&
        !ref.read(coldGreetingUsedProvider)) {
      _scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ref.read(coldGreetingUsedProvider)) return;
        ref.read(coldGreetingUsedProvider.notifier).consume();
        setState(() => _visible = true);
        _timer = Timer(const Duration(seconds: 5), () {
          if (mounted) setState(() => _visible = false);
        });
      });
    }
    final hour = DateTime.now().hour;
    final greeting = hour < 5
        ? '夜深了'
        : hour < 11
        ? '早上好'
        : hour < 14
        ? '中午好'
        : hour < 18
        ? '下午好'
        : '晚上好';
    final name =
        account.value?.nickname ??
        ref.watch(currentUserProvider)?.nickname ??
        '';
    final blue = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF9EC8FF)
        : const Color(0xFF264F81);
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: !_visible
            ? const SizedBox.shrink()
            : Padding(
                key: const ValueKey('beta13-cold-greeting'),
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: blue.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.music_note, size: 14, color: blue),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          name.isEmpty ? greeting : '$greeting，$name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: blue,
                            fontWeight: FontWeight.w600,
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
}
