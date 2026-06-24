import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';
import 'package:seed_color/features/editor/domain/entities/mask_model.dart';

/// 🌱 SeedColor — Masking Panel
///
/// Panel kontrol untuk mengelola beberapa masker (brush, linear, radial, AI)
/// dan menerapkan slider penyesuaian lokal (exposure, contrast, shadows, dll)
/// khusus untuk masker aktif.
class MaskingPanel extends StatelessWidget {
  final EditParameters parameters;
  final void Function(EditParameters updatedParams) onChanged;
  final void Function(EditParameters updatedParams) onChangeEnd;
  final bool showOverlay;
  final ValueChanged<bool> onToggleOverlay;

  const MaskingPanel({
    super.key,
    required this.parameters,
    required this.onChanged,
    required this.onChangeEnd,
    required this.showOverlay,
    required this.onToggleOverlay,
  });

  MaskModel? get _activeMask {
    if (parameters.activeMaskId == null) return null;
    for (final m in parameters.masks) {
      if (m.id == parameters.activeMaskId) {
        return m;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeMask;

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        children: [
          // ─── Toolbar: Tambah, List Masker & Toggle Overlay ───
          _buildToolbar(context, active),

          // ─── Area Sliders / Pesan Kosong ───────────────────
          Expanded(
            child: active != null
                ? _buildSliders(active)
                : _buildEmptyState(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, MaskModel? active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          // Tombol Tambah Masker Baru
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showAddMaskMenu(context),
            tooltip: 'Tambah Masker Baru',
          ),
          const SizedBox(width: 8),

          // List Horizontal Masker-Masker Aktif
          Expanded(
            child: SizedBox(
              height: 32,
              child: parameters.masks.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada masker penyesuaian',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: parameters.masks.length,
                      itemBuilder: (context, index) {
                        final mask = parameters.masks[index];
                        final isSelected = mask.id == parameters.activeMaskId;

                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getMaskIcon(mask.type),
                                  size: 12,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mask.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    final updatedMasks = List<MaskModel>.from(parameters.masks)..removeAt(index);
                                    final nextActiveId = isSelected
                                        ? (updatedMasks.isNotEmpty ? updatedMasks.last.id : null)
                                        : parameters.activeMaskId;
                                    onChanged(parameters.copyWith(
                                      masks: updatedMasks,
                                      activeMaskId: nextActiveId,
                                      clearActiveMask: nextActiveId == null,
                                    ));
                                    onChangeEnd(parameters.copyWith(
                                      masks: updatedMasks,
                                      activeMaskId: nextActiveId,
                                      clearActiveMask: nextActiveId == null,
                                    ));
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 12,
                                    color: isSelected ? Colors.white60 : Colors.white30,
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: const Color(0xFF141522),
                            onSelected: (selected) {
                              if (selected) {
                                onChanged(parameters.copyWith(activeMaskId: mask.id));
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Tombol Toggle Overlay (Merah)
          IconButton(
            icon: Icon(
              showOverlay ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: showOverlay ? const Color(0xFFFF3B30) : AppColors.textSecondary,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => onToggleOverlay(!showOverlay),
            tooltip: 'Tampilkan Overlay Masker (Merah)',
          ),
        ],
      ),
    );
  }

  Widget _buildSliders(MaskModel active) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      physics: const BouncingScrollPhysics(),
      children: [
        SeedSlider(
          label: 'Mask Exposure',
          value: active.exposure,
          min: -5.0,
          max: 5.0,
          onChanged: (val) => _updateActiveMaskValue('exposure', val),
          onChangeEnd: (val) => _updateActiveMaskValueEnd('exposure', val),
          accentColor: AppColors.toolMasking,
          formatValue: (val) => '${val >= 0 ? "+" : ""}${val.toStringAsFixed(2).replaceAll(".", ",")}',
        ),
        SeedSlider(
          label: 'Mask Contrast',
          value: active.contrast,
          min: -100.0,
          max: 100.0,
          onChanged: (val) => _updateActiveMaskValue('contrast', val),
          onChangeEnd: (val) => _updateActiveMaskValueEnd('contrast', val),
          accentColor: AppColors.toolMasking,
        ),
        SeedSlider(
          label: 'Mask Shadows',
          value: active.shadows,
          min: -100.0,
          max: 100.0,
          onChanged: (val) => _updateActiveMaskValue('shadows', val),
          onChangeEnd: (val) => _updateActiveMaskValueEnd('shadows', val),
          accentColor: AppColors.toolMasking,
        ),
        SeedSlider(
          label: 'Mask Saturation',
          value: active.saturation,
          min: -100.0,
          max: 100.0,
          onChanged: (val) => _updateActiveMaskValue('saturation', val),
          onChangeEnd: (val) => _updateActiveMaskValueEnd('saturation', val),
          accentColor: AppColors.toolMasking,
        ),
        SeedSlider(
          label: 'Mask Temp',
          value: active.temperature,
          min: -100.0,
          max: 100.0,
          onChanged: (val) => _updateActiveMaskValue('temperature', val),
          onChangeEnd: (val) => _updateActiveMaskValueEnd('temperature', val),
          accentColor: AppColors.toolMasking,
        ),
        SeedSlider(
          label: 'Mask Tint',
          value: active.tint,
          min: -100.0,
          max: 100.0,
          onChanged: (val) => _updateActiveMaskValue('tint', val),
          onChangeEnd: (val) => _updateActiveMaskValueEnd('tint', val),
          accentColor: AppColors.toolMasking,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.layers_clear_rounded, size: 36, color: Colors.white24),
          const SizedBox(height: 8),
          Text(
            'Silakan tambah masker untuk memulai penyesuaian lokal',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddMaskMenu(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah Masker', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMaskMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + 12,
        offset.dy - 140, // Memunculkan menu di atas panel
        offset.dx + 200,
        offset.dy,
      ),
      color: const Color(0xFF1E1E2E),
      items: [
        PopupMenuItem(
          value: MaskType.brush,
          child: const Row(
            children: [
              Icon(Icons.brush_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Kuas (Brush)', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: MaskType.linear,
          child: const Row(
            children: [
              Icon(Icons.linear_scale_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Gradien Linier', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: MaskType.radial,
          child: const Row(
            children: [
              Icon(Icons.adjust_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Gradien Radial', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: MaskType.subject,
          child: const Row(
            children: [
              Icon(Icons.person_outline_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Pilih Subjek (AI)', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: MaskType.sky,
          child: const Row(
            children: [
              Icon(Icons.cloud_queue_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text('Pilih Langit (AI)', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final name = _getDefaultMaskName(value, parameters.masks.length + 1);

        final newMask = MaskModel(
          id: id,
          name: name,
          type: value,
          // Inisialisasi posisi geometri gradien default
          linearStart: value == MaskType.linear ? const Offset(0.5, 0.25) : null,
          linearEnd: value == MaskType.linear ? const Offset(0.5, 0.75) : null,
          radialCenter: value == MaskType.radial ? const Offset(0.5, 0.5) : null,
          radialRadiusX: value == MaskType.radial ? 0.18 : 0.15,
          radialRadiusY: value == MaskType.radial ? 0.18 : 0.15,
        );

        final updatedMasks = List<MaskModel>.from(parameters.masks)..add(newMask);
        onChanged(parameters.copyWith(masks: updatedMasks, activeMaskId: id));
        onChangeEnd(parameters.copyWith(masks: updatedMasks, activeMaskId: id));
      }
    });
  }

  void _updateActiveMaskValue(String field, double val) {
    final activeId = parameters.activeMaskId;
    if (activeId == null) return;

    final updatedMasks = parameters.masks.map((m) {
      if (m.id == activeId) {
        switch (field) {
          case 'exposure': return m.copyWith(exposure: val);
          case 'contrast': return m.copyWith(contrast: val);
          case 'shadows': return m.copyWith(shadows: val);
          case 'saturation': return m.copyWith(saturation: val);
          case 'temperature': return m.copyWith(temperature: val);
          case 'tint': return m.copyWith(tint: val);
        }
      }
      return m;
    }).toList();

    onChanged(parameters.copyWith(masks: updatedMasks));
  }

  void _updateActiveMaskValueEnd(String field, double val) {
    final activeId = parameters.activeMaskId;
    if (activeId == null) return;

    final updatedMasks = parameters.masks.map((m) {
      if (m.id == activeId) {
        switch (field) {
          case 'exposure': return m.copyWith(exposure: val);
          case 'contrast': return m.copyWith(contrast: val);
          case 'shadows': return m.copyWith(shadows: val);
          case 'saturation': return m.copyWith(saturation: val);
          case 'temperature': return m.copyWith(temperature: val);
          case 'tint': return m.copyWith(tint: val);
        }
      }
      return m;
    }).toList();

    onChangeEnd(parameters.copyWith(masks: updatedMasks));
  }

  IconData _getMaskIcon(MaskType type) {
    switch (type) {
      case MaskType.brush: return Icons.brush_rounded;
      case MaskType.linear: return Icons.linear_scale_rounded;
      case MaskType.radial: return Icons.adjust_rounded;
      case MaskType.subject: return Icons.person_outline_rounded;
      case MaskType.sky: return Icons.cloud_queue_rounded;
    }
  }

  String _getDefaultMaskName(MaskType type, int count) {
    switch (type) {
      case MaskType.brush: return 'Kuas $count';
      case MaskType.linear: return 'Gradien Linier $count';
      case MaskType.radial: return 'Gradien Radial $count';
      case MaskType.subject: return 'AI Subjek $count';
      case MaskType.sky: return 'AI Langit $count';
    }
  }
}
