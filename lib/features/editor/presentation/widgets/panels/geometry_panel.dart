import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — Geometry Panel
///
/// Panel kontrol Geometri berisi pilihan Rasio Aspek (Crop),
/// tombol putar & cermin (Rotate & Flip), serta slider Perspektif 3D.
class GeometryPanel extends StatefulWidget {
  final EditParameters parameters;
  final void Function(EditParameters params) onChanged;
  final void Function(EditParameters params) onChangeEnd;

  const GeometryPanel({
    super.key,
    required this.parameters,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  State<GeometryPanel> createState() => _GeometryPanelState();
}

class _GeometryPanelState extends State<GeometryPanel> {
  int _activeTabIndex = 0; // 0: Potong, 1: Putar, 2: Perspektif

  final List<String> _aspectRatios = ['Bebas', '1:1', '4:3', '16:9', '3:2'];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        children: [
          // ─── TAB SELECTOR ──────────────────────────────────
          _buildTabBar(),
          const Divider(color: AppColors.border, height: 1, thickness: 0.5),

          // ─── ACTIVE TAB CONTENT ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: _buildActiveTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(0, Icons.crop_rounded, 'POTONG'),
          _buildTabItem(1, Icons.rotate_right_rounded, 'PUTAR'),
          _buildTabItem(2, Icons.grid_3x3_rounded, 'PERSPEKTIF'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildCropTab();
      case 1:
        return _buildRotateTab();
      case 2:
        return _buildPerspectiveTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── CROP TAB (ASPECT RATIOS) ───────────────────────────
  Widget _buildCropTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RASIO ASPEK',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _aspectRatios.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final ratio = _aspectRatios[index];
              final isSelected = widget.parameters.aspectRatio == ratio;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(ratio),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      // Reset crop rect ke default saat berganti rasio
                      final updated = widget.parameters.copyWith(
                        aspectRatio: ratio,
                        cropLeft: 0.0,
                        cropTop: 0.0,
                        cropRight: 1.0,
                        cropBottom: 1.0,
                      );
                      widget.onChanged(updated);
                      widget.onChangeEnd(updated);
                    }
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── ROTATE & FLIP TAB ───────────────────────────────
  Widget _buildRotateTab() {
    return Column(
      children: [
        // Slider fine rotation (-45° s.d. +45°)
        SeedSlider(
          label: 'Rotasi Halus',
          value: widget.parameters.rotation,
          min: -45.0,
          max: 45.0,
          onChanged: (val) {
            widget.onChanged(widget.parameters.copyWith(rotation: val));
          },
          onChangeEnd: (val) {
            widget.onChangeEnd(widget.parameters.copyWith(rotation: val));
          },
          accentColor: AppColors.toolGeometry,
          formatValue: (val) => '${val >= 0 ? "+" : ""}${val.toStringAsFixed(1)}°',
        ),

        const SizedBox(height: 12),

        // Action Buttons Row (Rotate 90, Flip)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.rotate_left_rounded,
              label: 'Putar Kiri',
              onPressed: () {
                // Rotasi 90 derajat kiri
                double newRot = widget.parameters.rotation - 90.0;
                if (newRot < -180.0) newRot += 360.0;
                final updated = widget.parameters.copyWith(rotation: newRot);
                widget.onChanged(updated);
                widget.onChangeEnd(updated);
              },
            ),
            _buildActionButton(
              icon: Icons.rotate_right_rounded,
              label: 'Putar Kanan',
              onPressed: () {
                // Rotasi 90 derajat kanan
                double newRot = widget.parameters.rotation + 90.0;
                if (newRot > 180.0) newRot -= 360.0;
                final updated = widget.parameters.copyWith(rotation: newRot);
                widget.onChanged(updated);
                widget.onChangeEnd(updated);
              },
            ),
            _buildActionButton(
              icon: Icons.flip_rounded,
              label: 'Cermin H',
              isSelected: widget.parameters.flipHorizontal,
              onPressed: () {
                final updated = widget.parameters.copyWith(
                  flipHorizontal: !widget.parameters.flipHorizontal,
                );
                widget.onChanged(updated);
                widget.onChangeEnd(updated);
              },
            ),
            _buildActionButton(
              icon: Icons.flip_outlined,
              label: 'Cermin V',
              isSelected: widget.parameters.flipVertical,
              onPressed: () {
                final updated = widget.parameters.copyWith(
                  flipVertical: !widget.parameters.flipVertical,
                );
                widget.onChanged(updated);
                widget.onChangeEnd(updated);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          style: IconButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ─── PERSPECTIVE TAB ──────────────────────────────────
  Widget _buildPerspectiveTab() {
    return Column(
      children: [
        SeedSlider(
          label: 'Distorsi Vertikal',
          value: widget.parameters.perspectiveVertical,
          min: -20.0,
          max: 20.0,
          onChanged: (val) {
            widget.onChanged(widget.parameters.copyWith(perspectiveVertical: val));
          },
          onChangeEnd: (val) {
            widget.onChangeEnd(widget.parameters.copyWith(perspectiveVertical: val));
          },
          accentColor: AppColors.toolGeometry,
          formatValue: (val) => val.toStringAsFixed(1),
        ),
        SeedSlider(
          label: 'Distorsi Horizontal',
          value: widget.parameters.perspectiveHorizontal,
          min: -20.0,
          max: 20.0,
          onChanged: (val) {
            widget.onChanged(widget.parameters.copyWith(perspectiveHorizontal: val));
          },
          onChangeEnd: (val) {
            widget.onChangeEnd(widget.parameters.copyWith(perspectiveHorizontal: val));
          },
          accentColor: AppColors.toolGeometry,
          formatValue: (val) => val.toStringAsFixed(1),
        ),
      ],
    );
  }
}
