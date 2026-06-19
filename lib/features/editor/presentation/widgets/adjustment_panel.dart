import 'package:flutter/material.dart';
import '../../../../core/widgets/seed_slider.dart';

/// 🌱 SeedColor — Adjustment Panel
///
/// Panel scrollable berisi kumpulan slider penyesuaian untuk kategori
/// alat yang aktif saat ini (seperti Exposure, Contrast, dsb).
class AdjustmentPanel extends StatelessWidget {
  final Map<String, double> values;
  final void Function(String key, double value) onChanged;

  const AdjustmentPanel({
    super.key,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        physics: const BouncingScrollPhysics(),
        children: values.entries.map((entry) {
          final isExposure = entry.key == 'Exposure';
          return SeedSlider(
            label: entry.key,
            value: entry.value,
            min: isExposure ? -5.0 : -100.0,
            max: isExposure ? 5.0 : 100.0,
            onChanged: (val) => onChanged(entry.key, val),
          );
        }).toList(),
      ),
    );
  }
}
