import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🌱 SeedColor — Color Wheel Widget
///
/// Widget kustom untuk menggambar roda warna (chromatic wheel)
/// guna melakukan color grading pada saluran Shadows, Midtones, atau Highlights.
class ColorWheel extends StatefulWidget {
  final double hue;
  final double saturation;
  final ValueChanged<math.Point<double>> onChanged;
  final ValueChanged<math.Point<double>> onChangeEnd;
  final Color activeColor;

  const ColorWheel({
    super.key,
    required this.hue,
    required this.saturation,
    required this.onChanged,
    required this.onChangeEnd,
    required this.activeColor,
  });

  @override
  State<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel> {
  final GlobalKey _wheelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Chromatic Color Wheel ───────────────────────
        GestureDetector(
          key: _wheelKey,
          onPanStart: _handleGesture,
          onPanUpdate: _handleGesture,
          onPanEnd: (_) => widget.onChangeEnd(math.Point(widget.hue, widget.saturation)),
          onTapDown: (details) {
            _handleGesture(DragUpdateDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition,
            ));
            widget.onChangeEnd(math.Point(widget.hue, widget.saturation));
          },
          child: CustomPaint(
            size: const Size(130, 130),
            painter: _ColorWheelPainter(
              hue: widget.hue,
              saturation: widget.saturation,
              activeColor: widget.activeColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ─── Value Label ─────────────────────────────────
        Text(
          'H: ${widget.hue.round()}°  •  S: ${widget.saturation.round()}%',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  void _handleGesture(dynamic details) {
    final RenderBox? renderBox = _wheelKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = details.localPosition as Offset;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Hitung jarak relatif (dx, dy) dari pusat roda warna
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    // Hitung Saturation (0 s.d. 100) berdasarkan rasio jarak dari tepi
    final sat = (dist / radius).clamp(0.0, 1.0) * 100.0;

    // Hitung Hue (0 s.d. 360) berdasarkan sudut sentuhan (atan2)
    final angleRad = math.atan2(dy, dx);
    final angleDeg = (angleRad * 180 / math.pi + 360) % 360;

    widget.onChanged(math.Point(angleDeg, sat));
  }
}

/// CustomPainter untuk merender gradasi roda warna dan handle penggeser
class _ColorWheelPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final Color activeColor;

  _ColorWheelPainter({
    required this.hue,
    required this.saturation,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Gambar gradasi spektrum Hue (SweepGradient)
    final sweepPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFF3B30), // Red
          Color(0xFFFFCC00), // Yellow
          Color(0xFF34C759), // Green
          Color(0xFF00C7BE), // Teal
          Color(0xFF007AFF), // Blue
          Color(0xFFAF52DE), // Purple
          Color(0xFFFF3B30), // Red
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, sweepPaint);

    // 2. Overlay gradasi desaturasi ke arah pusat putih (RadialGradient)
    final radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, radialPaint);

    // 3. Gambar border lingkaran tipis
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, borderPaint);

    // 4. Hitung posisi handle koordinat berdasarkan Hue dan Saturation
    final angleRad = hue * math.pi / 180;
    final r = (saturation / 100.0) * radius;
    final hx = center.dx + r * math.cos(angleRad);
    final hy = center.dy + r * math.sin(angleRad);

    // 5. Gambar outer glow indicator handle
    final handleGlow = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(hx, hy), 7.5, handleGlow);

    // 6. Gambar handle visual (lingkaran putih solid dengan isian transparan di dalam)
    final handleOuter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(hx, hy), 5.5, handleOuter);

    final handleInner = Paint()
      ..color = saturation > 15 ? activeColor : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(hx, hy), 3.5, handleInner);
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return oldDelegate.hue != hue ||
        oldDelegate.saturation != saturation ||
        oldDelegate.activeColor != activeColor;
  }
}
