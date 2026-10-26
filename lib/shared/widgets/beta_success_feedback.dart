import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared drawn mark for compact comment notices and the central login HUD.
class BetaSuccessMark extends StatelessWidget {
  const BetaSuccessMark({this.size = 26, super.key});
  final double size;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 900),
    builder: (_, value, _) =>
        CustomPaint(size: Size.square(size), painter: _MarkPainter(value)),
  );
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = const Color(0xFF2CB780)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .07,
        size.height * .07,
        size.width * .86,
        size.height * .86,
      ),
      -math.pi / 2,
      math.pi * 2 * (progress * 1.7).clamp(0, 1),
      false,
      pen,
    );
    final path = Path()
      ..moveTo(size.width * .35, size.height * .52)
      ..lineTo(size.width * .46, size.height * .63)
      ..lineTo(size.width * .68, size.height * .39);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * ((progress - .3) / .7).clamp(0, 1)),
      pen..strokeWidth = size.width * .045,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.progress != progress;
}

class BetaLoginSuccess extends StatefulWidget {
  const BetaLoginSuccess({required this.onComplete, this.onReveal, super.key});
  final VoidCallback onComplete;
  final VoidCallback? onReveal;
  @override
  State<BetaLoginSuccess> createState() => _BetaLoginSuccessState();
}

class _BetaLoginSuccessState extends State<BetaLoginSuccess>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 220),
  );
  Timer? _timer;
  bool _leaving = false;
  @override
  void initState() {
    super.initState();
    _motion.forward();
    _timer = Timer(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;
      widget.onReveal?.call();
      setState(() => _leaving = true);
      await _motion.reverse();
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: '登录成功',
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Opaque from the first frame. During dismissal this veil fades to the
        // already-mounted guide, together with the smaller success card.
        FadeTransition(
          opacity: _leaving ? _motion : kAlwaysCompleteAnimation,
          child: ColoredBox(
            key: const ValueKey('beta13-success-cover'),
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        Align(
          alignment: const Alignment(0, -.28),
          child: FadeTransition(
            opacity: _motion,
            child: ScaleTransition(
              scale: Tween(begin: .9, end: 1.0).animate(
                CurvedAnimation(
                  parent: _motion,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              ),
              child: RepaintBoundary(
                child: Container(
                  key: const ValueKey('beta10-login-success'),
                  width: 214,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xF20D1012),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const RepaintBoundary(child: BetaSuccessMark(size: 82)),
                      const SizedBox(height: 23),
                      Text(
                        '登录成功',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
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
