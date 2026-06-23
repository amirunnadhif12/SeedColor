import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/photo.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/photo_local_datasource.dart';
import '../datasources/album_local_datasource.dart';
import '../../../../core/database/app_database.dart';
import '../../../editor/data/datasources/raw_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final PhotoLocalDataSource photoDataSource;
  final AlbumLocalDataSource albumDataSource;
  final RawDatasource rawDatasource;
  final _uuid = const Uuid();

  LibraryRepositoryImpl({
    required this.photoDataSource,
    required this.albumDataSource,
    required this.rawDatasource,
  });

  @override
  Future<List<Photo>> getAllPhotos() async {
    final datas = await photoDataSource.getAllPhotos();
    return datas.map(_mapPhotoDataToEntity).toList();
  }

  @override
  Future<List<Photo>> getFavoritePhotos() async {
    final datas = await photoDataSource.getFavoritePhotos();
    return datas.map(_mapPhotoDataToEntity).toList();
  }

  @override
  Future<List<Photo>> getTrashPhotos() async {
    final datas = await photoDataSource.getTrashPhotos();
    return datas.map(_mapPhotoDataToEntity).toList();
  }

  @override
  Future<Photo> importPhoto(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileExtension = p.extension(filePath);
    final photoId = _uuid.v4();
    final newFileName = '$photoId$fileExtension';
    final targetPath = p.join(photosDir.path, newFileName);

    // Copy file to target path
    final srcFile = File(filePath);
    await srcFile.copy(targetPath);

    final now = DateTime.now();

    // Check if RAW file extension
    final extLower = fileExtension.toLowerCase();
    final isRaw = extLower == '.dng' ||
        extLower == '.cr2' ||
        extLower == '.nef' ||
        extLower == '.arw';

    String thumbnailPath = targetPath;
    if (isRaw) {
      try {
        final metadata = await rawDatasource.extractMetadataAndThumbnail(targetPath);
        if (metadata != null && metadata.thumbnailBytes.isNotEmpty) {
          final thumbFileName = '${photoId}_thumb.jpg';
          final thumbPath = p.join(photosDir.path, thumbFileName);
          final thumbFile = File(thumbPath);
          await thumbFile.writeAsBytes(metadata.thumbnailBytes);
          thumbnailPath = thumbPath;
        }
      } catch (e) {
        // Fallback to targetPath if thumbnail extraction fails
        thumbnailPath = targetPath;
      }
    }

    final photoData = PhotoData(
      id: photoId,
      path: targetPath,
      thumbnailPath: thumbnailPath,
      rating: 0,
      isFavorite: false,
      isTrash: false,
      createdAt: now,
    );

    await photoDataSource.insertPhoto(photoData);
    return _mapPhotoDataToEntity(photoData);
  }

  @override
  Future<void> updatePhotoRating(String id, int rating) {
    return photoDataSource.updatePhotoRating(id, rating);
  }

  @override
  Future<void> updatePhotoFavorite(String id, bool isFavorite) {
    return photoDataSource.updatePhotoFavorite(id, isFavorite);
  }

  @override
  Future<void> updatePhotoTrash(String id, bool isTrash) {
    return photoDataSource.updatePhotoTrash(id, isTrash);
  }

  @override
  Future<void> deletePhotoPermanently(String id) async {
    final photo = await photoDataSource.getPhotoById(id);
    if (photo != null) {
      try {
        final origFile = File(photo.path);
        if (await origFile.exists()) {
          await origFile.delete();
        }
        if (photo.thumbnailPath != null && photo.thumbnailPath != photo.path) {
          final thumbFile = File(photo.thumbnailPath!);
          if (await thumbFile.exists()) {
            await thumbFile.delete();
          }
        }
      } catch (_) {
        // Ignore file delete errors to ensure database stays clean
      }
    }
    return photoDataSource.deletePhotoPermanently(id);
  }

  @override
  Future<List<Album>> getAlbums() async {
    final list = await albumDataSource.getAlbumsWithStats();
    return list.map((item) {
      return Album(
        id: item.album.id,
        name: item.album.name,
        photoCount: item.photoCount,
        coverPhotoPath: item.coverPhotoPath,
        createdAt: item.album.createdAt,
      );
    }).toList();
  }

  @override
  Future<Album> createAlbum(String name) async {
    final albumId = _uuid.v4();
    final now = DateTime.now();
    final albumData = AlbumData(
      id: albumId,
      name: name,
      createdAt: now,
    );

    await albumDataSource.createAlbum(albumData);
    return Album(
      id: albumId,
      name: name,
      photoCount: 0,
      coverPhotoPath: null,
      createdAt: now,
    );
  }

  @override
  Future<void> addPhotoToAlbum(String albumId, String photoId) {
    return albumDataSource.addPhotoToAlbum(albumId, photoId);
  }

  @override
  Future<void> removePhotoFromAlbum(String albumId, String photoId) {
    return albumDataSource.removePhotoFromAlbum(albumId, photoId);
  }

  @override
  Future<List<Photo>> getPhotosInAlbum(String albumId) async {
    final list = await albumDataSource.getPhotosInAlbum(albumId);
    return list.map(_mapPhotoDataToEntity).toList();
  }

  @override
  Future<void> updatePhotoKeywords(String id, List<String> keywords) {
    final keywordsStr = keywords.isEmpty ? null : keywords.join(',');
    return photoDataSource.updatePhotoKeywords(id, keywordsStr);
  }

  Photo _mapPhotoDataToEntity(PhotoData data) {
    final keywordList = data.keywords != null && data.keywords!.isNotEmpty
        ? data.keywords!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    return Photo(
      id: data.id,
      path: data.path,
      thumbnailPath: data.thumbnailPath,
      rating: data.rating,
      isFavorite: data.isFavorite,
      isTrash: data.isTrash,
      createdAt: data.createdAt,
      keywords: keywordList,
    );
  }
}
