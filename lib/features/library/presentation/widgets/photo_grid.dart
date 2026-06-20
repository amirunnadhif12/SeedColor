import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/photo.dart';
import 'photo_thumbnail.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final String emptyMessage;

  const PhotoGrid({
    super.key,
    required this.photos,
    this.emptyMessage = 'No photos yet',
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.image_search_rounded,
                  color: Colors.white30,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        return PhotoThumbnail(photo: photos[index]);
      },
    );
  }
}
