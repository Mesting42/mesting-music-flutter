import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/app_preferences.dart';
import '../../../core/platform/distribution_channel.dart';
import '../../auth/beta_entry_flow.dart';
import '../../auth/presentation/first_launch_auth_coordinator.dart';
import '../../legal/presentation/disclaimer_dialog.dart';
import '../app_update_providers.dart';
import 'app_update_sheet.dart';

class AppUpdateCoordinator extends ConsumerStatefulWidget {
  const AppUpdateCoordinator({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<AppUpdateCoordinator> createState() =>
      _AppUpdateCoordinatorState();
}

/// Checks only after entry is complete. Foreground probes are throttled and
/// never replace the active controller/download. Public updates need no login.
class _AppUpdateCoordinatorState extends ConsumerState<AppUpdateCoordinator>
    with WidgetsBindingObserver {
  bool _scheduled = false;
  bool _presenting = false;
  DateTime? _lastCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleCheck());
  }

  bool _eligible() {
    final preferences = ref.read(sharedPreferencesProvider);
    if (preferences.getBool(firstLaunchAuthCompletedPreferenceKey) != true) {
      return false;
    }
    if (DistributionChannel.isBeta) {
      final stage = ref.read(betaEntryFlowProvider);
      return stage == BetaEntryStage.idle || stage == BetaEntryStage.app;
    }
    return hasAcceptedLegalDocuments(preferences);
  }

  void _scheduleCheck() {
    if (!mounted ||
        _scheduled ||
        _presenting ||
        !ref.read(autoAppUpdateChecksEnabledProvider) ||
        !_eligible()) {
      return;
    }
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < const Duration(minutes: 15)) {
      return;
    }
    _scheduled = true;
    unawaited(_checkAfterLaunch());
  }

  Future<void> _checkAfterLaunch() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      if (!mounted || !_eligible()) return;
      _lastCheck = DateTime.now();
      final result = await ref
          .read(appUpdateControllerProvider.notifier)
          .check();
      if (!mounted ||
          result == null ||
          !result.updateAvailable ||
          _presenting) {
        return;
      }
      _presenting = true;
      try {
        await showAppUpdateSheet(context);
      } finally {
        _presenting = false;
      }
    } finally {
      _scheduled = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _scheduleCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DistributionChannel.isBeta) {
      ref.listen(betaEntryFlowProvider, (_, next) {
        if (next == BetaEntryStage.app) _scheduleCheck();
      });
    }
    return widget.child;
  }
}
