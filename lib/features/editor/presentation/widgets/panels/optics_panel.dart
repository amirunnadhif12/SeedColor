import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — Optics Panel
///
/// Panel kontrol untuk mengaktifkan koreksi optik lensa kamera,
/// termasuk penghapusan Chromatic Aberration dan Lens Correction (koreksi distorsi).
class OpticsPanel extends StatelessWidget {
  final EditParameters parameters;
  final void Function(bool removeCA) onChromaticAberrationChanged;
  final void Function(bool enableLC) onLensCorrectionChanged;

  const OpticsPanel({
    super.key,
    required this.parameters,
    required this.onChromaticAberrationChanged,
    required this.onLensCorrectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildOpticsToggleRow(
                  context: context,
                  title: 'Hapus Aberasi Kromatik',
                  subtitle: 'Mengoreksi garis warna biru/merah pada tepian objek secara otomatis.',
                  value: parameters.removeChromaticAberration,
                  onChanged: onChromaticAberrationChanged,
                  icon: Icons.lens_blur_rounded,
                  accentColor: const Color(0xFFBC8CFF),
                ),
                const SizedBox(height: 16),
                _buildOpticsToggleRow(
                  context: context,
                  title: 'Koreksi Profil Lensa',
                  subtitle: 'Mengoreksi distorsi cembung/barrel bawaan lensa kamera.',
                  value: parameters.enableLensCorrection,
                  onChanged: onLensCorrectionChanged,
                  icon: Icons.camera_rounded,
                  accentColor: const Color(0xFFBC8CFF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpticsToggleRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? AppColors.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
          ),
        ],
      ),
    );
  }
}
