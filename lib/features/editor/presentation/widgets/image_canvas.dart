import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

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

  final double textureAdjust;
  final double clarity;
  final double dehaze;
  final double vignette;
  final double grain;

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
    required this.textureAdjust,
    required this.clarity,
    required this.dehaze,
    required this.vignette,
    required this.grain,
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
                  textureAdjust: textureAdjust,
                  clarity: clarity,
                  dehaze: dehaze,
                  vignette: vignette,
                  grain: grain,
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

  final double textureAdjust;
  final double clarity;
  final double dehaze;
  final double vignette;
  final double grain;

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
    required this.textureAdjust,
    required this.clarity,
    required this.dehaze,
    required this.vignette,
    required this.grain,
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

    // HSL (24 floats, indexes 12 to 35) -> Pass 0.0
    for (int i = 12; i < 36; i++) {
      shader.setFloat(i, 0.0);
    }

    // 3. Effects (Texture, Clarity, Dehaze, Vignette, Grain)
    shader.setFloat(36, textureAdjust);
    shader.setFloat(37, clarity);
    shader.setFloat(38, dehaze);
    shader.setFloat(39, vignette);
    shader.setFloat(40, grain);

    // 4. Color Grading (ShadowsColor, MidtonesColor, HighlightsColor, Blending, Balance)
    // Shadows RGB tint (41, 42, 43)
    shader.setFloat(41, 0.0);
    shader.setFloat(42, 0.0);
    shader.setFloat(43, 0.0);
    // Midtones RGB tint (44, 45, 46)
    shader.setFloat(44, 0.0);
    shader.setFloat(45, 0.0);
    shader.setFloat(46, 0.0);
    // Highlights RGB tint (47, 48, 49)
    shader.setFloat(47, 0.0);
    shader.setFloat(48, 0.0);
    shader.setFloat(49, 0.0);
    // Blending (50)
    shader.setFloat(50, 0.5);
    // Balance (51)
    shader.setFloat(51, 0.0);

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
        oldDelegate.textureAdjust != textureAdjust ||
        oldDelegate.clarity != clarity ||
        oldDelegate.dehaze != dehaze ||
        oldDelegate.vignette != vignette ||
        oldDelegate.grain != grain ||
        oldDelegate.image != image ||
        oldDelegate.lutImage != lutImage;
  }
}
