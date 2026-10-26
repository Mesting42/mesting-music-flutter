import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/audio/playback_mode.dart';

enum PlayerToolbarTool { lyrics, output, queue }

/// Code-native vectors calibrated to the user's toolbar reference. The same
/// 40dp canvas gives every tool a stable optical center and a 48dp outer target.
/// Route metadata and playback state are supplied by the caller, not guessed
/// by this purely visual component.
class PlayerToolbarGlyph extends StatelessWidget {
  const PlayerToolbarGlyph({
    required this.tool,
    this.active = false,
    this.headphones = false,
    this.order = const PlaybackOrder(),
    super.key,
  });
  final PlayerToolbarTool tool;
  final bool active, headphones;
  final PlaybackOrder order;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: const Size.square(40),
      painter: _ToolbarPainter(tool, active, headphones, order),
    ),
  );
}

class _ToolbarPainter extends CustomPainter {
  _ToolbarPainter(this.tool, this.active, this.headphones, this.order);
  final PlayerToolbarTool tool;
  final bool active, headphones;
  final PlaybackOrder order;
  static const ink = Color(0xFFB5C7D7);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);
    final paint = Paint()
      ..isAntiAlias = true
      ..color = ink;
    if (active) {
      paint.color = const Color(0xFF93ADBF);
      canvas.drawCircle(const Offset(20, 20), 17, paint);
    }
    switch (tool) {
      case PlayerToolbarTool.lyrics:
        paint.color = active ? const Color(0xFF233C50) : ink;
        final bubble = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(11, 11, 18, 16),
              const Radius.circular(4.5),
            ),
          )
          ..moveTo(15, 25)
          ..lineTo(14, 30)
          ..lineTo(21, 25)
          ..close();
        canvas.drawPath(bubble, paint);
        paint.color = active ? ink : const Color(0xFF233C50);
        for (final x in [15.0, 21.0]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, 15, 3.3, 4),
              const Radius.circular(1),
            ),
            paint,
          );
          canvas.drawPath(
            Path()
              ..moveTo(x + 3.3, 18)
              ..quadraticBezierTo(x + 3.3, 22, x, 22)
              ..lineTo(x, 20.4)
              ..quadraticBezierTo(x + 1.8, 20.4, x + 1.8, 18)
              ..close(),
            paint,
          );
        }
      case PlayerToolbarTool.output:
        if (headphones) {
          // Two earpieces, short stems and dark acoustic ports retain their
          // recognizable silhouette at 24 physical display pixels as well.
          for (final left in [true, false]) {
            canvas.save();
            if (!left) {
              canvas.translate(40, 0);
              canvas.scale(-1, 1);
            }
            paint.color = ink;
            final bud = Path()
              ..moveTo(8.2, 13.5)
              ..cubicTo(7, 10.2, 10.5, 8.5, 14.5, 10)
              ..cubicTo(17.9, 11.3, 19.2, 14.2, 17.2, 17.2)
              ..lineTo(15.3, 19)
              ..lineTo(15.3, 28.5)
              ..quadraticBezierTo(12.2, 31, 11.5, 27.8)
              ..lineTo(11.4, 18.8)
              ..quadraticBezierTo(8.5, 17.8, 8.2, 13.5)
              ..close();
            canvas.drawPath(bud, paint);
            paint.color = const Color(0xFF263E51);
            canvas.drawOval(const Rect.fromLTWH(10, 11.1, 3.7, 2.4), paint);
            canvas.drawOval(const Rect.fromLTWH(15.4, 13.2, 2.2, 4.2), paint);
            paint.color = const Color(0xFF6F879A);
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTWH(12, 26.5, 2.6, 2),
                const Radius.circular(1),
              ),
              paint,
            );
            canvas.restore();
          }
        } else {
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round;
          final screen = Path()
            ..moveTo(13, 25)
            ..lineTo(9, 25)
            ..lineTo(9, 12)
            ..quadraticBezierTo(9, 10, 11, 10)
            ..lineTo(29, 10)
            ..quadraticBezierTo(31, 10, 31, 12)
            ..lineTo(31, 25)
            ..lineTo(27, 25);
          canvas.drawPath(screen, paint);
          paint.style = PaintingStyle.fill;
          canvas.drawPath(
            Path()
              ..moveTo(20, 21)
              ..lineTo(12.5, 30)
              ..lineTo(27.5, 30)
              ..close(),
            paint,
          );
        }
      case PlayerToolbarTool.queue:
        paint
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        for (final y in [14.0, 20.0, 26.0]) {
          canvas.drawCircle(Offset(9.3, y), .8, paint);
          canvas.drawLine(Offset(14, y), Offset(y == 14 ? 24 : 29, y), paint);
        }
        if (order.shuffle || order.repeat != PlaybackRepeat.off) {
          paint
            ..style = PaintingStyle.fill
            ..color = const Color(0xFF385369);
          canvas.drawCircle(const Offset(30, 10), 7.1, paint);
          paint
            ..color = ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3;
          if (order.shuffle) {
            canvas.drawPath(
              Path()
                ..moveTo(26, 7.3)
                ..cubicTo(29.5, 7.3, 30.2, 12.7, 34, 12.7)
                ..moveTo(26, 12.7)
                ..cubicTo(29.5, 12.7, 30.2, 7.3, 34, 7.3),
              paint,
            );
            canvas.drawPath(
              Path()
                ..moveTo(32.3, 5.8)
                ..lineTo(34, 7.3)
                ..lineTo(32.3, 8.7)
                ..moveTo(32.3, 11.3)
                ..lineTo(34, 12.7)
                ..lineTo(32.3, 14.1),
              paint,
            );
          } else {
            canvas.drawArc(
              const Rect.fromLTWH(26, 6.5, 8, 7),
              -.6,
              math.pi * .86,
              false,
              paint,
            );
            canvas.drawArc(
              const Rect.fromLTWH(26, 6.5, 8, 7),
              math.pi - .6,
              math.pi * .86,
              false,
              paint,
            );
            canvas.drawPath(
              Path()
                ..moveTo(33.8, 6.4)
                ..lineTo(34.1, 9)
                ..lineTo(31.5, 8.8)
                ..moveTo(26.2, 13.6)
                ..lineTo(25.9, 11)
                ..lineTo(28.5, 11.2),
              paint,
            );
            if (order.repeat == PlaybackRepeat.one) {
              canvas.drawLine(
                const Offset(30, 8.3),
                const Offset(30, 11.6),
                paint,
              );
            }
          }
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ToolbarPainter old) =>
      tool != old.tool ||
      active != old.active ||
      headphones != old.headphones ||
      order != old.order;
}
