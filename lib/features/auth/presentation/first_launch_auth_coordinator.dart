import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/app_preferences.dart';
import '../../../core/platform/sensitive_screen.dart';
import '../../../shared/widgets/mesting_loading_indicator.dart';
import '../auth_providers.dart';
import 'auth_page.dart';

const firstLaunchAuthCompletedPreferenceKey =
    'mesting_first_launch_auth_completed_v1';

class FirstLaunchAuthCoordinator extends ConsumerStatefulWidget {
  const FirstLaunchAuthCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<FirstLaunchAuthCoordinator> createState() =>
      _FirstLaunchAuthCoordinatorState();
}

class _FirstLaunchAuthCoordinatorState
    extends ConsumerState<FirstLaunchAuthCoordinator> {
  late bool _completed;
  bool _saving = false;
  final _authNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _completed =
        ref
            .read(sharedPreferencesProvider)
            .getBool(firstLaunchAuthCompletedPreferenceKey) ==
        true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    if (!_completed && auth.value?.user != null && !_saving) {
      _saving = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
    }

    if (_completed || auth.value?.user != null) return widget.child;

    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: auth.isLoading
                ? const ColoredBox(
                    color: Color(0xFF15131A),
                    child: Center(
                      child: MestingLoadingIndicator(
                        key: ValueKey('first-launch-loading-animation'),
                        color: Color(0xFF91A5FF),
                        secondaryColor: Color(0xFF61C3C4),
                        semanticLabel: '正在恢复账号',
                      ),
                    ),
                  )
                : HeroControllerScope.none(
                    child: Navigator(
                      key: _authNavigatorKey,
                      onGenerateRoute: (_) => PageRouteBuilder<void>(
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SensitiveScreen(
                              child: AuthPage(
                                initialMode: 'login',
                                redirect: '/music/recommend',
                                firstLaunch: true,
                                onExperience: _complete,
                              ),
                            ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _complete() async {
    if (_completed) return;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(firstLaunchAuthCompletedPreferenceKey, true);
    if (mounted) {
      setState(() {
        _completed = true;
        _saving = false;
      });
    }
  }
}
