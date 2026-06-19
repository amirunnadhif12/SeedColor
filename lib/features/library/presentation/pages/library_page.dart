import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// 🌱 SeedColor — Library Page
///
/// Revamped dashboard matching Screen 1 of the premium mockup.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ──────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ─── Title ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'Library',
                  style: AppTypography.heading1.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // ─── Stats Cards Grid ────────────────────────
            SliverToBoxAdapter(child: _buildStatsCards()),

            // ─── Albums Header ───────────────────────────
            SliverToBoxAdapter(child: _buildAlbumsHeader()),

            // ─── Album List ──────────────────────────────
            SliverList(
              delegate: SliverChildListDelegate([
                _buildAlbumItem(
                  context: context,
                  name: 'Nature',
                  count: 128,
                  imagePath: 'assets/images/album_nature.png',
                ),
                _buildAlbumItem(
                  context: context,
                  name: 'City',
                  count: 97,
                  imagePath: 'assets/images/album_city.png',
                ),
                _buildAlbumItem(
                  context: context,
                  name: 'Portrait',
                  count: 156,
                  imagePath: 'assets/images/album_portrait.png',
                ),
                _buildAlbumItem(
                  context: context,
                  name: 'Travel',
                  count: 75,
                  imagePath: 'assets/images/album_travel.png',
                ),
                const SizedBox(height: 100), // Spacing for bottom nav
              ]),
            ),
          ],
        ),
      ),
    );
  }

  /// Header matching logo and subtext of mockup
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
      child: Row(
        children: [
          // Logo SeedColor Tile
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF141522),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A84FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Seed',
                    style: AppTypography.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Color',
                    style: AppTypography.heading3.copyWith(
                      color: const Color(0xFF0A84FF),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'EDIT YOUR WORLD',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 24),
            color: AppColors.textSecondary,
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  /// 2x2 Stats cards matching mockup layout
  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.image_outlined,
                  label: 'All Photos',
                  count: '1,253',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite_border_rounded,
                  label: 'Favorites',
                  count: '312',
                  color: const Color(0xFFFF4081),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.folder_open_rounded,
                  label: 'Albums',
                  count: '28',
                  color: const Color(0xFFFFB300),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.delete_outline_rounded,
                  label: 'Trash',
                  count: '18',
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Albums section header
  Widget _buildAlbumsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(
            'Albums',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Text(
              'See All',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Single album list item with image thumbnail matching mockup
  Widget _buildAlbumItem({
    required BuildContext context,
    required String name,
    required int count,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.backgroundPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Album photo thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Album info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
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
