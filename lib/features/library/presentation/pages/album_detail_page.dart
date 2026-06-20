import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/library_repository.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../widgets/photo_thumbnail.dart';

class AlbumDetailPage extends StatefulWidget {
  final String albumId;
  final String albumName;

  const AlbumDetailPage({
    super.key,
    required this.albumId,
    required this.albumName,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  final LibraryRepository _repository = sl<LibraryRepository>();
  List<Photo> _photos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final photos = await _repository.getPhotosInAlbum(widget.albumId);
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryBloc, LibraryState>(
      listener: (context, state) {
        if (state is LibraryLoaded) {
          _loadPhotos();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundPanel,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.albumName,
            style: AppTypography.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white70),
              onPressed: () => _showAddPhotosDialog(context),
              tooltip: 'Add Photos',
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No photos in this album yet',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddPhotosDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Photos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        itemCount: _photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return PhotoThumbnail(photo: photo);
        },
      ),
    );
  }

  void _showAddPhotosDialog(BuildContext context) async {
    try {
      final allPhotos = await _repository.getAllPhotos();
      final currentPhotoIds = _photos.map((p) => p.id).toSet();
      final availablePhotos = allPhotos.where((p) => !currentPhotoIds.contains(p.id)).toList();

      if (!context.mounted) return;

      if (availablePhotos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All library photos are already in this album.')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E2E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (dialogContext) {
          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Add Photos to Album',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white12, height: 24),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: availablePhotos.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final photo = availablePhotos[index];
                      return GestureDetector(
                        onTap: () {
                          BlocProvider.of<LibraryBloc>(context).add(
                            AddPhotoToAlbumEvent(
                              albumId: widget.albumId,
                              photoId: photo.id,
                            ),
                          );
                          Navigator.pop(dialogContext);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(photo.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load available photos: $e')),
        );
      }
    }
  }
}
