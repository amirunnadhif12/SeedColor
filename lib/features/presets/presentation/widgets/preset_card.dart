import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// 🌱 SeedColor — Preset Card Widget
///
/// Card untuk menampilkan preset di grid.
/// Menampilkan thumbnail gradient, nama preset, dan bookmark star.
class PresetCard extends StatelessWidget {
  final String name;
  final List<Color> gradientColors;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkToggle;

  const PresetCard({
    super.key,
    required this.name,
    required this.gradientColors,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundPanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Thumbnail ─────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient thumbnail placeholder
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 40,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),

                  // Bookmark star (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onBookmarkToggle,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isBookmarked
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 16,
                          color: isBookmarked
                              ? const Color(0xFFFFD700)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Name Label ────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                name,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
