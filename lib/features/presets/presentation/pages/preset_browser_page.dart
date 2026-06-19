import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../widgets/preset_card.dart';

/// 🌱 SeedColor — Preset Browser Page
///
/// Refactored to align with Mockup Screen 4 layout, styling, and photorealistic presets.
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

  // ─── Preset Data (Mockup Screen 4) ────────────────────
  static final List<_PresetData> _recommendedPresets = [
    _PresetData('Blue Nature', 'assets/images/album_nature.png', true),
    _PresetData('Warm Travel', 'assets/images/album_travel.png', true),
    _PresetData('Dark Moody', 'assets/images/album_city.png', false),
    _PresetData('Street Vibe', 'assets/images/album_city.png', false),
    _PresetData('Film Classic', 'assets/images/mountain_lake.png', false),
    _PresetData('Matte Soft', 'assets/images/album_portrait.png', false),
    _PresetData('Sunset Glow', 'assets/images/album_travel.png', false),
    _PresetData('Black & White', 'assets/images/album_city.png', false),
  ];

  static final List<_PresetData> _premiumPresets = [
    _PresetData('Cinema Gold', 'assets/images/album_travel.png', false),
    _PresetData('Teal Orange', 'assets/images/mountain_lake.png', false),
    _PresetData('Portra 400', 'assets/images/album_portrait.png', false),
    _PresetData('Velvia 50', 'assets/images/album_nature.png', false),
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
                physics: const BouncingScrollPhysics(),
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

  /// Header matching Mockup Screen 4: Back + Title + Plus + More
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
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'Add Preset',
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, size: 24),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'More options',
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
        labelStyle: AppTypography.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
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
          imagePath: preset.imagePath,
          isBookmarked: preset.isBookmarked,
          onTap: () {},
          onBookmarkToggle: () {
            setState(() {
              // Toggle bookmark logic
              presets[index] = _PresetData(
                preset.name,
                preset.imagePath,
                !preset.isBookmarked,
              );
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
            'No Presets Yet',
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create custom presets from your edits',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetData {
  final String name;
  final String imagePath;
  final bool isBookmarked;

  _PresetData(this.name, this.imagePath, this.isBookmarked);
}
