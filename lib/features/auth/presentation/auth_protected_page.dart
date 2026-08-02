import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/mesting_loading_indicator.dart';
import '../auth_providers.dart';
import 'auth_gate.dart';

class AuthProtectedPage extends ConsumerStatefulWidget {
  const AuthProtectedPage({
    required this.child,
    required this.reason,
    required this.redirect,
    this.fallback = '/profile',
    super.key,
  });

  final Widget child;
  final String reason;
  final String redirect;
  final String fallback;

  @override
  ConsumerState<AuthProtectedPage> createState() => _AuthProtectedPageState();
}

class _AuthProtectedPageState extends ConsumerState<AuthProtectedPage> {
  bool _requesting = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    if (auth.value?.user != null) return widget.child;
    if (!auth.isLoading && !_requesting) {
      _requesting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestAccess());
    }
    return const Center(
      child: MestingLoadingIndicator(
        key: ValueKey('auth-protected-loading-animation'),
        semanticLabel: '正在确认登录状态',
      ),
    );
  }

  Future<void> _requestAccess() async {
    final allowed = await ensureAuthenticated(
      context,
      ref,
      reason: widget.reason,
      redirect: widget.redirect,
    );
    if (!mounted) return;
    if (!allowed) context.go(widget.fallback);
    setState(() => _requesting = false);
  }
}
