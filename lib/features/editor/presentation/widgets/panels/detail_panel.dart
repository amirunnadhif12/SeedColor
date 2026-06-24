import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — Detail Panel
///
/// Panel kontrol Detail dengan slider untuk penajaman gambar (Sharpening)
/// dan pengurangan bising (Noise Reduction - Luminance & Color).
class DetailPanel extends StatelessWidget {
  final EditParameters parameters;
  final void Function(String key, double value) onChanged;
  final void Function(String key, double value) onChangeEnd;

  const DetailPanel({
    super.key,
    required this.parameters,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              physics: const BouncingScrollPhysics(),
              children: [
                // ─── SHARPENING GROUP ───────────────────────────
                _buildGroupHeader('PENAJAMAN'),
                SeedSlider(
                  label: 'Menajamkan',
                  value: parameters.sharpeningAmount,
                  min: 0.0,
                  max: 150.0,
                  onChanged: (val) => onChanged('Sharpening', val),
                  onChangeEnd: (val) => onChangeEnd('Sharpening', val),
                  accentColor: AppColors.toolDetail,
                ),
                SeedSlider(
                  label: 'Radius',
                  value: parameters.sharpeningRadius,
                  min: 0.0,
                  max: 3.0,
                  onChanged: (val) => onChanged('Radius', val),
                  onChangeEnd: (val) => onChangeEnd('Radius', val),
                  accentColor: AppColors.toolDetail,
                  formatValue: (val) => val.toStringAsFixed(1).replaceAll('.', ','),
                ),
                SeedSlider(
                  label: 'Detail',
                  value: parameters.sharpeningDetail,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Detail', val),
                  onChangeEnd: (val) => onChangeEnd('Detail', val),
                  accentColor: AppColors.toolDetail,
                ),
                SeedSlider(
                  label: 'Masking',
                  value: parameters.sharpeningMasking,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Masking', val),
                  onChangeEnd: (val) => onChangeEnd('Masking', val),
                  accentColor: AppColors.toolDetail,
                ),

                const SizedBox(height: 14),

                // ─── NOISE REDUCTION GROUP ──────────────────────
                _buildGroupHeader('PENGURANGAN BISING'),
                SeedSlider(
                  label: 'Luminance NR',
                  value: parameters.luminanceNR,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Luminance NR', val),
                  onChangeEnd: (val) => onChangeEnd('Luminance NR', val),
                  accentColor: AppColors.toolDetail,
                ),
                SeedSlider(
                  label: 'Color NR',
                  value: parameters.colorNR,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Color NR', val),
                  onChangeEnd: (val) => onChangeEnd('Color NR', val),
                  accentColor: AppColors.toolDetail,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
