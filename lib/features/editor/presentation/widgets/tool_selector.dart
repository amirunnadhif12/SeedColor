import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Model data untuk item bilah alat
class ToolItem {
  final IconData icon;
  final String label;
  final Color color;

  const ToolItem(this.icon, this.label, this.color);
}

/// 🌱 SeedColor — Tool Selector
///
/// Bilah horizontal untuk memilih kelompok alat pengeditan foto
/// (seperti Light, Color, Effects, dll) di bagian paling bawah layar.
class ToolSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onToolSelected;
  final List<ToolItem> tools;

  const ToolSelector({
    super.key,
    required this.selectedIndex,
    required this.onToolSelected,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.backgroundPanel,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: List.generate(tools.length, (index) {
            final tool = tools[index];
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onToolSelected(index);
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 60,
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
      ),
    );
  }
}
