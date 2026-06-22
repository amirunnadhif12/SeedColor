import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_libraw/flutter_libraw.dart';
import 'package:path/path.dart' as p;

class RawMetadata {
  final String make;
  final String model;
  final int width;
  final int height;
  final Uint8List thumbnailBytes;

  RawMetadata({
    required this.make,
    required this.model,
    required this.width,
    required this.height,
    required this.thumbnailBytes,
  });
}

class RawDatasource {
  bool _isLibRawLoaded = false;
  FlutterLibRawBindings? _bindings;

  RawDatasource() {
    _initLibRaw();
  }

  bool get isAvailable => _isLibRawLoaded;

  /// Inisialisasi binding FFI untuk LibRaw
  void _initLibRaw() {
    try {
      String? libPath;
      if (Platform.isWindows) {
        libPath = p.join(Directory.current.path, 'libraw.dll');
      } else if (Platform.isAndroid) {
        libPath = 'libraw.so'; // Sistem Android memuat .so dari JNI libs otomatis
      } else if (Platform.isMacOS) {
        libPath = 'libraw.dylib';
      } else if (Platform.isLinux) {
        libPath = 'libraw.so';
      }

      if (libPath != null) {
        final file = File(libPath);
        // Di Windows, cek keberadaan file secara eksplisit
        if (Platform.isWindows && !file.existsSync()) {
          debugPrint('LibRaw DLL tidak ditemukan di ${file.absolute.path}, menggunakan fallback Dart.');
          return;
        }

        final dylib = DynamicLibrary.open(libPath);
        _bindings = FlutterLibRawBindings(dylib);
        _isLibRawLoaded = true;
        debugPrint('LibRaw FFI berhasil dimuat dari $libPath.');
      }
    } catch (e) {
      debugPrint('Gagal memuat LibRaw FFI ($e), menggunakan fallback Dart parser.');
    }
  }

  /// Ekstraksi metadata dan thumbnail JPEG dari file RAW
  Future<RawMetadata?> extractMetadataAndThumbnail(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    // 1. Coba dekode menggunakan LibRaw jika tersedia
    if (_isLibRawLoaded && _bindings != null) {
      try {
        final ptr = _bindings!.libraw_init(0);
        if (ptr != nullptr) {
          final filePathPtr = filePath.toNativeUtf8().cast<Uint8>();
          final openResult = _bindings!.libraw_open_file(ptr, filePathPtr);
          calloc.free(filePathPtr);

          if (openResult == 0) {
            // Unpack thumbnail
            final unpackResult = _bindings!.libraw_unpack_thumb(ptr);
            if (unpackResult == 0) {
              // Dapatkan bytes thumbnail dari struct thumbnail
              final thumbPtr = ptr.ref.thumbnail.thumb;
              final length = ptr.ref.thumbnail.tlength;

              if (thumbPtr != nullptr && length > 0) {
                final bytes = thumbPtr.cast<Uint8>().asTypedList(length);
                final copiedBytes = Uint8List.fromList(bytes);

                // Dapatkan dimensi dan info kamera
                final makeBytes = <int>[];
                for (int i = 0; i < 64; i++) {
                  final char = ptr.ref.idata.make[i];
                  if (char == 0) break;
                  makeBytes.add(char);
                }
                final make = String.fromCharCodes(makeBytes);

                final modelBytes = <int>[];
                for (int i = 0; i < 64; i++) {
                  final char = ptr.ref.idata.model[i];
                  if (char == 0) break;
                  modelBytes.add(char);
                }
                final model = String.fromCharCodes(modelBytes);
                final width = ptr.ref.sizes.width;
                final height = ptr.ref.sizes.height;

                _bindings!.libraw_close(ptr);
                return RawMetadata(
                  make: make,
                  model: model,
                  width: width,
                  height: height,
                  thumbnailBytes: copiedBytes,
                );
              }
            }
            _bindings!.libraw_close(ptr);
          }
        }
      } catch (e) {
        debugPrint('Gagal memproses dengan LibRaw FFI: $e. Fallback ke Dart parser.');
      }
    }

    // 2. Fallback: Ekstraksi menggunakan Pure Dart TIFF/DNG parser
    try {
      final bytes = await file.readAsBytes();
      return _parseTiffRaw(bytes);
    } catch (e) {
      debugPrint('Pure Dart RAW parser gagal mengekstrak metadata: $e');
      return null;
    }
  }



  /// Pure Dart TIFF/DNG Parser untuk membaca EXIF dan mengekstrak embedded JPEG
  RawMetadata? _parseTiffRaw(Uint8List bytes) {
    if (bytes.length < 8) return null;

    final byteData = ByteData.sublistView(bytes);
    final isLittleEndian = byteData.getUint16(0, Endian.little) == 0x4949; // 'II'

    final endian = isLittleEndian ? Endian.little : Endian.big;
    final magic = byteData.getUint16(2, endian);
    if (magic != 42) return null; // Magic TIFF must be 42

    final firstIfdOffset = byteData.getUint32(4, endian);

    int? jpegOffset;
    int? jpegLength;
    int width = 0;
    int height = 0;
    String make = 'RAW Camera';
    String model = 'Sensor';

    // Pencarian rekursif untuk IFD
    void parseIfd(int offset) {
      if (offset == 0 || offset >= bytes.length) return;

      if (offset + 2 > bytes.length) return;
      final numEntries = byteData.getUint16(offset, endian);
      int entryOffset = offset + 2;

      List<int> subIfdOffsets = [];

      for (int i = 0; i < numEntries; i++) {
        if (entryOffset + 12 > bytes.length) break;

        final tag = byteData.getUint16(entryOffset, endian);
        final type = byteData.getUint16(entryOffset + 2, endian);
        final count = byteData.getUint32(entryOffset + 4, endian);
        final valOffset = byteData.getUint32(entryOffset + 8, endian);

        if (tag == 0x0201) { // JPEGInterchangeFormat (Offset to preview)
          jpegOffset = valOffset;
        } else if (tag == 0x0202) { // JPEGInterchangeFormatLength (Size of preview)
          jpegLength = valOffset;
        } else if (tag == 0x0112) { // Orientation
          // Orientasi EXIF jika diperlukan
        } else if (tag == 0x010f) { // Make
          make = _readString(bytes, valOffset, count);
        } else if (tag == 0x0110) { // Model
          model = _readString(bytes, valOffset, count);
        } else if (tag == 0x0100) { // ImageWidth
          if (type == 3) { // SHORT
            width = byteData.getUint16(entryOffset + 8, endian);
          } else if (type == 4) { // LONG
            width = valOffset;
          }
        } else if (tag == 0x0101) { // ImageLength (Height)
          if (type == 3) { // SHORT
            height = byteData.getUint16(entryOffset + 8, endian);
          } else if (type == 4) { // LONG
            height = valOffset;
          }
        } else if (tag == 0x014a) { // SubIFDs
          if (count == 1) {
            subIfdOffsets.add(valOffset);
          } else {
            for (int j = 0; j < count; j++) {
              final subOffsetAddress = valOffset + j * 4;
              if (subOffsetAddress + 4 <= bytes.length) {
                subIfdOffsets.add(byteData.getUint32(subOffsetAddress, endian));
              }
            }
          }
        }

        entryOffset += 12;
      }

      // Cari JPEG di SubIFDs jika belum ketemu
      if (jpegOffset == null) {
        for (final subOffset in subIfdOffsets) {
          parseIfd(subOffset);
          if (jpegOffset != null) break;
        }
      }

      // Jika belum ketemu juga, lanjut ke next IFD
      if (jpegOffset == null && entryOffset + 4 <= bytes.length) {
        final nextIfdOffset = byteData.getUint32(entryOffset, endian);
        parseIfd(nextIfdOffset);
      }
    }

    parseIfd(firstIfdOffset);

    if (jpegOffset != null && jpegLength != null) {
      if (jpegOffset! + jpegLength! <= bytes.length) {
        final thumbnailBytes = bytes.sublist(jpegOffset!, jpegOffset! + jpegLength!);
        
        // Coba baca dimensi dari JPEG stream jika TIFF ImageWidth/ImageHeight kosong
        if (width == 0 || height == 0) {
          final dimensions = _parseJpegDimensions(thumbnailBytes);
          if (dimensions != null) {
            width = dimensions[0];
            height = dimensions[1];
          } else {
            width = 1920; // Default fallback
            height = 1080;
          }
        }

        return RawMetadata(
          make: make.trim(),
          model: model.trim(),
          width: width,
          height: height,
          thumbnailBytes: thumbnailBytes,
        );
      }
    }

    return null;
  }

  String _readString(Uint8List bytes, int offset, int count) {
    if (offset + count > bytes.length) return 'Unknown';
    try {
      final subList = bytes.sublist(offset, offset + count);
      // Buang byte NULL di akhir string
      final end = subList.indexOf(0);
      return String.fromCharCodes(end == -1 ? subList : subList.sublist(0, end));
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Membaca dimensi gambar dari JPEG header (SOF0 marker)
  List<int>? _parseJpegDimensions(Uint8List jpegBytes) {
    try {
      if (jpegBytes.length < 4) return null;
      if (jpegBytes[0] != 0xFF || jpegBytes[1] != 0xD8) return null; // Not a valid JPEG

      int idx = 2;
      final byteData = ByteData.sublistView(jpegBytes);
      while (idx < jpegBytes.length - 8) {
        final marker = jpegBytes[idx];
        final nextMarker = jpegBytes[idx + 1];

        if (marker == 0xFF) {
          // SOF0 (Start of Frame 0) marker is 0xC0 or SOF2 is 0xC2
          if (nextMarker == 0xC0 || nextMarker == 0xC2) {
            // SOF header format:
            // marker length (2 bytes), precision (1 byte), height (2 bytes), width (2 bytes)
            final height = byteData.getUint16(idx + 5, Endian.big);
            final width = byteData.getUint16(idx + 7, Endian.big);
            return [width, height];
          } else {
            // Skip marker
            final length = byteData.getUint16(idx + 2, Endian.big);
            idx += 2 + length;
          }
        } else {
          idx++;
        }
      }
    } catch (_) {
      // Abaikan jika gagal parse JPEG header
    }
    return null;
  }
}
