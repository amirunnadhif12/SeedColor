import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/launch_utils.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/photo.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../widgets/album_card.dart';
import '../widgets/photo_grid.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // 0: Albums, 1: All Photos, 2: Favorites, 3: Trash
  int _selectedSection = 0;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
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
            if (state is LibraryLoaded) {
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
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(child: _buildHeader()),

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
}
