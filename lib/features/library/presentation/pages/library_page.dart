import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// 🌱 SeedColor — Halaman Library (Beranda)
///
/// Menampilkan stats, album, dan navigasi ke foto.
/// Design: Dark mode premium sesuai referensi.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ──────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ─── Title ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Library',
                  style: AppTypography.heading1.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                  ),
                ),
              ),
            ),

            // ─── Stats Cards ─────────────────────────────
            SliverToBoxAdapter(child: _buildStatsCards()),

            // ─── Albums Header ───────────────────────────
            SliverToBoxAdapter(child: _buildAlbumsHeader()),

            // ─── Album List ──────────────────────────────
            SliverList(
              delegate: SliverChildListDelegate([
                _buildAlbumItem(
                  name: 'Nature',
                  count: 128,
                  gradient: const [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  icon: Icons.landscape_rounded,
                ),
                _buildAlbumItem(
                  name: 'City',
                  count: 97,
                  gradient: const [Color(0xFF1A237E), Color(0xFF5C6BC0)],
                  icon: Icons.location_city_rounded,
                ),
                _buildAlbumItem(
                  name: 'Portrait',
                  count: 156,
                  gradient: const [Color(0xFF4A148C), Color(0xFFAB47BC)],
                  icon: Icons.face_rounded,
                ),
                _buildAlbumItem(
                  name: 'Travel',
                  count: 75,
                  gradient: const [Color(0xFFE65100), Color(0xFFFF9800)],
                  icon: Icons.flight_rounded,
                ),
                const SizedBox(height: 100), // Spacing for bottom nav
              ]),
            ),
          ],
        ),
      ),
    );
  }

  /// Header dengan logo SeedColor + settings icon
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          // Logo SeedColor
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A84FF), Color(0xFF0066CC)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'SeedColor',
            style: AppTypography.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 24),
            color: AppColors.textSecondary,
            onPressed: () {},
            tooltip: 'Pengaturan',
          ),
        ],
      ),
    );
  }

  /// 2x2 Stats cards grid
  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.photo_rounded,
                  label: 'Semua Foto',
                  count: '1.253',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite_rounded,
                  label: 'Favorit',
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
                  icon: Icons.folder_rounded,
                  label: 'Album',
                  count: '28',
                  color: const Color(0xFFFFB300),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.delete_rounded,
                  label: 'Tempat Sampah',
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
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
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
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
            'Album',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Lihat Semua',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Single album list item
  Widget _buildAlbumItem({
    required String name,
    required int count,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundPanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Album thumbnail (gradient placeholder)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: Colors.white70),
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
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count foto',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDisabled,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
