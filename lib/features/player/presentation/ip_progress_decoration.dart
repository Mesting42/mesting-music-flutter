import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../themes/mesting_palette.dart';
import '../../themes/music_theme_preset.dart';

const _helloKittyAsset =
    'assets/images/theme_gallery/hello-kitty-progress-head.png';
const _kuromiAsset = 'assets/images/theme_gallery/kuromi-progress-head.png';

const double ipProgressTrackHeight = 6;
const double ipProgressLeadingDotDiameter = 9;
const double _ipProgressTrackCenterY = 24;

Color progressTrackColorForIp(MusicThemeIp ip) => switch (ip) {
  MusicThemeIp.classic => const Color(0xFF5F75DE),
  MusicThemeIp.shinchan => const Color(0xFFF2A72E),
  MusicThemeIp.helloKitty => MestingPalette.dangerBright,
  MusicThemeIp.kuromi => const Color(0xFF9B6BE8),
};

Size progressCompanionSize(MusicThemeIp ip) => switch (ip) {
  MusicThemeIp.helloKitty => const Size(50, 42),
  MusicThemeIp.kuromi => const Size(48, 44),
  MusicThemeIp.shinchan => const Size(104, 84),
  MusicThemeIp.classic => Size.zero,
};

double progressCompanionTop(MusicThemeIp ip) => switch (ip) {
  MusicThemeIp.helloKitty || MusicThemeIp.kuromi =>
    _ipProgressTrackCenterY - _progressLeadingDotCenterY(ip),
  MusicThemeIp.shinchan => -60,
  MusicThemeIp.classic => 0,
};

double _progressLeadingDotCenterY(MusicThemeIp ip) =>
    progressCompanionSize(ip).height - ipProgressLeadingDotDiameter / 2 - .5;

double progressCompanionLeft({
  required double progress,
  required double availableWidth,
  required double companionWidth,
}) {
  if (availableWidth <= companionWidth) return 0;
  return (progress.clamp(0.0, 1.0) * availableWidth - companionWidth / 2).clamp(
    0.0,
    availableWidth - companionWidth,
  );
}

/// Draws an IP-specific rail without changing the Slider's drag or semantics.
///
/// The character remains a separate widget so playback motion can be paused
/// independently while the rail stays cheap to repaint.
class IpProgressTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const IpProgressTrackShape({required this.ip});

  final MusicThemeIp ip;

  @override
  bool get isRounded => true;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final height = sliderTheme.trackHeight ?? 0;
    if (height <= 0) return;

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final inactiveColor = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    ).evaluate(enableAnimation)!;
    final activeColor = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    ).evaluate(enableAnimation)!;
    final radius = Radius.circular(trackRect.height / 2);
    final track = RRect.fromRectAndRadius(trackRect, radius);
    final canvas = context.canvas;

    canvas.drawRRect(
      track,
      Paint()
        ..shader = LinearGradient(
          colors: [_inactiveTint(ip).withValues(alpha: .24), inactiveColor],
        ).createShader(trackRect),
    );
    canvas.drawRRect(
      track,
      Paint()
        ..color = Colors.white.withValues(alpha: .12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );

    final splitX = thumbCenter.dx.clamp(trackRect.left, trackRect.right);
    final activeRect = textDirection == TextDirection.ltr
        ? Rect.fromLTRB(trackRect.left, trackRect.top, splitX, trackRect.bottom)
        : Rect.fromLTRB(
            splitX,
            trackRect.top,
            trackRect.right,
            trackRect.bottom,
          );
    if (activeRect.width <= 0) return;

    final activeTrack = RRect.fromRectAndRadius(activeRect, radius);
    canvas.drawRRect(
      activeTrack,
      Paint()
        ..shader = LinearGradient(
          colors: [_activeStart(ip), activeColor, _activeEnd(ip)],
          stops: const [0, .58, 1],
        ).createShader(activeRect),
    );

    canvas.save();
    canvas.clipRRect(activeTrack);
    switch (ip) {
      case MusicThemeIp.classic:
        break;
      case MusicThemeIp.shinchan:
        _paintCrayonRoad(canvas, activeRect);
      case MusicThemeIp.helloKitty:
        _paintRibbonStitches(canvas, activeRect);
      case MusicThemeIp.kuromi:
        _paintKuromiDiamonds(canvas, activeRect);
    }
    canvas.restore();
  }

  void _paintCrayonRoad(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = const Color(0xFFFFF4C7).withValues(alpha: .82)
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;
    for (double x = rect.left + 7; x < rect.right - 2; x += 12) {
      canvas.drawLine(
        Offset(x - 1.8, rect.center.dy + 1.4),
        Offset(x + 1.8, rect.center.dy - 1.4),
        paint,
      );
    }
  }

  void _paintRibbonStitches(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .86)
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;
    for (double x = rect.left + 6; x < rect.right - 2; x += 11) {
      canvas.drawLine(
        Offset(x, rect.center.dy),
        Offset(x + 3.2, rect.center.dy),
        paint,
      );
    }
  }

  void _paintKuromiDiamonds(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = const Color(0xFFFFB5DC).withValues(alpha: .9);
    for (double x = rect.left + 8; x < rect.right - 2; x += 14) {
      final center = Offset(x, rect.center.dy);
      final diamond = Path()
        ..moveTo(center.dx, center.dy - 1.7)
        ..lineTo(center.dx + 2.2, center.dy)
        ..lineTo(center.dx, center.dy + 1.7)
        ..lineTo(center.dx - 2.2, center.dy)
        ..close();
      canvas.drawPath(diamond, paint);
    }
  }

  Color _inactiveTint(MusicThemeIp ip) => switch (ip) {
    MusicThemeIp.classic => const Color(0xFF5F75DE),
    MusicThemeIp.shinchan => const Color(0xFFFFD35B),
    MusicThemeIp.helloKitty => MestingPalette.dangerSoft,
    MusicThemeIp.kuromi => const Color(0xFF5E427F),
  };

  Color _activeStart(MusicThemeIp ip) => switch (ip) {
    MusicThemeIp.classic => const Color(0xFF7187F1),
    MusicThemeIp.shinchan => const Color(0xFFFFD65A),
    MusicThemeIp.helloKitty => MestingPalette.dangerBright,
    MusicThemeIp.kuromi => const Color(0xFF7654BE),
  };

  Color _activeEnd(MusicThemeIp ip) => switch (ip) {
    MusicThemeIp.classic => const Color(0xFF5368D2),
    MusicThemeIp.shinchan => const Color(0xFFEF782D),
    MusicThemeIp.helloKitty => MestingPalette.danger,
    MusicThemeIp.kuromi => const Color(0xFFD85BA5),
  };
}

class IpProgressCompanion extends StatefulWidget {
  const IpProgressCompanion({
    required this.ip,
    required this.playing,
    super.key,
  }) : assert(ip == MusicThemeIp.helloKitty || ip == MusicThemeIp.kuromi);

  final MusicThemeIp ip;
  final bool playing;

  @override
  State<IpProgressCompanion> createState() => _IpProgressCompanionState();
}

class _IpProgressCompanionState extends State<IpProgressCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant IpProgressCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing || oldWidget.ip != widget.ip) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.playing && !_reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      if (_reduceMotion) _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = progressCompanionSize(widget.ip);
    return RepaintBoundary(
      key: ValueKey('ip-progress-companion-${widget.ip.name}'),
      child: SizedBox.fromSize(
        size: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final phase = _controller.value * math.pi * 2;
            return widget.ip == MusicThemeIp.helloKitty
                ? _HelloKittyCompanion(phase: phase)
                : _KuromiCompanion(phase: phase);
          },
        ),
      ),
    );
  }
}

class _HelloKittyCompanion extends StatelessWidget {
  const _HelloKittyCompanion({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            key: const ValueKey('hello-kitty-progress-ribbon-medallion'),
            painter: _KittyRibbonMedallionPainter(phase: phase),
          ),
        ),
        Positioned(
          left: 6,
          top: 3,
          width: 38,
          height: 27,
          child: Image.asset(
            _helloKittyAsset,
            key: const ValueKey('hello-kitty-progress-character'),
            fit: BoxFit.contain,
          ),
        ),
        _leadingDotPositioned(MusicThemeIp.helloKitty),
      ],
    );
  }
}

class _KuromiCompanion extends StatelessWidget {
  const _KuromiCompanion({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            key: const ValueKey('kuromi-progress-mischief-crest'),
            painter: _KuromiMischiefCrestPainter(phase: phase),
          ),
        ),
        Positioned(
          left: 7,
          top: 1,
          width: 34,
          height: 34,
          child: Image.asset(
            _kuromiAsset,
            key: const ValueKey('kuromi-progress-character'),
            fit: BoxFit.contain,
          ),
        ),
        _leadingDotPositioned(MusicThemeIp.kuromi),
      ],
    );
  }
}

Positioned _leadingDotPositioned(MusicThemeIp ip) {
  final size = progressCompanionSize(ip);
  return Positioned(
    key: ValueKey('ip-progress-leading-dot-${ip.name}'),
    left: (size.width - ipProgressLeadingDotDiameter) / 2,
    top: size.height - ipProgressLeadingDotDiameter - .5,
    width: ipProgressLeadingDotDiameter,
    height: ipProgressLeadingDotDiameter,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _leadingDotColor(ip), width: 1.25),
        boxShadow: [
          BoxShadow(
            color: _leadingDotColor(ip).withValues(alpha: .34),
            blurRadius: 3,
          ),
        ],
      ),
    ),
  );
}

Color _leadingDotColor(MusicThemeIp ip) => switch (ip) {
  MusicThemeIp.helloKitty => MestingPalette.danger,
  MusicThemeIp.kuromi => const Color(0xFFD85BA5),
  MusicThemeIp.shinchan || MusicThemeIp.classic => Colors.white,
};

class _KittyRibbonMedallionPainter extends CustomPainter {
  const _KittyRibbonMedallionPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = ((math.sin(phase) + 1) / 2).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, 16);
    final medallion = Rect.fromCenter(
      center: center,
      width: size.width - 6,
      height: 32,
    );

    canvas.drawOval(
      medallion.inflate(1.8),
      Paint()
        ..color = MestingPalette.dangerBright.withValues(
          alpha: .12 + pulse * .12,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawOval(
      medallion,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: .96),
            MestingPalette.dangerSoft.withValues(alpha: .88),
          ],
        ).createShader(medallion),
    );
    canvas.drawOval(
      medallion,
      Paint()
        ..color = MestingPalette.dangerBright.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35,
    );

    final leftTail = Path()
      ..moveTo(center.dx - 9, 27)
      ..lineTo(center.dx - 14, size.height - 2)
      ..lineTo(center.dx - 6, size.height - 6)
      ..lineTo(center.dx - 2, 29)
      ..close();
    final rightTail = Path()
      ..moveTo(center.dx + 9, 27)
      ..lineTo(center.dx + 14, size.height - 2)
      ..lineTo(center.dx + 6, size.height - 6)
      ..lineTo(center.dx + 2, 29)
      ..close();
    final tailPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [MestingPalette.dangerBright, MestingPalette.danger],
      ).createShader(Offset.zero & size);
    canvas.drawPath(leftTail, tailPaint);
    canvas.drawPath(rightTail, tailPaint);

    final sparkleAlpha = (.42 + pulse * .4).clamp(0.0, 1.0);
    final sparkle = Paint()
      ..color = const Color(0xFFFFF3A5).withValues(alpha: sparkleAlpha);
    _paintSparkle(canvas, const Offset(3.5, 10), 2.2, sparkle);
    _paintSparkle(canvas, Offset(size.width - 3.5, 7), 1.7, sparkle);
  }

  void _paintSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint..strokeWidth = .9,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _KittyRibbonMedallionPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

class _KuromiMischiefCrestPainter extends CustomPainter {
  const _KuromiMischiefCrestPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = ((math.sin(phase) + 1) / 2).clamp(0.0, 1.0);
    final centerX = size.width / 2;
    final crest = Path()
      ..moveTo(centerX, 0)
      ..lineTo(size.width - 4, 8)
      ..lineTo(size.width - 6, 27)
      ..quadraticBezierTo(size.width - 9, 34, centerX, size.height - 8)
      ..quadraticBezierTo(9, 34, 6, 27)
      ..lineTo(4, 8)
      ..close();

    canvas.drawPath(
      crest,
      Paint()
        ..color = const Color(0xFFD85BA5).withValues(alpha: .1 + pulse * .12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5),
    );
    canvas.drawPath(
      crest,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20182B), Color(0xFF694595)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      crest,
      Paint()
        ..color = const Color(0xFFE477BD).withValues(alpha: .88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25,
    );

    final diamondPaint = Paint()
      ..color = Colors.white.withValues(alpha: .48 + pulse * .4);
    for (final center in [Offset(3, 15), Offset(size.width - 3, 21)]) {
      final diamond = Path()
        ..moveTo(center.dx, center.dy - 2.6)
        ..lineTo(center.dx + 2.2, center.dy)
        ..lineTo(center.dx, center.dy + 2.6)
        ..lineTo(center.dx - 2.2, center.dy)
        ..close();
      canvas.drawPath(diamond, diamondPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _KuromiMischiefCrestPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
