import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/hsl_adjustments.dart';

/// 🌱 SeedColor — Image Canvas Widget
///
/// Widget khusus untuk merender gambar dengan akselerasi GPU (Fragment Shader)
/// di atas InteractiveViewer sehingga mendukung pinch-to-zoom dan pan.
class ImageCanvas extends StatelessWidget {
  final ui.Image image;
  final ui.Image lutImage;
  final ui.FragmentShader shader;

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

  // 3D LUT Support
  final ui.Image? custom3dLutImage;
  final double lutSize;
  final double lutIntensity;

  const ImageCanvas({
    super.key,
    required this.image,
    required this.lutImage,
    required this.shader,
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
    this.custom3dLutImage,
    this.lutSize = 0.0,
    this.lutIntensity = 1.0,
  });

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
              aspectRatio: image.width / image.height,
              child: CustomPaint(
                painter: ShaderPainter(
                  shader: shader,
                  image: image,
                  lutImage: lutImage,
                  exposure: exposure,
                  contrast: contrast,
                  highlights: highlights,
                  shadows: shadows,
                  whites: whites,
                  blacks: blacks,
                  temperature: temperature,
                  tint: tint,
                  vibrance: vibrance,
                  saturation: saturation,
                  hslAdjustments: hslAdjustments,
                  textureAdjust: textureAdjust,
                  clarity: clarity,
                  dehaze: dehaze,
                  vignette: vignette,
                  grain: grain,
                  sharpeningAmount: sharpeningAmount,
                  sharpeningRadius: sharpeningRadius,
                  sharpeningDetail: sharpeningDetail,
                  sharpeningMasking: sharpeningMasking,
                  luminanceNR: luminanceNR,
                  colorNR: colorNR,
                  removeChromaticAberration: removeChromaticAberration,
                  enableLensCorrection: enableLensCorrection,
                  shadowsColor: shadowsColor,
                  midtonesColor: midtonesColor,
                  highlightsColor: highlightsColor,
                  cgBlending: cgBlending,
                  cgBalance: cgBalance,
                  custom3dLutImage: custom3dLutImage,
                  lutSize: lutSize,
                  lutIntensity: lutIntensity,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk merender shader pada kanvas
class ShaderPainter extends CustomPainter {
  final ui.FragmentShader? shader;
  final ui.Image image;
  final ui.Image lutImage;

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

  final List<double> shadowsColor;
  final List<double> midtonesColor;
  final List<double> highlightsColor;
  final double cgBlending;
  final double cgBalance;

  // 3D LUT Support
  final ui.Image? custom3dLutImage;
  final double lutSize;
  final double lutIntensity;

  ShaderPainter({
    required this.shader,
    required this.image,
    required this.lutImage,
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
    this.custom3dLutImage,
    this.lutSize = 0.0,
    this.lutIntensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = shader;
    if (s == null) {
      try {
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint(),
        );
      } catch (e) {
        // Fallback for tests where FakeImage cannot be painted natively
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = const Color(0xFF2E2E2E),
        );
      }
      return;
    }
    // 0. Set canvas size
    s.setFloat(0, size.width);
    s.setFloat(1, size.height);

    // 1. Light Adjustments (Exposure, Contrast, Highlights, Shadows, Whites, Blacks)
    s.setFloat(2, exposure);
    s.setFloat(3, contrast);
    s.setFloat(4, highlights);
    s.setFloat(5, shadows);
    s.setFloat(6, whites);
    s.setFloat(7, blacks);

    // 2. Color Adjustments (Temperature, Tint, Vibrance, Saturation)
    s.setFloat(8, temperature);
    s.setFloat(9, tint);
    s.setFloat(10, vibrance);
    s.setFloat(11, saturation);

    // HSL Mixer (24 floats, indexes 12 to 35)
    // Red (12-14)
    s.setFloat(12, hslAdjustments.red.hue);
    s.setFloat(13, hslAdjustments.red.saturation);
    s.setFloat(14, hslAdjustments.red.lightness);
    // Orange (15-17)
    s.setFloat(15, hslAdjustments.orange.hue);
    s.setFloat(16, hslAdjustments.orange.saturation);
    s.setFloat(17, hslAdjustments.orange.lightness);
    // Yellow (18-20)
    s.setFloat(18, hslAdjustments.yellow.hue);
    s.setFloat(19, hslAdjustments.yellow.saturation);
    s.setFloat(20, hslAdjustments.yellow.lightness);
    // Green (21-23)
    s.setFloat(21, hslAdjustments.green.hue);
    s.setFloat(22, hslAdjustments.green.saturation);
    s.setFloat(23, hslAdjustments.green.lightness);
    // Aqua (24-26)
    s.setFloat(24, hslAdjustments.aqua.hue);
    s.setFloat(25, hslAdjustments.aqua.saturation);
    s.setFloat(26, hslAdjustments.aqua.lightness);
    // Blue (27-29)
    s.setFloat(27, hslAdjustments.blue.hue);
    s.setFloat(28, hslAdjustments.blue.saturation);
    s.setFloat(29, hslAdjustments.blue.lightness);
    // Purple (30-32)
    s.setFloat(30, hslAdjustments.purple.hue);
    s.setFloat(31, hslAdjustments.purple.saturation);
    s.setFloat(32, hslAdjustments.purple.lightness);
    // Magenta (33-35)
    s.setFloat(33, hslAdjustments.magenta.hue);
    s.setFloat(34, hslAdjustments.magenta.saturation);
    s.setFloat(35, hslAdjustments.magenta.lightness);

    // 3. Effects (Texture, Clarity, Dehaze, Vignette, Grain)
    s.setFloat(36, textureAdjust);
    s.setFloat(37, clarity);
    s.setFloat(38, dehaze);
    s.setFloat(39, vignette);
    s.setFloat(40, grain);

    // 4. Color Grading (ShadowsColor, MidtonesColor, HighlightsColor, Blending, Balance)
    // Shadows RGB tint (41, 42, 43)
    s.setFloat(41, shadowsColor[0]);
    s.setFloat(42, shadowsColor[1]);
    s.setFloat(43, shadowsColor[2]);
    // Midtones RGB tint (44, 45, 46)
    s.setFloat(44, midtonesColor[0]);
    s.setFloat(45, midtonesColor[1]);
    s.setFloat(46, midtonesColor[2]);
    // Highlights RGB tint (47, 48, 49)
    s.setFloat(47, highlightsColor[0]);
    s.setFloat(48, highlightsColor[1]);
    s.setFloat(49, highlightsColor[2]);
    // Blending (50) - normalisasi 0-100 ke 0-1
    s.setFloat(50, cgBlending / 100.0);
    // Balance (51) - normalisasi -100-100 ke -1.0-1.0
    s.setFloat(51, cgBalance / 100.0);

    // 5. Detail & Optics (indexes 52 to 59)
    s.setFloat(52, sharpeningAmount);
    s.setFloat(53, sharpeningRadius);
    s.setFloat(54, sharpeningDetail);
    s.setFloat(55, sharpeningMasking);
    s.setFloat(56, luminanceNR);
    s.setFloat(57, colorNR);
    s.setFloat(58, removeChromaticAberration ? 1.0 : 0.0);
    s.setFloat(59, enableLensCorrection ? 1.0 : 0.0);
    s.setFloat(60, lutSize);
    s.setFloat(61, lutIntensity);

    // Bind Samplers
    s.setImageSampler(0, image);
    s.setImageSampler(1, lutImage);
    s.setImageSampler(2, custom3dLutImage ?? lutImage);

    // Draw rect covering the size bounds with shader paint
    final paint = Paint()..shader = s;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) {
    return oldDelegate.exposure != exposure ||
        oldDelegate.contrast != contrast ||
        oldDelegate.highlights != highlights ||
        oldDelegate.shadows != shadows ||
        oldDelegate.whites != whites ||
        oldDelegate.blacks != blacks ||
        oldDelegate.temperature != temperature ||
        oldDelegate.tint != tint ||
        oldDelegate.vibrance != vibrance ||
        oldDelegate.saturation != saturation ||
        oldDelegate.hslAdjustments != hslAdjustments ||
        oldDelegate.textureAdjust != textureAdjust ||
        oldDelegate.clarity != clarity ||
        oldDelegate.dehaze != dehaze ||
        oldDelegate.vignette != vignette ||
        oldDelegate.grain != grain ||
        oldDelegate.sharpeningAmount != sharpeningAmount ||
        oldDelegate.sharpeningRadius != sharpeningRadius ||
        oldDelegate.sharpeningDetail != sharpeningDetail ||
        oldDelegate.sharpeningMasking != sharpeningMasking ||
        oldDelegate.luminanceNR != luminanceNR ||
        oldDelegate.colorNR != colorNR ||
        oldDelegate.removeChromaticAberration != removeChromaticAberration ||
        oldDelegate.enableLensCorrection != enableLensCorrection ||
        oldDelegate.shadowsColor != shadowsColor ||
        oldDelegate.midtonesColor != midtonesColor ||
        oldDelegate.highlightsColor != highlightsColor ||
        oldDelegate.cgBalance != cgBalance ||
        oldDelegate.lutSize != lutSize ||
        oldDelegate.lutIntensity != lutIntensity ||
        oldDelegate.custom3dLutImage != custom3dLutImage ||
        oldDelegate.image != image ||
        oldDelegate.lutImage != lutImage;
  }
}
