import 'dart:io';
import 'dart:typed_data';

class LutData {
  final int size; // e.g. 33
  final Uint8List rgbaBytes;

  LutData({required this.size, required this.rgbaBytes});
}

class LutParser {
  static Future<LutData> parse(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('LUT file not found: $filePath');
    }
    final content = await file.readAsString();
    return parseString(content, is3dl: filePath.toLowerCase().endsWith('.3dl'));
  }

  static LutData parseString(String content, {required bool is3dl}) {
    final lines = content.split(RegExp(r'\r?\n'));
    int? size;
    final List<List<double>> points = [];

    if (is3dl) {
      // 3DL format parsing
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        final tokens = line.split(RegExp(r'\s+'));
        if (tokens.isEmpty) continue;

        // The first line containing multiple numbers defines the input grid mesh sizes.
        if (size == null) {
          final numbers = tokens.map((t) => double.tryParse(t)).whereType<double>().toList();
          if (numbers.isNotEmpty) {
            size = numbers.length;
          }
          continue;
        }

        // Subsequent lines are 3D LUT points: R G B
        final rgb = tokens.map((t) => double.tryParse(t)).whereType<double>().toList();
        if (rgb.length >= 3) {
          points.add([rgb[0], rgb[1], rgb[2]]);
        }
      }
    } else {
      // CUBE format parsing
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        if (line.startsWith('LUT_3D_SIZE')) {
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length > 1) {
            size = int.tryParse(parts[1]);
          }
          continue;
        }

        // Skip other metadata like TITLE, LUT_3D_INPUT_RANGE, etc.
        if (line.startsWith('TITLE') ||
            line.startsWith('LUT_3D_INPUT_RANGE') ||
            line.startsWith('LUT_1D_SIZE') ||
            line.startsWith('LUT_1D_INPUT_RANGE') ||
            line.startsWith('DOMAIN_MIN') ||
            line.startsWith('DOMAIN_MAX')) {
          continue;
        }

        final tokens = line.split(RegExp(r'\s+'));
        final rgb = tokens.map((t) => double.tryParse(t)).whereType<double>().toList();
        if (rgb.length >= 3) {
          points.add([rgb[0], rgb[1], rgb[2]]);
        }
      }
    }

    if (size == null) {
      // Infer size if not found in metadata. N^3 = points.length.
      final inferredSize = _cubeRoot(points.length);
      if (inferredSize * inferredSize * inferredSize == points.length) {
        size = inferredSize;
      } else {
        throw Exception('Could not determine LUT size (points count: ${points.length})');
      }
    }

    final totalExpected = size * size * size;
    if (points.length < totalExpected) {
      throw Exception('LUT file has fewer points (${points.length}) than expected ($totalExpected) for size $size');
    }

    // Determine the normalization scale
    double maxVal = 0.0;
    for (final pt in points) {
      if (pt[0] > maxVal) maxVal = pt[0];
      if (pt[1] > maxVal) maxVal = pt[1];
      if (pt[2] > maxVal) maxVal = pt[2];
    }

    double inputScale = 1.0;
    if (maxVal > 1023.0) {
      inputScale = 4095.0;
    } else if (maxVal > 255.0) {
      inputScale = 1023.0;
    } else if (maxVal > 1.0) {
      inputScale = 255.0;
    }

    final rgbaBytes = Uint8List(4 * size * size * size);

    for (int i = 0; i < totalExpected; i++) {
      final pt = points[i];
      final rVal = (pt[0] / inputScale * 255.0).round().clamp(0, 255);
      final gVal = (pt[1] / inputScale * 255.0).round().clamp(0, 255);
      final bVal = (pt[2] / inputScale * 255.0).round().clamp(0, 255);

      int r, g, b;
      if (is3dl) {
        // 3dl: Blue loops fastest, then Green, then Red (slowest)
        r = i ~/ (size * size);
        g = (i % (size * size)) ~/ size;
        b = (i % (size * size)) % size;
      } else {
        // cube: Red loops fastest, then Green, then Blue (slowest)
        b = i ~/ (size * size);
        g = (i % (size * size)) ~/ size;
        r = (i % (size * size)) % size;
      }

      // Lay out horizontally: slice width is size, height is size
      // Slice b is at horizontal offset b * size.
      // Pixel inside slice b has local column r, local row g.
      // So global column x = b * size + r
      // global row y = g
      final x = b * size + r;
      final y = g;
      final idx = 4 * (y * (size * size) + x);

      rgbaBytes[idx] = rVal;
      rgbaBytes[idx + 1] = gVal;
      rgbaBytes[idx + 2] = bVal;
      rgbaBytes[idx + 3] = 255;
    }

    return LutData(size: size, rgbaBytes: rgbaBytes);
  }

  static int _cubeRoot(int n) {
    int low = 1;
    int high = 256;
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final cube = mid * mid * mid;
      if (cube == n) return mid;
      if (cube < n) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return 0;
  }
}
