import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/photo.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';

class PhotoThumbnail extends StatelessWidget {
  final Photo photo;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool>? onToggleSelection;

  const PhotoThumbnail({
    super.key,
    required this.photo,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onToggleSelection?.call(!isSelected);
        } else {
          context.push('/editor/${photo.id}');
        }
      },
      onLongPress: isSelectionMode ? null : () => _showActionsBottomSheet(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
                );
              },
            ),

            // Gradient shade for overlays
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),

            // Selection Circle/Checkmark Overlay
            if (isSelectionMode)
              Positioned(
                top: 8,
                left: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0A84FF) : Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0A84FF) : Colors.white70,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: isSelected ? Colors.white : Colors.transparent,
                    size: 12,
                  ),
                ),
              ),

            // Top-right: Favorite Heart
            if (photo.isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF4081),
                    size: 14,
                  ),
                ),
              ),

            // Bottom-left: Rating Stars
            if (photo.rating > 0)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB300),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${photo.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<LibraryBloc>(),
          child: Builder(
            builder: (blocContext) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Photo Actions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 24),

                      // Favorite toggle
                      ListTile(
                        leading: Icon(
                          photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: photo.isFavorite ? const Color(0xFFFF4081) : Colors.white70,
                        ),
                        title: Text(
                          photo.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          blocContext.read<LibraryBloc>().add(
                                UpdatePhotoFavorite(
                                  photoId: photo.id,
                                  isFavorite: !photo.isFavorite,
                                ),
                              );
                          Navigator.pop(bottomSheetContext);
                        },
                      ),

                      // Rating Selector
                      ListTile(
                        leading: const Icon(Icons.star_outline_rounded, color: Colors.white70),
                        title: const Text('Set Rating', style: TextStyle(color: Colors.white)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return GestureDetector(
                                onTap: () {
                                  blocContext.read<LibraryBloc>().add(
                                        UpdatePhotoRating(
                                          photoId: photo.id,
                                          rating: index,
                                        ),
                                      );
                                  Navigator.pop(bottomSheetContext);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: photo.rating == index
                                        ? const Color(0xFF0A84FF)
                                        : Colors.white10,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      color: photo.rating == index ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      const Divider(color: Colors.white12, height: 24),

                      // Manage Keywords
                      ListTile(
                        leading: const Icon(Icons.tag_rounded, color: Colors.white70),
                        title: const Text('Manage Keywords', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _showManageKeywordsDialog(context, photo);
                        },
                      ),

                      // Move to Trash
                      ListTile(
                        leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        title: const Text('Move to Trash', style: TextStyle(color: Colors.redAccent)),
                        onTap: () {
                          blocContext.read<LibraryBloc>().add(
                                UpdatePhotoTrash(
                                  photoId: photo.id,
                                  isTrash: true,
                                ),
                              );
                          Navigator.pop(bottomSheetContext);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showManageKeywordsDialog(BuildContext context, Photo photo) {
    final textController = TextEditingController();
    final List<String> tempKeywords = List.from(photo.keywords);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            void addKeyword() {
              final newTag = textController.text.trim();
              if (newTag.isNotEmpty && !tempKeywords.contains(newTag)) {
                setDialogState(() {
                  tempKeywords.add(newTag);
                });
                textController.clear();
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Manage Keywords',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add keyword...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0A84FF)),
                          onPressed: addKeyword,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0A84FF)),
                        ),
                      ),
                      onSubmitted: (_) => addKeyword(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Keywords:',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (tempKeywords.isEmpty)
                      const Text(
                        'No keywords added yet.',
                        style: TextStyle(color: Colors.white30, fontSize: 12, fontStyle: FontStyle.italic),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tempKeywords.map((tag) {
                          return Chip(
                            label: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Colors.white70),
                            onDeleted: () {
                              setDialogState(() {
                                tempKeywords.remove(tag);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                TextButton(
                  onPressed: () {
                    context.read<LibraryBloc>().add(
                          UpdatePhotoKeywords(
                            photoId: photo.id,
                            keywords: tempKeywords,
                          ),
                        );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save', style: TextStyle(color: Color(0xFF0A84FF), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
