import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/features/editor/data/datasources/raw_datasource.dart';

void main() {
  late RawDatasource datasource;
  late String tempFilePath;

  setUp(() {
    datasource = RawDatasource();
    tempFilePath = '${Directory.systemTemp.path}/test_image.dng';
  });

  tearDown(() async {
    final file = File(tempFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  });

  test('extractMetadataAndThumbnail should extract thumbnail and metadata using TIFF fallback', () async {
    // 1. Create a mock JPEG thumbnail with SOF0 marker for width=20, height=10
    final jpegBytes = [
      0xFF, 0xD8, // SOI
      0xFF, 0xC0, // SOF0
      0x00, 0x0B, // Length of SOF0 header (11 bytes)
      0x08, // Precision
      0x00, 0x0A, // Height (10)
      0x00, 0x14, // Width (20)
      0x03, 0x01, 0x11, 0x00, 0x02, 0x11, 0x00, 0x03, 0x11, 0x00 // Component info
    ];

    final jpegOffset = 120;
    final jpegLength = jpegBytes.length;

    // 2. Build mock TIFF/DNG structure
    // Total size: 120 + jpegLength
    final tiffBytes = Uint8List(jpegOffset + jpegLength);
    final byteData = ByteData.sublistView(tiffBytes);

    // Header
    byteData.setUint16(0, 0x4949, Endian.little); // 'II' (Little Endian)
    byteData.setUint16(2, 42, Endian.little); // Magic number
    byteData.setUint32(4, 8, Endian.little); // Offset to 0th IFD

    // 0th IFD
    // Number of entries: 6
    byteData.setUint16(8, 6, Endian.little);

    int entryOffset = 10;

    // Helper to write an IFD entry
    void writeEntry(int tag, int type, int count, int valOffset) {
      byteData.setUint16(entryOffset, tag, Endian.little);
      byteData.setUint16(entryOffset + 2, type, Endian.little);
      byteData.setUint32(entryOffset + 4, count, Endian.little);
      byteData.setUint32(entryOffset + 8, valOffset, Endian.little);
      entryOffset += 12;
    }

    // Write TIFF tags
    writeEntry(0x010f, 2, 8, 82); // Make (ASCII, offset 82)
    writeEntry(0x0110, 2, 6, 90); // Model (ASCII, offset 90)
    writeEntry(0x0100, 4, 1, 20); // ImageWidth (LONG, 20)
    writeEntry(0x0101, 4, 1, 10); // ImageHeight (LONG, 10)
    writeEntry(0x0201, 4, 1, jpegOffset); // JPEGInterchangeFormat (Offset to preview)
    writeEntry(0x0202, 4, 1, jpegLength); // JPEGInterchangeFormatLength

    // Next IFD Offset (0)
    byteData.setUint32(entryOffset, 0, Endian.little);

    // Write strings (Make/Model)
    // Make: "Camera\0"
    final makeStr = 'Camera\u0000';
    for (int i = 0; i < makeStr.length; i++) {
      tiffBytes[82 + i] = makeStr.codeUnitAt(i);
    }
    // Model: "DNG\0"
    final modelStr = 'DNG\u0000';
    for (int i = 0; i < modelStr.length; i++) {
      tiffBytes[90 + i] = modelStr.codeUnitAt(i);
    }

    // Write JPEG bytes at offset
    for (int i = 0; i < jpegBytes.length; i++) {
      tiffBytes[jpegOffset + i] = jpegBytes[i];
    }

    // 3. Write mock TIFF to a temp file
    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(tiffBytes);

    // 4. Test extraction
    final metadata = await datasource.extractMetadataAndThumbnail(tempFilePath);

    expect(metadata, isNotNull);
    expect(metadata!.make, equals('Camera'));
    expect(metadata.model, equals('DNG'));
    expect(metadata.width, equals(20));
    expect(metadata.height, equals(10));
    expect(metadata.thumbnailBytes.length, equals(jpegLength));
    expect(metadata.thumbnailBytes[0], equals(0xFF));
    expect(metadata.thumbnailBytes[1], equals(0xD8));
  });
}
