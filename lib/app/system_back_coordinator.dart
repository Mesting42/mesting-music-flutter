import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keeps Android's back callback in sync with the retained Flutter navigator.
///
/// AudioService can keep Dart and its pages alive after their Android Activity
/// is destroyed. A new Activity starts without the old OnBackInvokedCallback,
/// even though no Dart route changed. NavigationNotification alone therefore
/// cannot restore system edge Back: republish its latest value on resume.
class SystemBackCoordinator extends StatefulWidget {
  const SystemBackCoordinator({required this.child, super.key});

  final Widget child;

  @override
  State<SystemBackCoordinator> createState() => _SystemBackCoordinatorState();
}

class _SystemBackCoordinatorState extends State<SystemBackCoordinator>
    with WidgetsBindingObserver {
  bool? _canHandlePop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _synchronize() {
    final canHandlePop = _canHandlePop;
    if (!mounted || canHandlePop == null) return;
    unawaited(SystemNavigator.setFrameworkHandlesBack(canHandlePop));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _synchronize();
    // The first resumed frame can also restore local search history or an
    // entry overlay. Re-read the latest notification after that frame settles.
    WidgetsBinding.instance.addPostFrameCallback((_) => _synchronize());
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<NavigationNotification>(
        onNotification: (notification) {
          _canHandlePop = notification.canHandlePop;
          // WidgetsApp still owns normal route-change reporting. This boundary
          // only adds synchronization when the native window resumes.
          return false;
        },
        child: widget.child,
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
