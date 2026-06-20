import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/features/editor/domain/entities/curve_data.dart';
import 'package:seed_color/features/editor/presentation/widgets/curves/curve_painter.dart';
import 'package:seed_color/features/editor/presentation/widgets/curves/curve_control_point.dart';

/// 🌱 SeedColor — Curves Panel
///
/// Panel kontrol Curves yang memungkinkan pengguna berpindah saluran warna
/// (RGB, Red, Green, Blue) dan mengedit kurva secara interaktif dengan gestur sentuh.
class CurvesPanel extends StatefulWidget {
  final CurveData curveData;
  final void Function(CurveData curveData) onChanged;
  final void Function(String channel, List<math.Point<double>> points) onChangeEnd;
  final VoidCallback onDonePressed;

  const CurvesPanel({
    super.key,
    required this.curveData,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onDonePressed,
  });

  @override
  State<CurvesPanel> createState() => _CurvesPanelState();
}

class _CurvesPanelState extends State<CurvesPanel> {
  String _activeChannel = 'rgb';
  int? _activePointIndex;
  final GlobalKey _paintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final points = widget.curveData.getChannelPoints(_activeChannel);

    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          // ─── Header & Channel Selector ────────────────────
          Row(
            children: [
              // Tab Selector Saluran Warna (RGB, R, G, B)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildChannelCircle('rgb', Colors.white),
                  const SizedBox(width: 8),
                  _buildChannelCircle('red', const Color(0xFFFF3B30)),
                  const SizedBox(width: 8),
                  _buildChannelCircle('green', const Color(0xFF34C759)),
                  const SizedBox(width: 8),
                  _buildChannelCircle('blue', const Color(0xFF007AFF)),
                ],
              ),
              const Spacer(),
              // Reset button
              GestureDetector(
                onTap: () {
                  final resetCurveData = widget.curveData.resetChannel(_activeChannel);
                  widget.onChanged(resetCurveData);
                  widget.onChangeEnd(
                    _activeChannel,
                    resetCurveData.getChannelPoints(_activeChannel),
                  );
                  setState(() {
                    _activePointIndex = null;
                  });
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Done button
              GestureDetector(
                onTap: widget.onDonePressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141522),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Info Row: Koordinat Input/Output & Hapus button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _activePointIndex != null && _activePointIndex! < points.length
                      ? 'Input: ${(points[_activePointIndex!].x * 255).round()}   Output: ${(points[_activePointIndex!].y * 255).round()}'
                      : 'Geser titik untuk mengedit  •  Tahan untuk hapus',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                if (_activePointIndex != null &&
                    _activePointIndex! > 0 &&
                    _activePointIndex! < points.length - 1)
                  GestureDetector(
                    onTap: () {
                      final updatedCurveData =
                          widget.curveData.removePoint(_activeChannel, _activePointIndex!);
                      widget.onChanged(updatedCurveData);
                      widget.onChangeEnd(
                        _activeChannel,
                        updatedCurveData.getChannelPoints(_activeChannel),
                      );
                      setState(() {
                        _activePointIndex = null;
                      });
                    },
                    child: Text(
                      'Hapus Titik',
                      style: TextStyle(
                        color: CurveControlPointStyle.getChannelColor(_activeChannel)
                            .withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ─── Interactive Curve Grid ──────────────────────
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF101016),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      key: _paintKey,
                      onPanStart: (details) => _handlePanStart(details, points),
                      onPanUpdate: (details) => _handlePanUpdate(details, points),
                      onPanEnd: _handlePanEnd,
                      onLongPressStart: (details) => _handleLongPress(details, points),
                      child: CustomPaint(
                        painter: CurvePainter(
                          points: points,
                          channel: _activeChannel,
                          activePointIndex: _activePointIndex,
                        ),
                      ),
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

  /// Membuat tombol lingkaran selector saluran warna (Lightroom-style)
  Widget _buildChannelCircle(String channel, Color color) {
    final isSelected = _activeChannel == channel;

    // RGB menggunakan warna putih, tetapi jika tidak terpilih tampilkan abu-abu
    final circleColor = channel == 'rgb'
        ? (isSelected ? Colors.white : Colors.white54)
        : (isSelected ? color : color.withValues(alpha: 0.5));

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeChannel = channel;
          _activePointIndex = null;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? circleColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: circleColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  // ─── Gesture Handlers ────────────────────────────────────

  void _handlePanStart(DragStartDetails details, List<math.Point<double>> points) {
    final RenderBox? renderBox = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = details.localPosition;
    final size = renderBox.size;

    // Normalisasikan koordinat sentuh (0.0 s.d. 1.0)
    final normX = (localPos.dx / size.width).clamp(0.0, 1.0);
    final normY = (1.0 - (localPos.dy / size.height)).clamp(0.0, 1.0);

    // 1. Deteksi apakah jari menyentuh titik kontrol yang sudah ada
    int? foundIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final dx = (pt.x - normX) * size.width;
      final dy = (pt.y - normY) * size.height;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < CurveControlPointStyle.touchRadius) {
        if (distance < minDistance) {
          minDistance = distance;
          foundIndex = i;
        }
      }
    }

    if (foundIndex != null) {
      // Kunci titik tersebut untuk di-drag
      setState(() {
        _activePointIndex = foundIndex;
      });
    } else {
      // 2. Jika menyentuh area kosong, buat titik kontrol baru
      final newPoint = math.Point(normX, normY);
      final newCurveData = widget.curveData.addPoint(_activeChannel, newPoint);

      // Cari indeks titik yang baru ditambahkan
      final newPoints = newCurveData.getChannelPoints(_activeChannel);
      final newIndex = newPoints.indexWhere((p) => p.x == normX && p.y == normY);

      if (newIndex != -1) {
        setState(() {
          _activePointIndex = newIndex;
        });
        widget.onChanged(newCurveData);
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, List<math.Point<double>> points) {
    if (_activePointIndex == null) return;

    final RenderBox? renderBox = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = details.localPosition;
    final size = renderBox.size;

    final normX = (localPos.dx / size.width).clamp(0.0, 1.0);
    final normY = (1.0 - (localPos.dy / size.height)).clamp(0.0, 1.0);

    final updatedCurveData = widget.curveData.updatePoint(
      _activeChannel,
      _activePointIndex!,
      math.Point(normX, normY),
    );

    widget.onChanged(updatedCurveData);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_activePointIndex != null) {
      final pts = widget.curveData.getChannelPoints(_activeChannel);
      widget.onChangeEnd(_activeChannel, pts);
      setState(() {
        _activePointIndex = null;
      });
    }
  }

  void _handleLongPress(LongPressStartDetails details, List<math.Point<double>> points) {
    final RenderBox? renderBox = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = details.localPosition;
    final size = renderBox.size;

    final normX = (localPos.dx / size.width).clamp(0.0, 1.0);
    final normY = (1.0 - (localPos.dy / size.height)).clamp(0.0, 1.0);

    // Cari titik terdekat
    int? foundIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final dx = (pt.x - normX) * size.width;
      final dy = (pt.y - normY) * size.height;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < CurveControlPointStyle.touchRadius) {
        if (distance < minDistance) {
          minDistance = distance;
          foundIndex = i;
        }
      }
    }

    // Jika ketemu dan bukan merupakan endpoints (index 0 atau ujung akhir), hapus titik tersebut
    if (foundIndex != null && foundIndex > 0 && foundIndex < points.length - 1) {
      final updatedCurveData = widget.curveData.removePoint(_activeChannel, foundIndex);
      final newPoints = updatedCurveData.getChannelPoints(_activeChannel);
      widget.onChanged(updatedCurveData);
      widget.onChangeEnd(_activeChannel, newPoints);
      setState(() {
        _activePointIndex = null;
      });
    }
  }
}
