import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// 🌱 SeedColor — Preset Card Widget
///
/// Refactored to support full-card photographic backgrounds with overlaid titles
/// and bookmark stars on the bottom right to match Mockup Screen 4.
class PresetCard extends StatelessWidget {
  final String name;
  final String? imagePath;
  final List<Color>? gradientColors;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkToggle;

  const PresetCard({
    super.key,
    required this.name,
    this.imagePath,
    this.gradientColors,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── Background Photo or Gradient ──────────
            if (imagePath != null)
              Image.asset(
                imagePath!,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors ?? [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.landscape_rounded,
                    size: 32,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),

            // ─── Subtle Dark Bottom Gradient ───────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // ─── Text & Star Overlay at the Bottom ─────
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  // Title Text
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bookmark Star (bottom-right of the card)
                  GestureDetector(
                    onTap: onBookmarkToggle,
                    child: Icon(
                      isBookmarked ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 16,
                      color: isBookmarked ? const Color(0xFFFFD700) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
