import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/hsl_adjustments.dart';
import 'image_canvas.dart';

/// 🌱 SeedColor — Compare Canvas Widget
///
/// Widget khusus untuk merender perbandingan "Sebelum vs Sesudah" secara interaktif
/// menggunakan swipe slider pada panel pratinjau gambar.
class CompareCanvas extends StatefulWidget {
  final ui.Image image;
  final ui.Image lutImage;
  final ui.Image identityLutImage;
  final ui.FragmentShader? shader;
  final double dragRatio;
  final ValueChanged<double> onDragUpdate;

  // Current parameters (After)
  final double exposure;
  final double contrast;
  final double highlights;
  final double shadows;
  final double whites;
  final double blacks;

  final double temperature;
  final double tint;
  final double vibrance;
  final double saturation;

  final HslAdjustments hslAdjustments;

  final double textureAdjust;
  final double clarity;
  final double dehaze;
  final double vignette;
  final double grain;

  // Detail Panel
  final double sharpeningAmount;
  final double sharpeningRadius;
  final double sharpeningDetail;
  final double sharpeningMasking;
  final double luminanceNR;
  final double colorNR;

  // Optics Panel
  final bool removeChromaticAberration;
  final bool enableLensCorrection;

  // Color Grading
  final List<double> shadowsColor;
  final List<double> midtonesColor;
  final List<double> highlightsColor;
  final double cgBlending;
  final double cgBalance;

  const CompareCanvas({
    super.key,
    required this.image,
    required this.lutImage,
    required this.identityLutImage,
    required this.shader,
    required this.dragRatio,
    required this.onDragUpdate,
    required this.exposure,
    required this.contrast,
    required this.highlights,
    required this.shadows,
    required this.whites,
    required this.blacks,
    required this.temperature,
    required this.tint,
    required this.vibrance,
    required this.saturation,
    required this.hslAdjustments,
    required this.textureAdjust,
    required this.clarity,
    required this.dehaze,
    required this.vignette,
    required this.grain,
    required this.sharpeningAmount,
    required this.sharpeningRadius,
    required this.sharpeningDetail,
    required this.sharpeningMasking,
    required this.luminanceNR,
    required this.colorNR,
    required this.removeChromaticAberration,
    required this.enableLensCorrection,
    required this.shadowsColor,
    required this.midtonesColor,
    required this.highlightsColor,
    required this.cgBlending,
    required this.cgBalance,
  });

  @override
  State<CompareCanvas> createState() => _CompareCanvasState();
}

class _CompareCanvasState extends State<CompareCanvas> {
  bool _showLabels = true;
  Timer? _labelTimer;

  @override
  void initState() {
    super.initState();
    _resetLabelTimer(show: true);
  }

  @override
  void dispose() {
    _labelTimer?.cancel();
    super.dispose();
  }

  void _resetLabelTimer({required bool show}) {
    _labelTimer?.cancel();
    if (show) {
      setState(() {
        _showLabels = true;
      });
    }
    _labelTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showLabels = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundPanel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          maxScale: 4.0,
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.image.width / widget.image.height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final sliderX = width * widget.dragRatio;

                  return Stack(
                    children: [
                      // 1. Gambar Sesudah (After) — Dirender penuh di latar belakang
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ShaderPainter(
                            shader: widget.shader,
                            image: widget.image,
                            lutImage: widget.lutImage,
                            exposure: widget.exposure,
                            contrast: widget.contrast,
                            highlights: widget.highlights,
                            shadows: widget.shadows,
                            whites: widget.whites,
                            blacks: widget.blacks,
                            temperature: widget.temperature,
                            tint: widget.tint,
                            vibrance: widget.vibrance,
                            saturation: widget.saturation,
                            hslAdjustments: widget.hslAdjustments,
                            textureAdjust: widget.textureAdjust,
                            clarity: widget.clarity,
                            dehaze: widget.dehaze,
                            vignette: widget.vignette,
                            grain: widget.grain,
                            sharpeningAmount: widget.sharpeningAmount,
                            sharpeningRadius: widget.sharpeningRadius,
                            sharpeningDetail: widget.sharpeningDetail,
                            sharpeningMasking: widget.sharpeningMasking,
                            luminanceNR: widget.luminanceNR,
                            colorNR: widget.colorNR,
                            removeChromaticAberration: widget.removeChromaticAberration,
                            enableLensCorrection: widget.enableLensCorrection,
                            shadowsColor: widget.shadowsColor,
                            midtonesColor: widget.midtonesColor,
                            highlightsColor: widget.highlightsColor,
                            cgBlending: widget.cgBlending,
                            cgBalance: widget.cgBalance,
                          ),
                        ),
                      ),

                      // 2. Gambar Sebelum (Before) — Dirender di atas dan dipotong (clipped)
                      Positioned.fill(
                        child: ClipRect(
                          clipper: BeforeClipper(widget.dragRatio),
                          child: CustomPaint(
                            painter: ShaderPainter(
                              shader: widget.shader,
                              image: widget.image,
                              lutImage: widget.identityLutImage,
                              exposure: 0.0,
                              contrast: 0.0,
                              highlights: 0.0,
                              shadows: 0.0,
                              whites: 0.0,
                              blacks: 0.0,
                              temperature: 0.0,
                              tint: 0.0,
                              vibrance: 0.0,
                              saturation: 0.0,
                              hslAdjustments: const HslAdjustments(),
                              textureAdjust: 0.0,
                              clarity: 0.0,
                              dehaze: 0.0,
                              vignette: 0.0,
                              grain: 0.0,
                              sharpeningAmount: 40.0,
                              sharpeningRadius: 1.0,
                              sharpeningDetail: 25.0,
                              sharpeningMasking: 0.0,
                              luminanceNR: 0.0,
                              colorNR: 25.0,
                              removeChromaticAberration: false,
                              enableLensCorrection: false,
                              shadowsColor: const [0.0, 0.0, 0.0],
                              midtonesColor: const [0.0, 0.0, 0.0],
                              highlightsColor: const [0.0, 0.0, 0.0],
                              cgBlending: 50.0,
                              cgBalance: 0.0,
                            ),
                          ),
                        ),
                      ),

                      // 3. Garis Pembagi Vertikal & Tombol Geser (Slider Handle)
                      Positioned(
                        left: sliderX - 25,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragStart: (_) => _resetLabelTimer(show: true),
                          onHorizontalDragUpdate: (details) {
                            _resetLabelTimer(show: true);
                            final newRatio = (sliderX + details.delta.dx) / width;
                            widget.onDragUpdate(newRatio.clamp(0.0, 1.0));
                          },
                          onHorizontalDragEnd: (_) => _resetLabelTimer(show: false),
                          child: SizedBox(
                            width: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Garis Putih Vertikal dengan Bayangan
                                Container(
                                  width: 2,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                // Knob Bulat Pembanding
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E2E),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.swap_horiz_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 4. Overlay Label "SEBELUM" & "SESUDAH"
                      Positioned(
                        left: 12,
                        top: 12,
                        child: AnimatedOpacity(
                          opacity: _showLabels ? 0.7 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SEBELUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: AnimatedOpacity(
                          opacity: _showLabels ? 0.7 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SESUDAH',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clipper khusus untuk memotong sisi kiri gambar (Menampilkan Sebelum)
class BeforeClipper extends CustomClipper<Rect> {
  final double ratio;

  BeforeClipper(this.ratio);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * ratio, size.height);
  }

  @override
  bool shouldReclip(BeforeClipper oldClipper) => oldClipper.ratio != ratio;
}
