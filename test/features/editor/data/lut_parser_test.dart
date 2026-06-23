import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/features/editor/data/datasources/lut_parser.dart';

void main() {
  group('LutParser Unit Tests', () {
    test('should parse .cube string correctly with fast red loop', () {
      const cubeContent = '''
# Created by SeedColor Test
TITLE "Test Cube"
LUT_3D_SIZE 2

0.0 0.0 0.0
1.0 0.0 0.0
0.0 1.0 0.0
1.0 1.0 0.0
0.0 0.0 1.0
1.0 0.0 1.0
0.0 1.0 1.0
1.0 1.0 1.0
''';

      final lutData = LutParser.parseString(cubeContent, is3dl: false);
      expect(lutData.size, 2);
      expect(lutData.rgbaBytes.length, 32);

      // Verify the layout:
      // index = b * N^2 + g * N + r.
      // Slices are laid out horizontally: x = b * size + r, y = g.
      // Total width = size * size = 4, height = size = 2.
      // Index in rgbaBytes = 4 * (y * width + x) = 4 * (g * 4 + b * 2 + r).
      
      // Let's verify (r=0, g=0, b=0): index = 4 * (0 + 0 + 0) = 0. Should be [0, 0, 0, 255]
      expect(lutData.rgbaBytes[0], 0);
      expect(lutData.rgbaBytes[1], 0);
      expect(lutData.rgbaBytes[2], 0);
      expect(lutData.rgbaBytes[3], 255);

      // Let's verify (r=1, g=0, b=0): index = 4 * (0 + 0 + 1) = 4. Should be [255, 0, 0, 255]
      expect(lutData.rgbaBytes[4], 255);
      expect(lutData.rgbaBytes[5], 0);
      expect(lutData.rgbaBytes[6], 0);
      expect(lutData.rgbaBytes[7], 255);

      // Let's verify (r=0, g=1, b=0): index = 4 * (1 * 4 + 0 + 0) = 16. Should be [0, 255, 0, 255]
      expect(lutData.rgbaBytes[16], 0);
      expect(lutData.rgbaBytes[17], 255);
      expect(lutData.rgbaBytes[18], 0);
      expect(lutData.rgbaBytes[19], 255);

      // Let's verify (r=1, g=1, b=1): index = 4 * (1 * 4 + 1 * 2 + 1) = 4 * 7 = 28. Should be [255, 255, 255, 255]
      expect(lutData.rgbaBytes[28], 255);
      expect(lutData.rgbaBytes[29], 255);
      expect(lutData.rgbaBytes[30], 255);
      expect(lutData.rgbaBytes[31], 255);
    });

    test('should parse .3dl string correctly with fast blue loop and bit depth scale', () {
      const tdlContent = '''
# Created by SeedColor Test
0 1023
0 0 0
0 0 1023
0 1023 0
0 1023 1023
1023 0 0
1023 0 1023
1023 1023 0
1023 1023 1023
''';

      final lutData = LutParser.parseString(tdlContent, is3dl: true);
      expect(lutData.size, 2);
      expect(lutData.rgbaBytes.length, 32);

      // For 3dl, the loops are:
      // r = i ~/ (size * size);
      // g = (i % (size * size)) ~/ size;
      // b = (i % (size * size)) % size;
      // Destination: x = b * size + r, y = g.
      // Index in rgbaBytes = 4 * (g * 4 + b * 2 + r).
      
      // Let's verify i=1 in file: "0 0 1023". This corresponds to r=0, g=0, b=1.
      // Destination: x = 1 * 2 + 0 = 2, y = 0.
      // Index = 4 * (0 * 4 + 2) = 8.
      // R=0, G=0, B=1023 (scaled to 255).
      expect(lutData.rgbaBytes[8], 0);
      expect(lutData.rgbaBytes[9], 0);
      expect(lutData.rgbaBytes[10], 255);
      expect(lutData.rgbaBytes[11], 255);

      // Let's verify i=4 in file: "1023 0 0". This corresponds to r=1, g=0, b=0.
      // Destination: x = 0 * 2 + 1 = 1, y = 0.
      // Index = 4 * (0 * 4 + 1) = 4.
      // R=1023 (255), G=0, B=0.
      expect(lutData.rgbaBytes[4], 255);
      expect(lutData.rgbaBytes[5], 0);
      expect(lutData.rgbaBytes[6], 0);
      expect(lutData.rgbaBytes[7], 255);
    });

    test('should infer size from point count if LUT_3D_SIZE is missing', () {
      const cubeContentWithoutSize = '''
# No size declaration
0.0 0.0 0.0
1.0 0.0 0.0
0.0 1.0 0.0
1.0 1.0 0.0
0.0 0.0 1.0
1.0 0.0 1.0
0.0 1.0 1.0
1.0 1.0 1.0
''';
      final lutData = LutParser.parseString(cubeContentWithoutSize, is3dl: false);
      expect(lutData.size, 2);
      expect(lutData.rgbaBytes.length, 32);
    });

    group('Bit-Depth normalizations', () {
      test('should auto-scale if maxVal > 1.0 and <= 255.0', () {
        const content = '''
LUT_3D_SIZE 2
0 0 0
255 0 0
0 255 0
255 255 0
0 0 255
255 0 255
0 255 255
255 255 255
''';
        final lutData = LutParser.parseString(content, is3dl: false);
        expect(lutData.rgbaBytes[4], 255);
      });

      test('should auto-scale if maxVal > 255.0 and <= 1023.0', () {
        const content = '''
LUT_3D_SIZE 2
0 0 0
1023 0 0
0 1023 0
1023 1023 0
0 0 1023
1023 0 1023
0 1023 1023
1023 1023 1023
''';
        final lutData = LutParser.parseString(content, is3dl: false);
        expect(lutData.rgbaBytes[4], 255);
      });

      test('should auto-scale if maxVal > 1023.0 and <= 4095.0', () {
        const content = '''
LUT_3D_SIZE 2
0 0 0
4095 0 0
0 4095 0
4095 4095 0
0 0 4095
4095 0 4095
0 4095 4095
4095 4095 4095
''';
        final lutData = LutParser.parseString(content, is3dl: false);
        expect(lutData.rgbaBytes[4], 255);
      });
    });
  });
}
