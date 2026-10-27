import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AppleAudioGlyphKind {
  route,
  earphones,
  phone,
  speakerQuiet,
  speakerLoud,
  check,
}

/// Playback-destination vectors. The earbud contour adapts Tabler's MIT-licensed
/// device-airpods outline (see third_party/audio_glyphs/NOTICE.md), rather than
/// bundling Apple's platform-restricted SF Symbols. A glyph never changes the
/// real device name or claims that a non-Apple headset is an Apple product.
class AppleAudioGlyph extends StatelessWidget {
  const AppleAudioGlyph(
    this.kind, {
    this.size = 24,
    required this.color,
    super.key,
  });
  final AppleAudioGlyphKind kind;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(kind, color),
    ),
  );
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.kind, this.color);
  final AppleAudioGlyphKind kind;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) =>
      paintAppleAudioGlyph(canvas, size, kind, color);
  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.kind != kind || old.color != color;
}

/// The toolbar's existing canvas shares these exact contours with the dialog.
void paintAppleAudioGlyph(
  Canvas canvas,
  Size size,
  AppleAudioGlyphKind kind,
  Color color,
) {
  canvas.save();
  canvas.scale(size.width / 40, size.height / 40);
  final pen = Paint()
    ..isAntiAlias = true
    ..color = color;
  switch (kind) {
    case AppleAudioGlyphKind.route:
      pen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round;
      for (final radius in [6.0, 10.5, 15.0]) {
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(20, 20), radius: radius),
          math.pi * .72,
          math.pi * 1.56,
          false,
          pen,
        );
      }
      pen.style = PaintingStyle.fill;
      canvas.drawPath(
        Path()
          ..moveTo(20, 21)
          ..lineTo(12.5, 32)
          ..lineTo(27.5, 32)
          ..close(),
        pen,
      );
    case AppleAudioGlyphKind.earphones:
      canvas.scale(40 / 24);
      pen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.65
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final mirror in [false, true]) {
        canvas.save();
        if (mirror) {
          canvas.translate(24, 0);
          canvas.scale(-1, 1);
        }
        final bud = Path()
          ..moveTo(6, 4)
          ..arcToPoint(const Offset(10, 7.8), radius: const Radius.circular(4))
          ..lineTo(10, 18.5)
          ..arcToPoint(
            const Offset(7, 18.5),
            radius: const Radius.circular(1.5),
          )
          ..lineTo(7, 12)
          ..lineTo(6, 12)
          ..arcToPoint(const Offset(2, 8.2), radius: const Radius.circular(4))
          ..lineTo(2, 8)
          ..arcToPoint(const Offset(6, 4), radius: const Radius.circular(4))
          ..close();
        canvas.drawPath(bud, pen);
        canvas.restore();
      }
    case AppleAudioGlyphKind.phone:
      pen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(11, 4, 18, 32),
          const Radius.circular(4),
        ),
        pen,
      );
      canvas.drawLine(const Offset(17, 8), const Offset(23, 8), pen);
      canvas.drawLine(const Offset(18, 32), const Offset(22, 32), pen);
    case AppleAudioGlyphKind.speakerQuiet:
    case AppleAudioGlyphKind.speakerLoud:
      canvas.drawPath(
        Path()
          ..moveTo(6, 16)
          ..lineTo(12, 16)
          ..lineTo(21, 9)
          ..quadraticBezierTo(22, 8.5, 22, 10)
          ..lineTo(22, 30)
          ..quadraticBezierTo(22, 31.5, 21, 31)
          ..lineTo(12, 24)
          ..lineTo(6, 24)
          ..quadraticBezierTo(5, 24, 5, 23)
          ..lineTo(5, 17)
          ..quadraticBezierTo(5, 16, 6, 16)
          ..close(),
        pen,
      );
      if (kind == AppleAudioGlyphKind.speakerLoud) {
        pen
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        for (final radius in [7.0, 12.0]) {
          canvas.drawArc(
            Rect.fromCircle(center: const Offset(21, 20), radius: radius),
            -.7,
            1.4,
            false,
            pen,
          );
        }
      }
    case AppleAudioGlyphKind.check:
      pen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(
        Path()
          ..moveTo(10, 21)
          ..lineTo(17, 27)
          ..lineTo(30, 12),
        pen,
      );
  }
  canvas.restore();
}
