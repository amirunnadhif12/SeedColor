import 'package:flutter/material.dart';

/// 🌱 SeedColor — Crop Overlay Widget
///
/// Widget overlay interaktif untuk memotong gambar (Crop).
/// Menampilkan area terpilih, area redup (dimmed) di luar pilihan,
/// grid pembantu Rule of Thirds, dan handle sentuh di sudut serta tepi.
class CropOverlay extends StatefulWidget {
  final double cropLeft;
  final double cropTop;
  final double cropRight;
  final double cropBottom;
  final String aspectRatio; // 'Bebas', '1:1', '4:3', '16:9', '3:2'
  final void Function(double left, double top, double right, double bottom) onCropChanged;

  const CropOverlay({
    super.key,
    required this.cropLeft,
    required this.cropTop,
    required this.cropRight,
    required this.cropBottom,
    required this.aspectRatio,
    required this.onCropChanged,
  });

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  bool _isDragging = false;

  // Mendapatkan nilai rasio numerik
  double? get _ratioValue {
    switch (widget.aspectRatio) {
      case '1:1':
        return 1.0;
      case '4:3':
        return 4.0 / 3.0;
      case '16:9':
        return 16.0 / 9.0;
      case '3:2':
        return 3.0 / 2.0;
      default:
        return null; // Bebas
    }
  }

  void _updateCrop({
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double parentWidth,
    required double parentHeight,
  }) {
    double nLeft = (left ?? widget.cropLeft).clamp(0.0, widget.cropRight - 0.1);
    double nTop = (top ?? widget.cropTop).clamp(0.0, widget.cropBottom - 0.1);
    double nRight = (right ?? widget.cropRight).clamp(widget.cropLeft + 0.1, 1.0);
    double nBottom = (bottom ?? widget.cropBottom).clamp(widget.cropTop + 0.1, 1.0);

    final ratio = _ratioValue;
    if (ratio != null) {
      // Jika rasio aspek dikunci, kita harus menyesuaikan sisi lain
      double w = (nRight - nLeft) * parentWidth;
      double h = (nBottom - nTop) * parentHeight;

      if (left != null || right != null) {
        // Drag horizontal -> sesuaikan tinggi
        h = w / ratio;
        if (top != null) {
          nTop = nBottom - (h / parentHeight);
          if (nTop < 0.0) {
            nTop = 0.0;
            nRight = nLeft + (nBottom - nTop) * parentHeight * ratio / parentWidth;
          }
        } else {
          nBottom = nTop + (h / parentHeight);
          if (nBottom > 1.0) {
            nBottom = 1.0;
            nLeft = nRight - (nBottom - nTop) * parentHeight * ratio / parentWidth;
          }
        }
      } else if (top != null || bottom != null) {
        // Drag vertikal -> sesuaikan lebar
        w = h * ratio;
        if (left != null) {
          nLeft = nRight - (w / parentWidth);
          if (nLeft < 0.0) {
            nLeft = 0.0;
            nBottom = nTop + (nRight - nLeft) * parentWidth / ratio / parentHeight;
          }
        } else {
          nRight = nLeft + (w / parentWidth);
          if (nRight > 1.0) {
            nRight = 1.0;
            nTop = nBottom - (nRight - nLeft) * parentWidth / ratio / parentHeight;
          }
        }
      }
    }

    widget.onCropChanged(
      double.parse(nLeft.toStringAsFixed(4)),
      double.parse(nTop.toStringAsFixed(4)),
      double.parse(nRight.toStringAsFixed(4)),
      double.parse(nBottom.toStringAsFixed(4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double handleSize = 32.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final W = constraints.maxWidth;
        final H = constraints.maxHeight;

        final left = widget.cropLeft * W;
        final top = widget.cropTop * H;
        final right = widget.cropRight * W;
        final bottom = widget.cropBottom * H;
        final width = right - left;
        final height = bottom - top;

        return Stack(
          children: [
            // ─── BACKGROUND OVERLAY (DIMMED OUTSIDE CROP AREA) ───
            Positioned.fill(
              child: CustomPaint(
                painter: CropDimPainter(
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom,
                  showGrid: _isDragging,
                ),
              ),
            ),

            // ─── CORNER HANDLES ─────────────────────────────
            // Top Left
            Positioned(
              left: left - handleSize / 3,
              top: top - handleSize / 3,
              width: handleSize,
              height: handleSize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanEnd: (_) => setState(() => _isDragging = false),
                onPanCancel: () => setState(() => _isDragging = false),
                onPanUpdate: (details) {
                  final dx = details.delta.dx / W;
                  final dy = details.delta.dy / H;
                  _updateCrop(
                    left: widget.cropLeft + dx,
                    top: widget.cropTop + dy,
                    parentWidth: W,
                    parentHeight: H,
                  );
                },
                child: _buildCornerWidget(isTop: true, isLeft: true),
              ),
            ),
            // Top Right
            Positioned(
              left: right - handleSize * 2 / 3,
              top: top - handleSize / 3,
              width: handleSize,
              height: handleSize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanEnd: (_) => setState(() => _isDragging = false),
                onPanCancel: () => setState(() => _isDragging = false),
                onPanUpdate: (details) {
                  final dx = details.delta.dx / W;
                  final dy = details.delta.dy / H;
                  _updateCrop(
                    right: widget.cropRight + dx,
                    top: widget.cropTop + dy,
                    parentWidth: W,
                    parentHeight: H,
                  );
                },
                child: _buildCornerWidget(isTop: true, isLeft: false),
              ),
            ),
            // Bottom Left
            Positioned(
              left: left - handleSize / 3,
              top: bottom - handleSize * 2 / 3,
              width: handleSize,
              height: handleSize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanEnd: (_) => setState(() => _isDragging = false),
                onPanCancel: () => setState(() => _isDragging = false),
                onPanUpdate: (details) {
                  final dx = details.delta.dx / W;
                  final dy = details.delta.dy / H;
                  _updateCrop(
                    left: widget.cropLeft + dx,
                    bottom: widget.cropBottom + dy,
                    parentWidth: W,
                    parentHeight: H,
                  );
                },
                child: _buildCornerWidget(isTop: false, isLeft: true),
              ),
            ),
            // Bottom Right
            Positioned(
              left: right - handleSize * 2 / 3,
              top: bottom - handleSize * 2 / 3,
              width: handleSize,
              height: handleSize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanEnd: (_) => setState(() => _isDragging = false),
                onPanCancel: () => setState(() => _isDragging = false),
                onPanUpdate: (details) {
                  final dx = details.delta.dx / W;
                  final dy = details.delta.dy / H;
                  _updateCrop(
                    right: widget.cropRight + dx,
                    bottom: widget.cropBottom + dy,
                    parentWidth: W,
                    parentHeight: H,
                  );
                },
                child: _buildCornerWidget(isTop: false, isLeft: false),
              ),
            ),

            // ─── EDGE HANDLES ───────────────────────────────
            if (_ratioValue == null) ...[
              // Tepi Atas
              Positioned(
                left: left + handleSize,
                top: top - handleSize / 3,
                width: width - handleSize * 2,
                height: handleSize,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => setState(() => _isDragging = true),
                  onPanEnd: (_) => setState(() => _isDragging = false),
                  onPanCancel: () => setState(() => _isDragging = false),
                  onPanUpdate: (details) {
                    final dy = details.delta.dy / H;
                    _updateCrop(top: widget.cropTop + dy, parentWidth: W, parentHeight: H);
                  },
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Tepi Bawah
              Positioned(
                left: left + handleSize,
                top: bottom - handleSize * 2 / 3,
                width: width - handleSize * 2,
                height: handleSize,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => setState(() => _isDragging = true),
                  onPanEnd: (_) => setState(() => _isDragging = false),
                  onPanCancel: () => setState(() => _isDragging = false),
                  onPanUpdate: (details) {
                    final dy = details.delta.dy / H;
                    _updateCrop(bottom: widget.cropBottom + dy, parentWidth: W, parentHeight: H);
                  },
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Tepi Kiri
              Positioned(
                left: left - handleSize / 3,
                top: top + handleSize,
                width: handleSize,
                height: height - handleSize * 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => setState(() => _isDragging = true),
                  onPanEnd: (_) => setState(() => _isDragging = false),
                  onPanCancel: () => setState(() => _isDragging = false),
                  onPanUpdate: (details) {
                    final dx = details.delta.dx / W;
                    _updateCrop(left: widget.cropLeft + dx, parentWidth: W, parentHeight: H);
                  },
                  child: Center(
                    child: Container(
                      width: 2.5,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Tepi Kanan
              Positioned(
                left: right - handleSize * 2 / 3,
                top: top + handleSize,
                width: handleSize,
                height: height - handleSize * 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => setState(() => _isDragging = true),
                  onPanEnd: (_) => setState(() => _isDragging = false),
                  onPanCancel: () => setState(() => _isDragging = false),
                  onPanUpdate: (details) {
                    final dx = details.delta.dx / W;
                    _updateCrop(right: widget.cropRight + dx, parentWidth: W, parentHeight: H);
                  },
                  child: Center(
                    child: Container(
                      width: 2.5,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCornerWidget({required bool isTop, required bool isLeft}) {
    const double thickness = 3.5;
    const double length = 14.0;
    return Stack(
      children: [
        Positioned(
          top: isTop ? 0 : null,
          bottom: !isTop ? 0 : null,
          left: isLeft ? 0 : null,
          right: !isLeft ? 0 : null,
          width: length,
          height: thickness,
          child: Container(color: Colors.white),
        ),
        Positioned(
          top: isTop ? 0 : null,
          bottom: !isTop ? 0 : null,
          left: isLeft ? 0 : null,
          right: !isLeft ? 0 : null,
          width: thickness,
          height: length,
          child: Container(color: Colors.white),
        ),
      ],
    );
  }
}

/// CustomPainter untuk menggambar area luar kelabu dan grid Rule of Thirds
class CropDimPainter extends CustomPainter {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final bool showGrid;

  CropDimPainter({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);

    // Area Atas
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), dimPaint);
    // Area Bawah
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), dimPaint);
    // Area Kiri
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), dimPaint);
    // Area Kanan
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), dimPaint);

    // Garis batas (border) putih tipis untuk area potong
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), borderPaint);

    // Grid Rule of Thirds (hanya muncul saat pengguna menyeret handle)
    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      final w = right - left;
      final h = bottom - top;

      // Garis vertikal
      canvas.drawLine(Offset(left + w / 3, top), Offset(left + w / 3, bottom), gridPaint);
      canvas.drawLine(Offset(left + w * 2 / 3, top), Offset(left + w * 2 / 3, bottom), gridPaint);

      // Garis horizontal
      canvas.drawLine(Offset(left, top + h / 3), Offset(right, top + h / 3), gridPaint);
      canvas.drawLine(Offset(left, top + h * 2 / 3), Offset(right, top + h * 2 / 3), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CropDimPainter oldDelegate) {
    return oldDelegate.left != left ||
        oldDelegate.top != top ||
        oldDelegate.right != right ||
        oldDelegate.bottom != bottom ||
        oldDelegate.showGrid != showGrid;
  }
}
