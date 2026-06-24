import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/mask_model.dart';

/// 🌱 SeedColor — Mask Overlay Painter
///
/// CustomPainter untuk menggambar garis panduan dan handle interaktif (control points)
/// di atas preview gambar untuk masker bertipe Linear Gradient dan Radial Gradient,
/// serta outline kursor sapuan untuk masker Brush.
class MaskOverlayPainter extends CustomPainter {
  final MaskModel? activeMask;
  final Offset? currentBrushPoint;
  final double? currentBrushRadius;

  MaskOverlayPainter({
    required this.activeMask,
    this.currentBrushPoint,
    this.currentBrushRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mask = activeMask;
    if (mask == null || !mask.isVisible) return;

    final paintLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintDash = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintDot = Paint()
      ..color = const Color(0xFF0A84FF)
      ..style = PaintingStyle.fill;

    final paintDotOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (mask.type == MaskType.linear && mask.linearStart != null && mask.linearEnd != null) {
      final start = Offset(mask.linearStart!.dx * size.width, mask.linearStart!.dy * size.height);
      final end = Offset(mask.linearEnd!.dx * size.width, mask.linearEnd!.dy * size.height);

      final direction = end - start;
      final length = direction.distance;

      if (length > 0) {
        final normal = Offset(-direction.dy / length, direction.dx / length);
        final lineHalfLength = math.max(size.width, size.height);

        // Garis batas luar start
        canvas.drawLine(
          start - normal * lineHalfLength,
          start + normal * lineHalfLength,
          paintLine,
        );

        // Garis batas luar end
        canvas.drawLine(
          end - normal * lineHalfLength,
          end + normal * lineHalfLength,
          paintLine,
        );

        // Garis tengah (titik tumpu transisi) - putus-putus
        final mid = (start + end) / 2;
        _drawDashedLine(
          canvas,
          mid - normal * lineHalfLength,
          mid + normal * lineHalfLength,
          paintDash,
        );

        // Garis penghubung arah gradien
        canvas.drawLine(start, end, paintDash);

        // Bulatan handle kontrol
        canvas.drawCircle(start, 7, paintDot);
        canvas.drawCircle(start, 7, paintDotOutline);

        canvas.drawCircle(end, 7, paintDot);
        canvas.drawCircle(end, 7, paintDotOutline);
      }
    } else if (mask.type == MaskType.radial && mask.radialCenter != null) {
      final center = Offset(mask.radialCenter!.dx * size.width, mask.radialCenter!.dy * size.height);
      final radX = mask.radialRadiusX * size.width;
      final radY = mask.radialRadiusY * size.height;
      final rot = mask.radialRotation;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rot);

      // Gambar elips pembatas
      final rect = Rect.fromCenter(center: Offset.zero, width: radX * 2, height: radY * 2);
      canvas.drawOval(rect, paintLine);

      // Sumbu simetri (putus-putus)
      canvas.drawLine(Offset(-radX, 0), Offset(radX, 0), paintDash);
      canvas.drawLine(Offset(0, -radY), Offset(0, radY), paintDash);

      // Bulatan handle kontrol tengah (posisi)
      canvas.drawCircle(Offset.zero, 7, paintDot);
      canvas.drawCircle(Offset.zero, 7, paintDotOutline);

      // Bulatan handle kontrol tepi (radius)
      canvas.drawCircle(Offset(radX, 0), 6, paintDot);
      canvas.drawCircle(Offset(radX, 0), 6, paintDotOutline);

      canvas.drawCircle(Offset(0, radY), 6, paintDot);
      canvas.drawCircle(Offset(0, radY), 6, paintDotOutline);

      canvas.restore();
    }

    // Menggambar lingkar batas kuas saat sedang melukis
    if (mask.type == MaskType.brush && currentBrushPoint != null && currentBrushRadius != null) {
      final pos = Offset(currentBrushPoint!.dx * size.width, currentBrushPoint!.dy * size.height);
      final radius = currentBrushRadius! * size.width;
      final paintBrushOutline = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(pos, radius, paintBrushOutline);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 8.0;
    const double dashSpace = 4.0;
    final double distance = (p2 - p1).distance;
    final Offset direction = (p2 - p1) / distance;
    double currentDistance = 0.0;
    while (currentDistance < distance) {
      final Offset start = p1 + direction * currentDistance;
      final double endDistance = math.min(currentDistance + dashWidth, distance);
      final Offset end = p1 + direction * endDistance;
      canvas.drawLine(start, end, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant MaskOverlayPainter oldDelegate) {
    return oldDelegate.activeMask != activeMask ||
        oldDelegate.currentBrushPoint != currentBrushPoint ||
        oldDelegate.currentBrushRadius != currentBrushRadius;
  }
}
