import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — Light Panel
///
/// Panel kontrol pencahayaan dengan 6 slider utama (Exposure, Contrast,
/// Highlights, Shadows, Whites, Blacks) dan tombol penyesuaian otomatis (Auto).
class LightPanel extends StatelessWidget {
  final EditParameters parameters;
  final void Function(String key, double value) onChanged;
  final void Function(String key, double value) onChangeEnd;
  final VoidCallback onAutoPressed;

  const LightPanel({
    super.key,
    required this.parameters,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onAutoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        children: [
          // ─── Header Panel & Tombol Auto ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onAutoPressed,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.brightness_auto_rounded,
                          size: 14,
                          color: AppColors.toolLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Auto',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Daftar Sliders ───────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              physics: const BouncingScrollPhysics(),
              children: [
                SeedSlider(
                  label: 'Exposure',
                  value: parameters.exposure,
                  min: -5.0,
                  max: 5.0,
                  onChanged: (val) => onChanged('Exposure', val),
                  onChangeEnd: (val) => onChangeEnd('Exposure', val),
                  accentColor: AppColors.toolLight,
                  formatValue: (val) =>
                      '${val >= 0 ? "+" : ""}${val.toStringAsFixed(2).replaceAll(".", ",")}',
                ),
                SeedSlider(
                  label: 'Contrast',
                  value: parameters.contrast,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Contrast', val),
                  onChangeEnd: (val) => onChangeEnd('Contrast', val),
                  accentColor: AppColors.toolLight,
                ),
                SeedSlider(
                  label: 'Highlights',
                  value: parameters.highlights,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Highlights', val),
                  onChangeEnd: (val) => onChangeEnd('Highlights', val),
                  accentColor: AppColors.toolLight,
                ),
                SeedSlider(
                  label: 'Shadows',
                  value: parameters.shadows,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Shadows', val),
                  onChangeEnd: (val) => onChangeEnd('Shadows', val),
                  accentColor: AppColors.toolLight,
                ),
                SeedSlider(
                  label: 'Whites',
                  value: parameters.whites,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Whites', val),
                  onChangeEnd: (val) => onChangeEnd('Whites', val),
                  accentColor: AppColors.toolLight,
                ),
                SeedSlider(
                  label: 'Blacks',
                  value: parameters.blacks,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Blacks', val),
                  onChangeEnd: (val) => onChangeEnd('Blacks', val),
                  accentColor: AppColors.toolLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
