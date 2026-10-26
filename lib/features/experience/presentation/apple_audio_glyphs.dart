import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AppleAudioGlyphKind { route, earphones, speakerQuiet, speakerLoud, check }

/// Application-authored vectors informed by Apple's playback-destination
/// vocabulary. These are not extracted SF Symbols or an assertion of a device
/// brand: native route metadata continues to own the actual name and type.
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
      for (final mirror in [false, true]) {
        canvas.save();
        if (mirror) {
          canvas.translate(40, 0);
          canvas.scale(-1, 1);
        }
        final bud = Path()
          ..moveTo(8.5, 12.3)
          ..cubicTo(8.5, 8.6, 13, 8.1, 16.4, 10.7)
          ..cubicTo(19.6, 13.2, 19.1, 16.8, 15.5, 18.1)
          ..lineTo(15.5, 29)
          ..quadraticBezierTo(15.5, 31.5, 12.9, 31.5)
          ..quadraticBezierTo(10.5, 31.5, 10.5, 29)
          ..lineTo(10.5, 18)
          ..quadraticBezierTo(8.5, 16, 8.5, 12.3)
          ..close();
        // Transparent acoustic ports keep the contour crisp in both themes.
        final port = Paint()
          ..isAntiAlias = true
          ..color = color.withValues(alpha: .3)
          ..blendMode = BlendMode.dstOut;
        canvas.saveLayer(const Rect.fromLTWH(7, 7, 13, 26), Paint());
        canvas.drawPath(bud, pen);
        canvas.drawOval(const Rect.fromLTWH(12.8, 11, 3.4, 4.3), port);
        canvas.restore();
        canvas.restore();
      }
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
