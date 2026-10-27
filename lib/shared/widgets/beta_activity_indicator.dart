import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cupertino-style ticks with an opaque leading stroke for colored actions.
///
/// CupertinoActivityIndicator caps every tick at 147/255 opacity, which can
/// make a white busy indicator disappear against blue glass in light mode.
/// Keep the familiar eight-tick motion, with one fully visible white stroke.
class BetaActivityIndicator extends StatefulWidget {
  const BetaActivityIndicator({
    this.color = Colors.white,
    this.radius = 12,
    super.key,
  });

  final Color color;
  final double radius;

  @override
  State<BetaActivityIndicator> createState() => _BetaActivityIndicatorState();
}

class _BetaActivityIndicatorState extends State<BetaActivityIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _rotation.stop();
    } else if (!_rotation.isAnimating) {
      _rotation.repeat();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.radius * 2,
    child: CustomPaint(
      painter: _ActivityTicks(_rotation, widget.color, widget.radius),
    ),
  );
}

class _ActivityTicks extends CustomPainter {
  _ActivityTicks(this.position, this.color, this.radius)
    : super(repaint: position);

  final Animation<double> position;
  final Color color;
  final double radius;
  static const _alphas = [80, 88, 104, 128, 158, 190, 222, 255];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final tick = RRect.fromLTRBR(
      -radius / 10,
      -radius,
      radius / 10,
      -radius / 3,
      Radius.circular(radius / 10),
    );
    final active = (position.value * _alphas.length).floor();
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    for (var i = 0; i < _alphas.length; i++) {
      paint.color = color.withAlpha(_alphas[(i - active) % _alphas.length]);
      canvas.drawRRect(tick, paint);
      canvas.rotate(math.pi * 2 / _alphas.length);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ActivityTicks oldDelegate) =>
      position != oldDelegate.position ||
      color != oldDelegate.color ||
      radius != oldDelegate.radius;
}
