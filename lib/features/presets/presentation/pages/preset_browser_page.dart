import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../features/editor/presentation/bloc/editor_bloc.dart';
import '../../../../features/editor/presentation/bloc/editor_event.dart';
import '../../domain/entities/preset.dart';
import '../bloc/presets_bloc.dart';
import '../bloc/presets_event.dart';
import '../bloc/presets_state.dart';
import '../widgets/preset_card.dart';

/// 🌱 SeedColor — Preset Browser Page
///
/// Wraps the actual browser view with a [BlocProvider] of [PresetsBloc]
/// and triggers [LoadPresets] on startup.
class PresetBrowserPage extends StatelessWidget {
  const PresetBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PresetsBloc>(
      create: (context) => sl<PresetsBloc>()..add(LoadPresets()),
      child: const PresetBrowserView(),
    );
  }
}

class PresetBrowserView extends StatefulWidget {
  const PresetBrowserView({super.key});

  @override
  State<PresetBrowserView> createState() => _PresetBrowserViewState();
}

class _PresetBrowserViewState extends State<PresetBrowserView>
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

  String? _getPresetImagePath(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('cinema')) return 'assets/images/album_travel.png';
    if (lowerName.contains('teal')) return 'assets/images/mountain_lake.png';
    if (lowerName.contains('warm')) return 'assets/images/album_travel.png';
    if (lowerName.contains('moody') || lowerName.contains('dark')) return 'assets/images/album_city.png';
    if (lowerName.contains('film')) return 'assets/images/mountain_lake.png';
    if (lowerName.contains('matte')) return 'assets/images/album_portrait.png';
    if (lowerName.contains('sunset')) return 'assets/images/album_travel.png';
    if (lowerName.contains('b&w') || lowerName.contains('monochrome')) return 'assets/images/album_city.png';
    if (lowerName.contains('portra')) return 'assets/images/album_portrait.png';
    if (lowerName.contains('velvia')) return 'assets/images/album_nature.png';
    if (lowerName.contains('ektar')) return 'assets/images/album_nature.png';
    if (lowerName.contains('urban')) return 'assets/images/album_city.png';
    if (lowerName.contains('forest') || lowerName.contains('cool')) return 'assets/images/album_nature.png';
    if (lowerName.contains('vintage')) return 'assets/images/album_portrait.png';
    return null; // Fallback to gradients for user presets
  }

  List<Color>? _getPresetGradient(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('cinema')) {
      return [const Color(0xFFE5A93B), const Color(0xFF2A52BE)];
    }
    if (lowerName.contains('teal')) {
      return [const Color(0xFF008080), const Color(0xFFFF7F50)];
    }
    if (lowerName.contains('warm')) {
      return [const Color(0xFFFFB347), const Color(0xFFFFCC33)];
    }
    if (lowerName.contains('moody') || lowerName.contains('dark')) {
      return [const Color(0xFF1F1F1F), const Color(0xFF000000)];
    }
    if (lowerName.contains('b&w') || lowerName.contains('monochrome')) {
      return [const Color(0xFF7F7F7F), const Color(0xFF1A1A1A)];
    }
    return [const Color(0xFF0A84FF), const Color(0xFFBC8CFF)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PresetsBloc, PresetsState>(
      listener: (context, state) {
        if (state is PresetsLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        if (state is PresetsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                // ─── Header ──────────────────────────────────
                _buildHeader(context),

                // ─── Tab Bar ─────────────────────────────────
                _buildTabBar(),

                // ─── Tab Content ─────────────────────────────
                Expanded(
                  child: Builder(
                    builder: (childContext) {
                      if (state is PresetsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        );
                      }

                      if (state is PresetsLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildPresetGrid(context, state.recommended),
                            _buildPresetGrid(context, state.premium),
                            state.yours.isEmpty
                                ? _buildEmptyState()
                                : _buildPresetGrid(context, state.yours),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header matching Mockup Screen 4: Back + Title + Plus + More
  Widget _buildHeader(BuildContext context) {
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
            onPressed: () => _showImportDialog(context),
            tooltip: 'Import XMP Preset',
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, size: 24),
            color: AppColors.textPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SeedColor Presets Manager v1.0'),
                  backgroundColor: AppColors.backgroundPanel,
                ),
              );
            },
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
  Widget _buildPresetGrid(BuildContext context, List<Preset> presets) {
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
      itemBuilder: (gridContext, index) {
        final preset = presets[index];
        final imagePath = _getPresetImagePath(preset.name);
        final gradientColors = imagePath == null ? _getPresetGradient(preset.name) : null;

        return PresetCard(
          name: preset.name,
          imagePath: imagePath,
          gradientColors: gradientColors,
          isBookmarked: preset.isBookmarked,
          onTap: () => _showPresetOptions(context, preset),
          onBookmarkToggle: () {
            context.read<PresetsBloc>().add(
                  ToggleBookmark(
                    presetId: preset.id,
                    isBookmarked: !preset.isBookmarked,
                  ),
                );
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

  void _showPresetOptions(BuildContext parentContext, Preset preset) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: AppColors.backgroundPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  preset.name,
                  style: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              // Option 1: Apply to editor
              ListTile(
                leading: const Icon(Icons.palette_rounded, color: AppColors.primary),
                title: const Text('Terapkan ke Penyuntingan', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  sl<EditorBloc>().add(ApplyPreset(preset.parameters));
                  parentContext.go('/edit');
                },
              ),
              // Option 2: Export to XMP
              ListTile(
                leading: const Icon(Icons.ios_share_rounded, color: Colors.white70),
                title: const Text('Ekspor ke .XMP', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showExportDialog(parentContext, preset);
                },
              ),
              // Option 3: Delete (Only if Yours)
              if (preset.category == 'yours')
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  title: const Text('Hapus Preset', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    parentContext.read<PresetsBloc>().add(DeletePresetEvent(presetId: preset.id));
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showImportDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Import Preset from XMP', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter absolute file path (e.g. C:/Presets/teal.xmp)',
              hintStyle: TextStyle(color: Colors.white30),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final path = controller.text.trim();
                if (path.isNotEmpty) {
                  parentContext.read<PresetsBloc>().add(ImportXmp(filePath: path));
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Import', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(BuildContext parentContext, Preset preset) {
    final controller = TextEditingController(text: 'C:/Users/ACER/Downloads');
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Export Preset to XMP', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter absolute directory path',
              hintStyle: TextStyle(color: Colors.white30),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final path = controller.text.trim();
                if (path.isNotEmpty) {
                  parentContext.read<PresetsBloc>().add(
                        ExportXmp(
                          presetId: preset.id,
                          outputPath: path,
                        ),
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Export', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}
