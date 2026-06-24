import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/entities/mask_model.dart';

/// 🌱 SeedColor — Mask Texture Generator
///
/// Utilitas untuk merender deskripsi masker geometris (Brush, Linear, Radial, AI)
/// menjadi tekstur gambar grayscale/alpha (ui.Image) berukuran 512x512.
class MaskTextureGenerator {
  /// Membuat tekstur masker berbasis ukuran tertentu secara asinkron
  static Future<ui.Image> generate({
    required MaskModel mask,
    required Size size,
    ui.Image? baseImage,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

    // Clear background
    canvas.drawColor(Colors.transparent, BlendMode.clear);

    if (!mask.isVisible) {
      final picture = recorder.endRecording();
      return picture.toImage(size.width.toInt(), size.height.toInt());
    }

    switch (mask.type) {
      case MaskType.brush:
        _drawBrush(canvas, size, mask.strokes);
        break;
      case MaskType.linear:
        _drawLinear(canvas, size, mask.linearStart, mask.linearEnd);
        break;
      case MaskType.radial:
        _drawRadial(
          canvas,
          size,
          mask.radialCenter,
          mask.radialRadiusX,
          mask.radialRadiusY,
          mask.radialRotation,
        );
        break;
      case MaskType.subject:
        _drawSubject(canvas, size, baseImage);
        break;
      case MaskType.sky:
        _drawSky(canvas, size, baseImage);
        break;
    }

    final picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  static void _drawBrush(Canvas canvas, Size size, List<BrushStroke> strokes) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final double width = stroke.radius * size.width;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: stroke.opacity)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width;

      // Blur filter untuk mengatur kehalusan tepi kuas (hardness)
      if (stroke.hardness < 1.0) {
        final blurRadius = width * (1.0 - stroke.hardness) * 0.5;
        if (blurRadius > 0.0) {
          paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
        }
      }

      final path = Path();
      path.moveTo(stroke.points.first.dx * size.width, stroke.points.first.dy * size.height);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx * size.width, stroke.points[i].dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  static void _drawLinear(Canvas canvas, Size size, Offset? start, Offset? end) {
    final s = start ?? const Offset(0.5, 0.2);
    final e = end ?? const Offset(0.5, 0.8);

    final startPoint = Offset(s.dx * size.width, s.dy * size.height);
    final endPoint = Offset(e.dx * size.width, e.dy * size.height);

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        startPoint,
        endPoint,
        [Colors.white, Colors.white.withValues(alpha: 0.0)],
        [0.0, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  static void _drawRadial(Canvas canvas, Size size, Offset? center, double radX, double radY, double rotation) {
    final c = center ?? const Offset(0.5, 0.5);
    final centerPoint = Offset(c.dx * size.width, c.dy * size.height);

    canvas.save();
    canvas.translate(centerPoint.dx, centerPoint.dy);
    canvas.rotate(rotation);
    canvas.scale(radX * size.width, radY * size.height);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1.0,
        [Colors.white, Colors.white.withValues(alpha: 0.0)],
        [0.0, 1.0],
      );

    canvas.drawCircle(Offset.zero, 1.0, paint);
    canvas.restore();
  }

  static void _drawSubject(Canvas canvas, Size size, ui.Image? baseImage) {
    // Simulasi masker AI Subject: membuat gradien elips terpusat pada subjek (gunung/orang)
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.58),
        size.width * 0.38,
        [Colors.white, Colors.white.withValues(alpha: 0.0)],
        [0.0, 1.0],
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.58),
        width: size.width * 0.75,
        height: size.height * 0.52,
      ),
      paint,
    );
  }

  static void _drawSky(Canvas canvas, Size size, ui.Image? baseImage) {
    // Simulasi masker AI Sky: bagian atas gambar
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, 0.0),
        Offset(size.width * 0.5, size.height * 0.46),
        [Colors.white, Colors.white.withValues(alpha: 0.0)],
        [0.0, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.46), paint);
  }
}
