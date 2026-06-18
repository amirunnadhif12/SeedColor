import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// 🌱 SeedColor — Halaman Editor
///
/// Halaman utama untuk mengedit foto.
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
    'Exposure': 0.35,
    'Contrast': 20,
    'Highlights': -40,
    'Shadows': 35,
    'Whites': 10,
    'Blacks': -15,
  };

  // ─── Color Panel Sliders ─────────────────────────────
  final Map<String, double> _colorValues = {
    'Temperature': 0,
    'Tint': 0,
    'Vibrance': 15,
    'Saturation': 0,
  };

  // ─── Effects Panel Sliders ───────────────────────────
  final Map<String, double> _effectsValues = {
    'Texture': 0,
    'Clarity': 0,
    'Dehaze': 0,
    'Vignette': 0,
    'Grain': 0,
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

  /// Full-bleed image preview
  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundPanel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder — landscape preview
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A3A52),
                    Color(0xFF2D5F41),
                    Color(0xFF5A7A4A),
                    Color(0xFF8B7355),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.landscape_rounded,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preview Foto',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                  Icon(Icons.auto_graph_rounded,
                      size: 16, color: AppColors.textSecondary),
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
          return _buildSliderRow(
            label: entry.key,
            value: entry.value,
            min: entry.key == 'Exposure' ? -5.0 : -100.0,
            max: entry.key == 'Exposure' ? 5.0 : 100.0,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentValues[entry.key] = val;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  /// Single slider row: Label — Slider — Value
  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    // Format value display
    String displayValue;
    if (label == 'Exposure') {
      displayValue =
          '${value >= 0 ? "+" : ""}${value.toStringAsFixed(2).replaceAll(".", ",")}';
    } else {
      final intVal = value.round();
      displayValue = '${intVal >= 0 ? "+" : ""}$intVal';
    }



    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 14),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),

          // Custom centered slider
          Expanded(
            child: _CenteredSlider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),

          // Value
          SizedBox(
            width: 46,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
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

/// Custom centered slider widget yang menunjukkan posisi dari center (zero)
class _CenteredSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _CenteredSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final centerFraction = (0 - min) / (max - min);
        final valueFraction = (value - min) / (max - min);
        final centerX = width * centerFraction;
        final valueX = width * valueFraction;

        return SizedBox(
          height: 36,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background track
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.sliderTrack,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              // Active portion (from center to thumb)
              Positioned(
                left: value >= 0 ? centerX : valueX,
                width: (valueX - centerX).abs(),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              // Center dot indicator
              Positioned(
                left: centerX - 2,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Invisible slider on top for gesture handling
              Positioned.fill(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: AppColors.textPrimary,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayColor: AppColors.primary.withValues(alpha: 0.08),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
