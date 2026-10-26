import 'package:flutter/material.dart';

/// The handle owns dismissal; artwork, lyric scrolling and adjustable controls
/// never compete with this vertical drag. AnimatedBuilder keeps the live
/// player subtree stable throughout the gesture on every display refresh rate.
class PlayerPullToDismiss extends StatefulWidget {
  const PlayerPullToDismiss({
    required this.child,
    required this.onDismiss,
    super.key,
  });
  final Widget child;
  final VoidCallback onDismiss;
  @override
  State<PlayerPullToDismiss> createState() => _PlayerPullToDismissState();
}

class _PlayerPullToDismissState extends State<PlayerPullToDismiss>
    with SingleTickerProviderStateMixin {
  late final AnimationController _offset = AnimationController.unbounded(
    vsync: this,
  );
  bool _closing = false;
  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void update(DragUpdateDetails details) {
    if (_closing) return;
    _offset.stop();
    _offset.value = (_offset.value + details.delta.dy).clamp(
      0,
      MediaQuery.sizeOf(context).height,
    );
  }

  Future<void> finish([double speed = 0]) async {
    if (_closing) return;
    final height = MediaQuery.sizeOf(context).height;
    final close =
        _offset.value > height * .18 || (_offset.value > 16 && speed > 650);
    _closing = close;
    await _offset.animateTo(
      close ? height : 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(milliseconds: close ? 240 : 280),
      curve: Curves.easeOutCubic,
    );
    if (mounted && close) widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) => _DismissHandleScope(
    state: this,
    child: AnimatedBuilder(
      animation: _offset,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _offset.value),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_offset.value > 0 ? 24 : 0),
          ),
          child: child,
        ),
      ),
    ),
  );
}

class _DismissHandleScope extends InheritedWidget {
  const _DismissHandleScope({required this.state, required super.child});
  final _PlayerPullToDismissState state;
  @override
  bool updateShouldNotify(_DismissHandleScope oldWidget) =>
      state != oldWidget.state;
}

class PlayerDismissHandle extends StatelessWidget {
  const PlayerDismissHandle({required this.onTap, super.key});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<_DismissHandleScope>()!
        .state;
    return Semantics(
      label: '向下拖动收起播放器',
      button: true,
      child: GestureDetector(
        key: const ValueKey('player-dismiss-handle'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onVerticalDragUpdate: state.update,
        onVerticalDragEnd: (details) =>
            state.finish(details.primaryVelocity ?? 0),
        onVerticalDragCancel: () => state.finish(),
        child: SizedBox(
          width: 112,
          height: 36,
          child: Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
