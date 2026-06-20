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
  final ui.FragmentShader shader;
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
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 0. Set canvas size
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // 1. Light Adjustments (Exposure, Contrast, Highlights, Shadows, Whites, Blacks)
    shader.setFloat(2, exposure);
    shader.setFloat(3, contrast);
    shader.setFloat(4, highlights);
    shader.setFloat(5, shadows);
    shader.setFloat(6, whites);
    shader.setFloat(7, blacks);

    // 2. Color Adjustments (Temperature, Tint, Vibrance, Saturation)
    shader.setFloat(8, temperature);
    shader.setFloat(9, tint);
    shader.setFloat(10, vibrance);
    shader.setFloat(11, saturation);

    // HSL Mixer (24 floats, indexes 12 to 35)
    // Red (12-14)
    shader.setFloat(12, hslAdjustments.red.hue);
    shader.setFloat(13, hslAdjustments.red.saturation);
    shader.setFloat(14, hslAdjustments.red.lightness);
    // Orange (15-17)
    shader.setFloat(15, hslAdjustments.orange.hue);
    shader.setFloat(16, hslAdjustments.orange.saturation);
    shader.setFloat(17, hslAdjustments.orange.lightness);
    // Yellow (18-20)
    shader.setFloat(18, hslAdjustments.yellow.hue);
    shader.setFloat(19, hslAdjustments.yellow.saturation);
    shader.setFloat(20, hslAdjustments.yellow.lightness);
    // Green (21-23)
    shader.setFloat(21, hslAdjustments.green.hue);
    shader.setFloat(22, hslAdjustments.green.saturation);
    shader.setFloat(23, hslAdjustments.green.lightness);
    // Aqua (24-26)
    shader.setFloat(24, hslAdjustments.aqua.hue);
    shader.setFloat(25, hslAdjustments.aqua.saturation);
    shader.setFloat(26, hslAdjustments.aqua.lightness);
    // Blue (27-29)
    shader.setFloat(27, hslAdjustments.blue.hue);
    shader.setFloat(28, hslAdjustments.blue.saturation);
    shader.setFloat(29, hslAdjustments.blue.lightness);
    // Purple (30-32)
    shader.setFloat(30, hslAdjustments.purple.hue);
    shader.setFloat(31, hslAdjustments.purple.saturation);
    shader.setFloat(32, hslAdjustments.purple.lightness);
    // Magenta (33-35)
    shader.setFloat(33, hslAdjustments.magenta.hue);
    shader.setFloat(34, hslAdjustments.magenta.saturation);
    shader.setFloat(35, hslAdjustments.magenta.lightness);

    // 3. Effects (Texture, Clarity, Dehaze, Vignette, Grain)
    shader.setFloat(36, textureAdjust);
    shader.setFloat(37, clarity);
    shader.setFloat(38, dehaze);
    shader.setFloat(39, vignette);
    shader.setFloat(40, grain);

    // 4. Color Grading (ShadowsColor, MidtonesColor, HighlightsColor, Blending, Balance)
    // Shadows RGB tint (41, 42, 43)
    shader.setFloat(41, shadowsColor[0]);
    shader.setFloat(42, shadowsColor[1]);
    shader.setFloat(43, shadowsColor[2]);
    // Midtones RGB tint (44, 45, 46)
    shader.setFloat(44, midtonesColor[0]);
    shader.setFloat(45, midtonesColor[1]);
    shader.setFloat(46, midtonesColor[2]);
    // Highlights RGB tint (47, 48, 49)
    shader.setFloat(47, highlightsColor[0]);
    shader.setFloat(48, highlightsColor[1]);
    shader.setFloat(49, highlightsColor[2]);
    // Blending (50) - normalisasi 0-100 ke 0-1
    shader.setFloat(50, cgBlending / 100.0);
    // Balance (51) - normalisasi -100-100 ke -1.0-1.0
    shader.setFloat(51, cgBalance / 100.0);

    // 5. Detail & Optics (indexes 52 to 59)
    shader.setFloat(52, sharpeningAmount);
    shader.setFloat(53, sharpeningRadius);
    shader.setFloat(54, sharpeningDetail);
    shader.setFloat(55, sharpeningMasking);
    shader.setFloat(56, luminanceNR);
    shader.setFloat(57, colorNR);
    shader.setFloat(58, removeChromaticAberration ? 1.0 : 0.0);
    shader.setFloat(59, enableLensCorrection ? 1.0 : 0.0);

    // Bind Samplers
    shader.setImageSampler(0, image);
    shader.setImageSampler(1, lutImage);

    // Draw rect covering the size bounds with shader paint
    final paint = Paint()..shader = shader;
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
        oldDelegate.cgBlending != cgBlending ||
        oldDelegate.cgBalance != cgBalance ||
        oldDelegate.image != image ||
        oldDelegate.lutImage != lutImage;
  }
}
