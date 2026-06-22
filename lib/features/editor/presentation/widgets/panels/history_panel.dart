import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../bloc/editor_state.dart';

class HistoryPanel extends StatefulWidget {
  final List<HistoryEntry> history;
  final int currentHistoryIndex;
  final List<NamedSnapshot> snapshots;
  final ValueChanged<int> onStepSelected;
  final ValueChanged<String> onCreateSnapshot;
  final ValueChanged<NamedSnapshot> onApplySnapshot;
  final ValueChanged<String> onDeleteSnapshot;

  const HistoryPanel({
    super.key,
    required this.history,
    required this.currentHistoryIndex,
    required this.snapshots,
    required this.onStepSelected,
    required this.onCreateSnapshot,
    required this.onApplySnapshot,
    required this.onDeleteSnapshot,
  });

  @override
  State<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel> {
  int _activeTab = 0; // 0 for Langkah, 1 for Snapshot

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Top Control Row (TabBar + Add Snapshot Button) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Custom Tab Bar Row
                GestureDetector(
                  onTap: () => setState(() => _activeTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTab == 0 ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Langkah',
                      style: AppTypography.labelMedium.copyWith(
                        color: _activeTab == 0 ? AppColors.textPrimary : AppColors.textTertiary,
                        fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _activeTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTab == 1 ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Snapshot',
                      style: AppTypography.labelMedium.copyWith(
                        color: _activeTab == 1 ? AppColors.textPrimary : AppColors.textTertiary,
                        fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Add Snapshot Button (only visible in Snapshot tab)
                if (_activeTab == 1)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                    onPressed: () => _showCreateSnapshotDialog(context),
                    tooltip: 'Buat Snapshot Baru',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1, thickness: 0.5),
          const SizedBox(height: 8),

          // ─── Tab Content List ───
          Expanded(
            child: _activeTab == 0 ? _buildHistoryList() : _buildSnapshotsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (widget.history.isEmpty) {
      return Center(
        child: Text(
          'Belum ada langkah pengeditan',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    // Lightroom lists history with newest at the top
    final reversedHistory = widget.history.reversed.toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      itemCount: reversedHistory.length,
      itemBuilder: (context, index) {
        final entry = reversedHistory[index];
        // Calculate the actual index in the non-reversed history list
        final actualIndex = widget.history.length - 1 - index;
        final isActive = actualIndex == widget.currentHistoryIndex;

        return GestureDetector(
          onTap: () => widget.onStepSelected(actualIndex),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            margin: const EdgeInsets.only(bottom: 6.0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? Icons.play_arrow_rounded : Icons.lens,
                  size: isActive ? 16 : 6,
                  color: isActive ? AppColors.primary : AppColors.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isActive ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  _formatTime(entry.timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSnapshotsList() {
    if (widget.snapshots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Belum ada snapshot.\nBuat snapshot untuk menyimpan pengaturan saat ini.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      itemCount: widget.snapshots.length,
      itemBuilder: (context, index) {
        final snapshot = widget.snapshots[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 6.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            visualDensity: const VisualDensity(vertical: -3),
            title: Text(
              snapshot.name,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _formatDate(snapshot.createdAt),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                  onPressed: () => widget.onApplySnapshot(snapshot),
                  tooltip: 'Terapkan',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  onPressed: () => widget.onDeleteSnapshot(snapshot.id),
                  tooltip: 'Hapus',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateSnapshotDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Buat Snapshot Baru',
            style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nama snapshot (contoh: Edit Hangat)',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final name = controller.text.trim();
                widget.onCreateSnapshot(name);
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$hour:$min:$sec';
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$min';
  }
}
