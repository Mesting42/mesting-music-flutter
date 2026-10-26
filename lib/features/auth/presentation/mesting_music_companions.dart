import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Two original, articulated music characters. Drawing and interaction are
/// isolated from authentication; no network or audio player is created here.
class MestingMusicCompanions extends StatefulWidget {
  const MestingMusicCompanions({this.height = 238, super.key});
  final double height;
  @override
  State<MestingMusicCompanions> createState() => _MestingMusicCompanionsState();
}

class _MestingMusicCompanionsState extends State<MestingMusicCompanions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();
  int _greetingUntil = 0;
  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Mesting 音符与唱片伙伴，轻点打招呼',
    button: true,
    child: GestureDetector(
      onTap: () => setState(
        () => _greetingUntil = DateTime.now().millisecondsSinceEpoch + 1600,
      ),
      child: RepaintBoundary(
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _beat,
            builder: (context, _) => CustomPaint(
              painter: _CompanionPainter(
                MediaQuery.disableAnimationsOf(context) ? .16 : _beat.value,
                DateTime.now().millisecondsSinceEpoch < _greetingUntil,
                Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CompanionPainter extends CustomPainter {
  _CompanionPainter(this.time, this.greeting, this.dark);
  final double time;
  final bool greeting, dark;
  static const coral = Color(0xFFDE5757);
  static const ink = Color(0xFF30282B);
  Color get outline => dark ? const Color(0xFFEBD3C9) : ink;
  final Paint fill = Paint()..isAntiAlias = true;
  void stroke(Canvas c, Path path, {Color? color, double width = 3.4}) =>
      c.drawPath(
        path,
        Paint()
          ..color = color ?? outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
  void limb(Canvas c, Offset a, Offset b, Offset d) => stroke(
    c,
    Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(b.dx, b.dy, d.dx, d.dy),
  );
  @override
  void paint(Canvas c, Size s) {
    c.save();
    final scale = math.min(s.width / 350, s.height / 240);
    c.translate((s.width - 350 * scale) / 2, (s.height - 240 * scale) / 2);
    c.scale(scale);
    final beat = math.sin(time * math.pi * 8);
    final hand = greeting ? math.sin(time * math.pi * 40) * 10 : beat * 3;
    fill.color = coral.withValues(alpha: dark ? .10 : .08);
    c.drawOval(const Rect.fromLTWH(32, 196, 288, 22), fill);
    // Left character: a headphone-wearing musical note with an offset stem.
    c.save();
    c.translate(96, 123 + beat * 3);
    c.rotate(beat * .035);
    limb(
      c,
      const Offset(-14, 39),
      const Offset(-19, 66),
      const Offset(-27, 72),
    );
    limb(c, const Offset(13, 39), const Offset(20, 61), const Offset(32, 65));
    limb(
      c,
      const Offset(-28, 7),
      const Offset(-58, 3),
      Offset(-61, -14 - hand),
    );
    limb(c, const Offset(24, 9), const Offset(45, -3), const Offset(53, -1));
    final body = Path()
      ..moveTo(-24, -5)
      ..cubicTo(-39, -4, -43, 34, -16, 40)
      ..cubicTo(11, 47, 31, 32, 26, 7)
      ..lineTo(22, -52)
      ..quadraticBezierTo(41, -50, 48, -63)
      ..quadraticBezierTo(27, -78, 9, -66)
      ..lineTo(9, 2)
      ..quadraticBezierTo(-8, -12, -24, -5)
      ..close();
    c.drawPath(body, fill..color = coral);
    stroke(c, body, width: 2.4);
    stroke(
      c,
      Path()
        ..moveTo(-29, 0)
        ..cubicTo(-36, -32, 25, -38, 30, -3),
      width: 5,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-36, -4, 10, 23),
        const Radius.circular(5),
      ),
      fill..color = ink,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(25, -6, 10, 23),
        const Radius.circular(5),
      ),
      fill,
    );
    _face(c, const Offset(-3, 16), blink: time > .80 && time < .825);
    c.restore();
    // Right character: warm porcelain record, coral centre and articulated arms.
    c.save();
    c.translate(239, 121 - beat * 3);
    c.rotate(-beat * .045);
    limb(
      c,
      const Offset(-14, 45),
      const Offset(-21, 65),
      const Offset(-33, 69),
    );
    limb(c, const Offset(17, 43), const Offset(26, 60), const Offset(35, 65));
    limb(c, const Offset(-43, 5), const Offset(-58, -2), const Offset(-77, -1));
    limb(
      c,
      const Offset(42, -2),
      const Offset(58, -15),
      Offset(63 + hand, -37),
    );
    c.drawCircle(Offset.zero, 48, fill..color = const Color(0xFFFFF4E7));
    c.drawCircle(
      Offset.zero,
      48,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    for (final radius in [33.0, 39.0]) {
      c.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        .5,
        1.3,
        false,
        Paint()
          ..color = const Color(0xFFD2B8AE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    c.drawCircle(Offset.zero, 22, fill..color = coral);
    _face(c, const Offset(0, -2), blink: time > .36 && time < .385);
    c.drawCircle(const Offset(32, -36), 4, fill..color = Colors.white);
    c.restore();
    for (var i = 0; i < 5; i++) {
      final x = 35.0 + i * 67;
      final y = 36.0 + math.sin(i * 1.6 + time * math.pi * 2) * 9;
      final p = Path()
        ..moveTo(x, y - 4)
        ..lineTo(x, y + 4)
        ..moveTo(x - 4, y)
        ..lineTo(x + 4, y);
      stroke(
        c,
        p,
        color: i.isEven ? coral : (dark ? const Color(0xFFEED7CD) : ink),
        width: 2,
      );
    }
    c.restore();
  }

  void _face(Canvas c, Offset origin, {required bool blink}) {
    for (final x in [-8.0, 8.0]) {
      if (blink) {
        stroke(
          c,
          Path()
            ..moveTo(origin.dx + x - 2, origin.dy)
            ..lineTo(origin.dx + x + 2, origin.dy),
          width: 2,
          color: ink,
        );
      } else {
        c.drawOval(
          Rect.fromCenter(center: origin + Offset(x, 0), width: 3.6, height: 6),
          fill..color = ink,
        );
      }
    }
    stroke(
      c,
      Path()
        ..moveTo(origin.dx - 4, origin.dy + 8)
        ..quadraticBezierTo(
          origin.dx,
          origin.dy + 12,
          origin.dx + 5,
          origin.dy + 7,
        ),
      width: 2,
      color: ink,
    );
  }

  @override
  bool shouldRepaint(_CompanionPainter old) =>
      old.time != time || old.greeting != greeting || old.dark != dark;
}
