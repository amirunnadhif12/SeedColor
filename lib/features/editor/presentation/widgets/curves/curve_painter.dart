import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:seed_color/core/utils/math_utils.dart';

/// 🌱 SeedColor — Curve Painter
///
/// CustomPainter untuk merender grid kurva, kurva spline halus (Catmull-Rom),
/// mock histogram di latar belakang, dan titik kontrol kurva.
class CurvePainter extends CustomPainter {
  final List<math.Point<double>> points;
  final String channel;
  final int? activePointIndex;

  CurvePainter({
    required this.points,
    required this.channel,
    this.activePointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawHistogramBackdrop(canvas, size);
    _drawGrid(canvas, size);
    _drawSplineCurve(canvas, size);
    _drawDashedGuideLines(canvas, size);
    _drawControlPoints(canvas, size);
  }

  /// Menggambar backdrop histogram tiruan (mock) demi estetika premium
  void _drawHistogramBackdrop(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height * 0.15),
        Offset(0, size.height),
        [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.01),
        ],
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // Membuat bentuk gunung histogram tiruan
    final width = size.width;
    final height = size.height;

    path.quadraticBezierTo(width * 0.15, height * 0.9, width * 0.3, height * 0.4);
    path.quadraticBezierTo(width * 0.45, height * 0.15, width * 0.6, height * 0.5);
    path.quadraticBezierTo(width * 0.75, height * 0.85, width * 0.9, height * 0.7);
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Menggambar grid panduan 4x4
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Pembagian 4 kolom (3 garis vertikal)
    for (int i = 1; i <= 3; i++) {
      final x = size.width * (i / 4);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Pembagian 4 baris (3 garis horizontal)
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Garis diagonal linier putus-putus sebagai referensi
    final dashedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), dashedPaint);
  }

  /// Menggambar kurva spline halus menggunakan Catmull-Rom LUT
  void _drawSplineCurve(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final lut = MathUtils.catmullRomSplineLut(points);
    final curveColor = _getChannelColor();

    final paint = Paint()
      ..color = curveColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    
    // Titik awal kurva (x=0)
    final double startY = size.height * (1.0 - lut[0]);
    path.moveTo(0, startY);

    // Iterasi 256 segmen LUT untuk membuat kurva spline yang mulus
    for (int i = 1; i < 256; i++) {
      final x = size.width * (i / 255.0);
      final y = size.height * (1.0 - lut[i]);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  /// Menggambar titik-titik kontrol lingkaran kurva
  void _drawControlPoints(Canvas canvas, Size size) {
    final activeColor = _getChannelColor();

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final cx = pt.x * size.width;
      final cy = (1.0 - pt.y) * size.height;
      final isLastOrFirst = i == 0 || i == points.length - 1;

      final bool isActive = activePointIndex == i;

      // Outer Glow untuk titik aktif
      if (isActive) {
        final glowPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx, cy), 12, glowPaint);
      }

      // Border luar putih
      final outerPaint = Paint()
        ..color = isLastOrFirst ? Colors.white70 : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), isActive ? 6 : 5, outerPaint);

      // Center solid berwarna sesuai channel aktif
      final innerPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), isActive ? 4 : 3, innerPaint);
    }
  }

  /// Menggambar garis panduan silang (crosshair) putus-putus untuk titik aktif
  void _drawDashedGuideLines(Canvas canvas, Size size) {
    if (activePointIndex == null || activePointIndex! >= points.length) return;

    final pt = points[activePointIndex!];
    final cx = pt.x * size.width;
    final cy = (1.0 - pt.y) * size.height;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double dashWidth = 4.0;
    const double dashSpace = 3.0;

    // Garis vertikal dari top ke bottom
    double y = 0.0;
    while (y < size.height) {
      final double endY = math.min(y + dashWidth, size.height);
      canvas.drawLine(Offset(cx, y), Offset(cx, endY), paint);
      y += dashWidth + dashSpace;
    }

    // Garis horizontal dari left ke right
    double x = 0.0;
    while (x < size.width) {
      final double endX = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, cy), Offset(endX, cy), paint);
      x += dashWidth + dashSpace;
    }
  }

  /// Mengembalikan warna saluran kurva aktif
  Color _getChannelColor() {
    switch (channel.toLowerCase()) {
      case 'red':
        return const Color(0xFFFF3B30);
      case 'green':
        return const Color(0xFF34C759);
      case 'blue':
        return const Color(0xFF007AFF);
      case 'rgb':
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant CurvePainter oldDelegate) {
    return oldDelegate.channel != channel ||
        oldDelegate.activePointIndex != activePointIndex ||
        oldDelegate.points != points;
  }
}
