import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/launch_utils.dart';
import '../../../../core/utils/copied_settings_helper.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/photo.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../widgets/album_card.dart';
import '../widgets/photo_grid.dart';
import '../../editor/domain/repositories/editor_repository.dart';
import '../../presets/domain/repositories/preset_repository.dart';
import '../../presets/domain/entities/preset.dart';
import '../../batch/batch_exporter.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // 0: Albums, 1: All Photos, 2: Favorites, 3: Trash
  int _selectedSection = 0;
  bool _isSelectionMode = false;
  Set<String> _selectedPhotoIds = {};
  bool _isLoadingBatch = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedPhotoIds.clear();
    });
  }

  Future<void> _checkFirstLaunch() async {
    final isFirst = await LaunchUtils.isFirstLaunch();
    if (isFirst && mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryBloc>(
      create: (context) => sl<LibraryBloc>()..add(LoadLibrary()),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        floatingActionButton: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoaded && !_isSelectionMode) {
              return FloatingActionButton(
                backgroundColor: const Color(0xFF0A84FF),
                onPressed: () {
                  context.read<LibraryBloc>().add(ImportFromGallery());
                },
                child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        body: SafeArea(
          child: BlocConsumer<LibraryBloc, LibraryState>(
            listener: (context, state) {
              if (state is LibraryLoaded && state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is LibraryLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (state is LibraryError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LibraryBloc>().add(LoadLibrary());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is LibraryLoaded) {
                return Stack(
                  children: [
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Header
                        SliverToBoxAdapter(child: _buildHeader(state)),

                        // Title
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

                        // Stats Cards Grid
                        SliverToBoxAdapter(
                          child: _buildStatsCards(
                            allPhotosCount: state.allPhotos.length,
                            favoritesCount: state.favoritePhotos.length,
                            albumsCount: state.albums.length,
                            trashCount: state.trashPhotos.length,
                          ),
                        ),

                        // Active Section Header
                        SliverToBoxAdapter(child: _buildSectionHeader(context)),

                        // Content based on selection
                        _buildActiveSectionContent(state),

                        // Bottom padding offset when in selection mode
                        SliverToBoxAdapter(
                          child: SizedBox(height: _isSelectionMode ? 90.0 : 20.0),
                        ),
                      ],
                    ),
                    if (_isSelectionMode)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildBottomBatchBar(context, state),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  /// Header matching logo and subtext of mockup
  Widget _buildHeader(LibraryLoaded state) {
    if (_isSelectionMode) {
      final List<Photo> activePhotos = _selectedSection == 1 ? state.allPhotos : state.favoritePhotos;
      final isAllSelected = _selectedPhotoIds.length == activePhotos.length && activePhotos.isNotEmpty;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              onPressed: _toggleSelectionMode,
              tooltip: 'Selesai',
            ),
            const SizedBox(width: 12),
            Text(
              '${_selectedPhotoIds.length} Terpilih',
              style: AppTypography.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isAllSelected) {
                    _selectedPhotoIds.clear();
                  } else {
                    _selectedPhotoIds = activePhotos.map((p) => p.id).toSet();
                  }
                });
              },
              child: Text(
                isAllSelected ? 'Batal Pilih' : 'Pilih Semua',
                style: const TextStyle(
                  color: Color(0xFF0A84FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
          if (_selectedSection == 1 || _selectedSection == 2) ...[
            IconButton(
              icon: const Icon(Icons.check_box_outlined, color: Color(0xFF0A84FF), size: 24),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select Mode',
            ),
          ],
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
  Widget _buildStatsCards({
    required int allPhotosCount,
    required int favoritesCount,
    required int albumsCount,
    required int trashCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSection = 1),
                  child: _buildStatCard(
                    icon: Icons.image_outlined,
                    label: 'All Photos',
                    count: allPhotosCount.toString(),
                    color: AppColors.primary,
                    isSelected: _selectedSection == 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSection = 2),
                  child: _buildStatCard(
                    icon: Icons.favorite_border_rounded,
                    label: 'Favorites',
                    count: favoritesCount.toString(),
                    color: const Color(0xFFFF4081),
                    isSelected: _selectedSection == 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSection = 0),
                  child: _buildStatCard(
                    icon: Icons.folder_open_rounded,
                    label: 'Albums',
                    count: albumsCount.toString(),
                    color: const Color(0xFFFFB300),
                    isSelected: _selectedSection == 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSection = 3),
                  child: _buildStatCard(
                    icon: Icons.delete_outline_rounded,
                    label: 'Trash',
                    count: trashCount.toString(),
                    color: AppColors.textTertiary,
                    isSelected: _selectedSection == 3,
                  ),
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
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.backgroundPanel.withValues(alpha: 0.8) : AppColors.backgroundPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.border,
          width: isSelected ? 1.5 : 0.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
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

  /// Section Header with dynamic controls
  Widget _buildSectionHeader(BuildContext context) {
    String title = 'Albums';
    if (_selectedSection == 1) title = 'All Photos';
    if (_selectedSection == 2) title = 'Favorites';
    if (_selectedSection == 3) title = 'Trash';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (_selectedSection == 0)
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined, color: AppColors.primary),
              onPressed: () => _showCreateAlbumDialog(context),
              tooltip: 'New Album',
            ),
        ],
      ),
    );
  }

  Widget _buildActiveSectionContent(LibraryLoaded state) {
    if (_selectedSection == 0) {
      if (state.albums.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.folder_open_rounded, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No albums created yet',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AlbumCard(album: state.albums[index]);
          },
          childCount: state.albums.length,
        ),
      );
    } else if (_selectedSection == 1) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: PhotoGrid(
            photos: state.allPhotos,
            emptyMessage: 'No photos imported yet',
            isSelectionMode: _isSelectionMode,
            selectedPhotoIds: _selectedPhotoIds,
            onToggleSelection: (photo) {
              setState(() {
                if (_selectedPhotoIds.contains(photo.id)) {
                  _selectedPhotoIds.remove(photo.id);
                } else {
                  _selectedPhotoIds.add(photo.id);
                }
              });
            },
          ),
        ),
      );
    } else if (_selectedSection == 2) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: PhotoGrid(
            photos: state.favoritePhotos,
            emptyMessage: 'No favorite photos yet',
            isSelectionMode: _isSelectionMode,
            selectedPhotoIds: _selectedPhotoIds,
            onToggleSelection: (photo) {
              setState(() {
                if (_selectedPhotoIds.contains(photo.id)) {
                  _selectedPhotoIds.remove(photo.id);
                } else {
                  _selectedPhotoIds.add(photo.id);
                }
              });
            },
          ),
        ),
      );
    } else {
      if (state.trashPhotos.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'Trash is empty',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.trashPhotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final photo = state.trashPhotos[index];
              return GestureDetector(
                onTap: () => _showTrashOptions(context, photo),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo.path),
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black38,
                        child: const Center(
                          child: Icon(Icons.restore_from_trash_rounded, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _showTrashOptions(BuildContext context, Photo photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Trash Options',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.restore_rounded, color: Colors.greenAccent),
                title: const Text('Restore Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<LibraryBloc>().add(
                        UpdatePhotoTrash(photoId: photo.id, isTrash: false),
                      );
                  Navigator.pop(bottomSheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                title: const Text('Delete Permanently', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  context.read<LibraryBloc>().add(
                        DeletePhotoPermanentlyEvent(photoId: photo.id),
                      );
                  Navigator.pop(bottomSheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateAlbumDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('New Album', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter album name',
              hintStyle: const TextStyle(color: Colors.white30),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  BlocProvider.of<LibraryBloc>(context).add(CreateNewAlbum(name: name));
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Create', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  // ─── Batch Operations UI & Logics ─────────────────────

  Widget _buildBottomBatchBar(BuildContext context, LibraryLoaded state) {
    final List<Photo> activePhotos = _selectedSection == 1 ? state.allPhotos : state.favoritePhotos;
    final hasSelection = _selectedPhotoIds.isNotEmpty;
    final hasCopied = CopiedSettingsHelper.hasCopiedParameters;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF11121A).withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFF262633), width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Apply Preset
            _buildBottomBarButton(
              icon: Icons.style_rounded,
              label: 'Preset',
              isEnabled: hasSelection,
              onTap: () => _showBatchPresetBottomSheet(context, activePhotos),
            ),
            // Paste Settings
            _buildBottomBarButton(
              icon: Icons.paste_rounded,
              label: 'Tempel',
              isEnabled: hasSelection && hasCopied,
              onTap: () => _applyBatchPasteSettings(activePhotos),
            ),
            // Batch Export
            _buildBottomBarButton(
              icon: Icons.ios_share_rounded,
              label: 'Ekspor',
              isEnabled: hasSelection,
              onTap: () => _showBatchExportDialog(context, activePhotos),
            ),
            // Favorite Toggle
            _buildBottomBarButton(
              icon: Icons.favorite_rounded,
              label: 'Favorit',
              isEnabled: hasSelection,
              onTap: () => _executeBatchFavorite(context, activePhotos),
            ),
            // Trash
            _buildBottomBarButton(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus',
              isEnabled: hasSelection,
              color: Colors.redAccent,
              onTap: () => _executeBatchTrash(context, activePhotos),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarButton({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
    Color? color,
  }) {
    final activeColor = color ?? const Color(0xFF0A84FF);
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? activeColor : Colors.white24,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white70 : Colors.white24,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  StateSetter? _dialogStateSetter;
  String _dialogTitle = '';
  String _dialogMessage = '';

  void _showProgressDialog(String title, String message) {
    _dialogTitle = title;
    _dialogMessage = message;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            _dialogStateSetter = setState;
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A84FF)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _dialogTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dialogMessage,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateProgressDialog(String title, String message) {
    if (_dialogStateSetter != null) {
      _dialogStateSetter!(() {
        _dialogTitle = title;
        _dialogMessage = message;
      });
    }
  }

  void _showBatchPresetBottomSheet(BuildContext context, List<Photo> activePhotos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return FutureBuilder<List<Preset>>(
          future: sl<PresetRepository>().getPresets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text('Tidak ada preset tersedia', style: TextStyle(color: Colors.white70)),
                ),
              );
            }
            final presets = snapshot.data!;
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Pilih Preset untuk Diterapkan',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: presets.length,
                      itemBuilder: (context, index) {
                        final preset = presets[index];
                        return ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0A84FF),
                                  Colors.purpleAccent.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.style_rounded, color: Colors.white, size: 18),
                          ),
                          title: Text(preset.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(preset.category.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          onTap: () async {
                            Navigator.pop(bottomSheetContext);
                            _applyBatchPreset(activePhotos, preset);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _applyBatchPreset(List<Photo> activePhotos, Preset preset) async {
    setState(() {
      _isLoadingBatch = true;
    });

    _showProgressDialog('Menerapkan Preset...', 'Memproses foto...');

    try {
      int count = 0;
      for (final id in _selectedPhotoIds) {
        count++;
        _updateProgressDialog('Menerapkan Preset...', 'Memproses foto $count dari ${_selectedPhotoIds.length}...');

        final photo = activePhotos.firstWhere((p) => p.id == id);
        final sessionResult = await sl<EditorRepository>().getSession(id);

        final session = await sessionResult.fold(
          (failure) async {
            final startResult = await sl<EditorRepository>().startSession(id, photo.path);
            return startResult.fold((_) => null, (s) => s);
          },
          (s) => s,
        );

        if (session != null) {
          final updatedSession = session.copyWith(currentParameters: preset.parameters);
          await sl<EditorRepository>().saveSession(updatedSession);
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _toggleSelectionMode(); // Exit selection mode
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menerapkan preset "${preset.name}" ke $count foto'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menerapkan preset: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingBatch = false;
      });
    }
  }

  Future<void> _applyBatchPasteSettings(List<Photo> activePhotos) async {
    if (!CopiedSettingsHelper.hasCopiedParameters) return;

    setState(() {
      _isLoadingBatch = true;
    });

    _showProgressDialog('Menempel Pengaturan...', 'Memproses foto...');

    try {
      int count = 0;
      final params = CopiedSettingsHelper.copiedParameters!;
      for (final id in _selectedPhotoIds) {
        count++;
        _updateProgressDialog('Menempel Pengaturan...', 'Memproses foto $count dari ${_selectedPhotoIds.length}...');

        final photo = activePhotos.firstWhere((p) => p.id == id);
        final sessionResult = await sl<EditorRepository>().getSession(id);

        final session = await sessionResult.fold(
          (failure) async {
            final startResult = await sl<EditorRepository>().startSession(id, photo.path);
            return startResult.fold((_) => null, (s) => s);
          },
          (s) => s,
        );

        if (session != null) {
          final updatedSession = session.copyWith(currentParameters: params);
          await sl<EditorRepository>().saveSession(updatedSession);
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _toggleSelectionMode(); // Exit selection mode
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menempel pengaturan ke $count foto'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menempel pengaturan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingBatch = false;
      });
    }
  }

  void _showBatchExportDialog(BuildContext context, List<Photo> activePhotos) {
    String format = 'jpeg';
    double quality = 90.0;
    double scale = 1.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.ios_share_rounded, color: Color(0xFF0A84FF), size: 24),
                  SizedBox(width: 10),
                  Text('Ekspor Massal', style: TextStyle(color: Colors.white)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FORMAT GAMBAR', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => format = 'jpeg'),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: format == 'jpeg' ? const Color(0xFF1E2E4A) : Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: format == 'jpeg' ? const Color(0xFF0A84FF) : Colors.white12),
                              ),
                              child: Center(
                                child: Text('JPEG', style: TextStyle(color: format == 'jpeg' ? const Color(0xFF0A84FF) : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => format = 'png'),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: format == 'png' ? const Color(0xFF1E2E4A) : Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: format == 'png' ? const Color(0xFF0A84FF) : Colors.white12),
                              ),
                              child: Center(
                                child: Text('PNG', style: TextStyle(color: format == 'png' ? const Color(0xFF0A84FF) : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (format == 'jpeg') ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('KUALITAS KOMPRESI', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('${quality.toInt()}%', style: const TextStyle(color: Color(0xFF0A84FF), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Slider(
                        value: quality,
                        min: 10.0,
                        max: 100.0,
                        divisions: 9,
                        activeColor: const Color(0xFF0A84FF),
                        inactiveColor: Colors.white10,
                        onChanged: (val) => setDialogState(() => quality = val),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('UKURAN OUTPUT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<double>(
                      value: scale,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E2E),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0A84FF))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1.0, child: Text('Asli (100%)')),
                        DropdownMenuItem(value: 0.5, child: Text('Sedang (50%)')),
                        DropdownMenuItem(value: 0.25, child: Text('Kecil (25%)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => scale = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _executeBatchExport(activePhotos, format, quality.toInt(), scale);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Ekspor'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executeBatchExport(
    List<Photo> activePhotos,
    String format,
    int quality,
    double scale,
  ) async {
    setState(() {
      _isLoadingBatch = true;
    });

    final selectedPhotos = activePhotos.where((p) => _selectedPhotoIds.contains(p.id)).toList();
    _showProgressDialog('Mengekspor Foto...', 'Menyiapkan...');

    try {
      String outputDir;
      if (Platform.isWindows) {
        final downloadsDir = await getDownloadsDirectory();
        outputDir = downloadsDir?.path ?? 'C:/Users/ACER/Downloads';
      } else if (Platform.isAndroid) {
        outputDir = '/storage/emulated/0/Download';
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        outputDir = docsDir.path;
      }
      outputDir = outputDir.replaceAll('\\', '/');

      final exporter = BatchExporter(editorRepository: sl<EditorRepository>());

      await exporter.exportPhotos(
        selectedPhotos,
        outputDirectory: outputDir,
        format: format,
        quality: quality,
        scale: scale,
        onProgress: (current, total, path) {
          final filename = p.basename(path);
          _updateProgressDialog(
            'Mengekspor Foto ($current/$total)...',
            'Sedang merender dan menyimpan $filename...',
          );
        },
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _toggleSelectionMode(); // Exit selection mode
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengekspor ${selectedPhotos.length} foto ke folder Unduhan'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingBatch = false;
      });
    }
  }

  Future<void> _executeBatchFavorite(BuildContext context, List<Photo> activePhotos) async {
    setState(() {
      _isLoadingBatch = true;
    });

    try {
      final selectedPhotos = activePhotos.where((p) => _selectedPhotoIds.contains(p.id)).toList();
      final anyUnfavorited = selectedPhotos.any((p) => !p.isFavorite);
      final newValue = anyUnfavorited;

      final bloc = context.read<LibraryBloc>();
      for (final photo in selectedPhotos) {
        bloc.add(UpdatePhotoFavorite(photoId: photo.id, isFavorite: newValue));
      }

      _toggleSelectionMode();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue ? 'Berhasil memfavoritkan ${selectedPhotos.length} foto' : 'Berhasil menghapus favorit ${selectedPhotos.length} foto'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoadingBatch = false;
      });
    }
  }

  Future<void> _executeBatchTrash(BuildContext context, List<Photo> activePhotos) async {
    setState(() {
      _isLoadingBatch = true;
    });

    try {
      final selectedPhotos = activePhotos.where((p) => _selectedPhotoIds.contains(p.id)).toList();
      final bloc = context.read<LibraryBloc>();
      for (final photo in selectedPhotos) {
        bloc.add(UpdatePhotoTrash(photoId: photo.id, isTrash: true));
      }

      _toggleSelectionMode();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil memindahkan ${selectedPhotos.length} foto ke tempat sampah'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoadingBatch = false;
      });
    }
  }
}
