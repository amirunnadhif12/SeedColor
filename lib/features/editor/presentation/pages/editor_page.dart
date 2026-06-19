import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/seed_slider.dart';

/// 🌱 SeedColor — Halaman Editor
///
/// Halaman utama untuk mengedit foto dengan akselerasi GPU (Shader).
/// Layout: Full-screen image preview + Bottom tool panel
/// Lightroom-style sliders (label + slider + value)
class EditorPage extends StatefulWidget {
  final String photoId;

  const EditorPage({super.key, required this.photoId});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage>
    with SingleTickerProviderStateMixin {
  int _selectedToolIndex = 0;
  
  // Resources for shader preview
  ui.Image? _testImage;
  ui.Image? _lutImage;
  ui.FragmentShader? _shader;
  bool _isLoading = true;

  final List<_ToolItem> _tools = [
    _ToolItem(Icons.wb_sunny_rounded, 'Light', AppColors.toolLight),
    _ToolItem(Icons.palette_rounded, 'Color', AppColors.toolColor),
    _ToolItem(Icons.auto_awesome_rounded, 'Effects', AppColors.toolEffects),
    _ToolItem(Icons.details_rounded, 'Detail', AppColors.toolDetail),
    _ToolItem(Icons.crop_rounded, 'Geometry', AppColors.toolGeometry),
    _ToolItem(Icons.layers_rounded, 'Masking', AppColors.toolMasking),
  ];

  // ─── Light Panel Sliders ─────────────────────────────
  final Map<String, double> _lightValues = {
    'Exposure': 0.0,
    'Contrast': 0.0,
    'Highlights': 0.0,
    'Shadows': 0.0,
    'Whites': 0.0,
    'Blacks': 0.0,
  };

  // ─── Color Panel Sliders ─────────────────────────────
  final Map<String, double> _colorValues = {
    'Temperature': 0.0,
    'Tint': 0.0,
    'Vibrance': 0.0,
    'Saturation': 0.0,
  };

  // ─── Effects Panel Sliders ───────────────────────────
  final Map<String, double> _effectsValues = {
    'Texture': 0.0,
    'Clarity': 0.0,
    'Dehaze': 0.0,
    'Vignette': 0.0,
    'Grain': 0.0,
  };

  // ─── Detail Panel Sliders ────────────────────────────
  final Map<String, double> _detailValues = {
    'Sharpening': 40,
    'Radius': 1,
    'Detail': 25,
    'Masking': 0,
    'Luminance NR': 0,
    'Color NR': 25,
  };

  Map<String, double> get _currentValues {
    switch (_selectedToolIndex) {
      case 0:
        return _lightValues;
      case 1:
        return _colorValues;
      case 2:
        return _effectsValues;
      case 3:
        return _detailValues;
      default:
        return _lightValues;
    }
  }

  String get _currentToolLabel => _tools[_selectedToolIndex].label;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      // 1. Load image (img/LOGO.png)
      final ByteData data = await rootBundle.load('img/LOGO.png');
      final Uint8List list = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo fi = await codec.getNextFrame();
      _testImage = fi.image;

      // 2. Create identity LUT
      _lutImage = await _createIdentityLut();

      // 3. Load shader (composite.frag)
      final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
        'lib/shaders/composite.frag',
      );
      _shader = program.fragmentShader();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading resources: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ui.Image> _createIdentityLut() async {
    final completer = Completer<ui.Image>();
    final bytes = Uint8List(256 * 4);
    for (int i = 0; i < 256; i++) {
      bytes[i * 4 + 0] = i; // R
      bytes[i * 4 + 1] = i; // G
      bytes[i * 4 + 2] = i; // B
      bytes[i * 4 + 3] = i; // A (RGB Curve)
    }
    ui.decodeImageFromPixels(
      bytes,
      256,
      1,
      ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ──────────────────────────────────
            _buildTopBar(),

            // ─── Image Preview ────────────────────────────
            Expanded(child: _buildImagePreview()),

            // ─── Panel Header ─────────────────────────────
            _buildPanelHeader(),

            // ─── Adjustment Sliders ───────────────────────
            _buildAdjustmentSliders(),

            // ─── Tool Selector Bar ────────────────────────
            _buildToolSelector(),
          ],
        ),
      ),
    );
  }

  /// Top bar dengan back, undo, redo, share
  Widget _buildTopBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Kembali',
          ),
          const Spacer(),

          // Undo
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: AppColors.textTertiary,
            onPressed: () {},
            tooltip: 'Urungkan',
          ),

          // Redo
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            color: AppColors.textTertiary,
            onPressed: () {},
            tooltip: 'Ulangi',
          ),

          // Share / Export
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'Ekspor',
          ),
        ],
      ),
    );
  }

  /// Full-bleed image preview dengan rendering shader real-time
  Widget _buildImagePreview() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_shader == null || _testImage == null || _lutImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat mesin shader atau gambar',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

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
              aspectRatio: _testImage!.width / _testImage!.height,
              child: CustomPaint(
                painter: ShaderPainter(
                  shader: _shader!,
                  image: _testImage!,
                  lutImage: _lutImage!,
                  exposure: _lightValues['Exposure'] ?? 0.0,
                  contrast: _lightValues['Contrast'] ?? 0.0,
                  highlights: _lightValues['Highlights'] ?? 0.0,
                  shadows: _lightValues['Shadows'] ?? 0.0,
                  whites: _lightValues['Whites'] ?? 0.0,
                  blacks: _lightValues['Blacks'] ?? 0.0,
                  temperature: _colorValues['Temperature'] ?? 0.0,
                  tint: _colorValues['Tint'] ?? 0.0,
                  vibrance: _colorValues['Vibrance'] ?? 0.0,
                  saturation: _colorValues['Saturation'] ?? 0.0,
                  textureAdjust: _effectsValues['Texture'] ?? 0.0,
                  clarity: _effectsValues['Clarity'] ?? 0.0,
                  dehaze: _effectsValues['Dehaze'] ?? 0.0,
                  vignette: _effectsValues['Vignette'] ?? 0.0,
                  grain: _effectsValues['Grain'] ?? 0.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Panel header: Tool name + Curve toggle
  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Text(
            _currentToolLabel.toUpperCase(),
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          if (_selectedToolIndex == 0) ...[
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Curve',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Lightroom-style adjustment sliders
  Widget _buildAdjustmentSliders() {
    final values = _currentValues;

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        physics: const BouncingScrollPhysics(),
        children: values.entries.map((entry) {
          return SeedSlider(
            label: entry.key,
            value: entry.value,
            min: entry.key == 'Exposure' ? -5.0 : -100.0,
            max: entry.key == 'Exposure' ? 5.0 : 100.0,
            onChanged: (val) {
              setState(() {
                _currentValues[entry.key] = val;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  /// Bottom tool selector bar
  Widget _buildToolSelector() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.backgroundPanel,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_tools.length, (index) {
          final tool = _tools[index];
          final isSelected = index == _selectedToolIndex;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedToolIndex = index);
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      tool.icon,
                      size: 20,
                      color:
                          isSelected ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.label,
                    style: AppTypography.toolLabel.copyWith(
                      color:
                          isSelected ? AppColors.primary : AppColors.textTertiary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Model data untuk tool item
class _ToolItem {
  final IconData icon;
  final String label;
  final Color color;

  const _ToolItem(this.icon, this.label, this.color);
}

/// CustomPainter untuk menggambar gambar uji menggunakan FragmentShader
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
