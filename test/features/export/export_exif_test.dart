import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:seed_color/features/editor/data/repositories/editor_repository_impl.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

void main() {
  test('injectEditMetadata preserves original EXIF and injects editing parameters', () {
    // 1. Create a dummy original image bytes with EXIF metadata
    final originalImage = img.Image(width: 4, height: 4);
    final originalExif = img.ExifData();
    originalExif.directories['ifd0'] = img.IfdDirectory();
    originalExif.directories['ifd0']!.sub['exif'] = img.IfdDirectory();
    
    // Set Make tag (0x010f)
    originalExif.directories['ifd0']![0x010f] = img.IfdValueAscii.string('SeedTestCamera');
    originalImage.exif = originalExif;

    final originalJpgBytes = Uint8List.fromList(img.encodeJpg(originalImage));

    // 2. Define non-default editing parameters
    final updatedParams = EditParameters.identity().copyWith(
      exposure: 0.85,
      contrast: 15.0,
      saturation: -5.0,
    );

    // 3. Inject metadata using the helper
    final resultExif = injectEditMetadata(originalJpgBytes, updatedParams);

    // 4. Verify EXIF fields
    // Verify original tag is preserved
    final makeTag = resultExif.directories['ifd0']?[0x010f];
    expect(makeTag, isNotNull);
    expect(makeTag.toString(), equals('SeedTestCamera'));

    // Verify software tag is present
    final softwareTag = resultExif.directories['ifd0']?[0x0131];
    expect(softwareTag, isNotNull);
    expect(softwareTag.toString(), equals('SeedColor'));

    // Verify UserComment tag in exif sub-directory contains the correct JSON
    final userComment = resultExif.exifIfd[0x9286];
    expect(userComment, isNotNull);
    
    final jsonStr = userComment.toString();
    final Map<String, dynamic> metadata = jsonDecode(jsonStr);
    expect(metadata['exposure'], equals(0.85));
    expect(metadata['contrast'], equals(15.0));
    expect(metadata['saturation'], equals(-5.0));
  });
}
