import 'package:flutter/widgets.dart';

/// Tracks this window's keyboard even below a resizing Scaffold. Its body
/// MediaQuery has already consumed viewInsets; observing the view avoids a
/// device-specific inset heuristic and preserves the caller's text scaling.
class KeyboardVisibilityBuilder extends StatefulWidget {
  const KeyboardVisibilityBuilder({required this.builder, super.key});
  final Widget Function(BuildContext context, bool visible) builder;
  @override
  State<KeyboardVisibilityBuilder> createState() => _KeyboardVisibilityState();
}

class _KeyboardVisibilityState extends State<KeyboardVisibilityBuilder>
    with WidgetsBindingObserver {
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = View.of(context).viewInsets.bottom > 0;
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final visible = View.of(context).viewInsets.bottom > 0;
    if (visible != _visible) setState(() => _visible = visible);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _visible);
}
