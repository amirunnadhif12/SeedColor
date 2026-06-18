import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../widgets/preset_card.dart';

/// 🌱 SeedColor — Halaman Preset Browser
///
/// Grid preset dengan tabs: Recommended, Premium, Yours
/// Sesuai referensi screen 4.
class PresetBrowserPage extends StatefulWidget {
  const PresetBrowserPage({super.key});

  @override
  State<PresetBrowserPage> createState() => _PresetBrowserPageState();
}

class _PresetBrowserPageState extends State<PresetBrowserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Preset Data ──────────────────────────────────────
  static final List<_PresetData> _recommendedPresets = [
    _PresetData('Blue Nature', [Color(0xFF1A3A52), Color(0xFF4A7C59)], true),
    _PresetData('Warm Travel', [Color(0xFFCC8844), Color(0xFF885533)], true),
    _PresetData('Dark Moody', [Color(0xFF1A1A2E), Color(0xFF16213E)], false),
    _PresetData('Street Vibe', [Color(0xFF2D2D3A), Color(0xFF4A4A5A)], false),
    _PresetData('Film Classic', [Color(0xFF5C4033), Color(0xFF8B7355)], false),
    _PresetData('Matte Soft', [Color(0xFF7A6B5D), Color(0xFFA89B8C)], false),
    _PresetData('Sunset Glow', [Color(0xFFCC6633), Color(0xFFFF8844)], false),
    _PresetData(
        'Black & White', [Color(0xFF2A2A2A), Color(0xFF5A5A5A)], false),
  ];

  static final List<_PresetData> _premiumPresets = [
    _PresetData(
        'Cinema Gold', [Color(0xFF4A3728), Color(0xFFB8860B)], false),
    _PresetData(
        'Teal Orange', [Color(0xFF006D6F), Color(0xFFFF6B35)], false),
    _PresetData(
        'Portra 400', [Color(0xFF8B7355), Color(0xFFD4C5B2)], false),
    _PresetData(
        'Velvia 50', [Color(0xFF2E4600), Color(0xFF1E90FF)], false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────
            _buildHeader(),

            // ─── Tab Bar ─────────────────────────────────
            _buildTabBar(),

            // ─── Tab Content ─────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPresetGrid(_recommendedPresets),
                  _buildPresetGrid(_premiumPresets),
                  _buildEmptyState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header: Back + Title + Add + More
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          Text(
            'Presets',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'Tambah Preset',
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, size: 24),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'Lainnya',
          ),
        ],
      ),
    );
  }

  /// Tab bar: Recommended | Premium | Yours
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTypography.labelLarge.copyWith(fontSize: 13),
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(fontSize: 13),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
        dividerHeight: 0.5,
        tabs: const [
          Tab(text: 'Recommended'),
          Tab(text: 'Premium'),
          Tab(text: 'Yours'),
        ],
      ),
    );
  }

  /// Grid of preset cards (2 columns)
  Widget _buildPresetGrid(List<_PresetData> presets) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        return PresetCard(
          name: preset.name,
          gradientColors: preset.colors,
          isBookmarked: preset.isBookmarked,
          onTap: () {},
          onBookmarkToggle: () {
            setState(() {
              // Toggle bookmark in real app
            });
          },
        );
      },
    );
  }

  /// Empty state for "Yours" tab
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.add_photo_alternate_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Preset',
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat preset kustom dari editan kamu',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetData {
  final String name;
  final List<Color> colors;
  final bool isBookmarked;

  const _PresetData(this.name, this.colors, this.isBookmarked);
}
