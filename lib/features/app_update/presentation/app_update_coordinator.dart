import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/app_preferences.dart';
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

class _AppUpdateCoordinatorState extends ConsumerState<AppUpdateCoordinator> {
  bool _scheduled = false;
  bool _presenting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleCheck());
  }

  void _scheduleCheck() {
    if (_scheduled || !ref.read(autoAppUpdateChecksEnabledProvider)) return;
    _scheduled = true;
    unawaited(_checkAfterLaunch());
  }

  Future<void> _checkAfterLaunch() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted ||
        ref
                .read(sharedPreferencesProvider)
                .getBool(disclaimerAcceptedPreferenceKey) !=
            true) {
      return;
    }
    final result = await ref.read(appUpdateControllerProvider.notifier).check();
    if (!mounted || result == null || !result.updateAvailable || _presenting) {
      return;
    }
    _presenting = true;
    try {
      await showAppUpdateSheet(context);
    } finally {
      _presenting = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
