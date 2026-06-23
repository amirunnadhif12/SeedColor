import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/math_utils.dart';
import '../../domain/entities/curve_data.dart';
import '../../domain/entities/edit_parameters.dart';
import '../../domain/entities/edit_session.dart';
import '../../domain/repositories/editor_repository.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/database/app_database.dart';

/// 🌱 SeedColor — Editor Repository Implementation
///
/// Implementasi repositori untuk mengelola sesi pengeditan dan ekspor gambar.
/// Menggunakan akselerasi GPU off-screen untuk merender penyesuaian resolusi penuh.
class EditorRepositoryImpl implements EditorRepository {
  // Penyimpanan sesi aktif di memori
  final Map<String, EditSession> _sessions = {};

  @override
  Future<Either<Failure, EditSession>> startSession(
    String photoId,
    String imagePath,
  ) async {
    try {
      if (_sessions.containsKey(photoId)) {
        return Right(_sessions[photoId]!);
      }

      // Membaca resolusi gambar asli jika bukan sampel
      int width = 1920;
      int height = 1080;

      if (photoId != 'sample' && imagePath.isNotEmpty) {
        try {
          final file = File(imagePath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final ui.Codec codec = await ui.instantiateImageCodec(bytes);
            final ui.FrameInfo fi = await codec.getNextFrame();
            width = fi.image.width;
            height = fi.image.height;
          }
        } catch (e) {
          debugPrint('Gagal membaca resolusi gambar asli: $e');
        }
      }

      final session = EditSession(
        photoId: photoId,
        imagePath: imagePath,
        currentParameters: EditParameters.identity(),
        originalWidth: width,
        originalHeight: height,
        createdAt: DateTime.now(),
      );

      _sessions[photoId] = session;
      return Right(session);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSession(EditSession session) async {
    try {
      _sessions[session.photoId] = session;
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EditSession>> getSession(String photoId) async {
    try {
      final session = _sessions[photoId];
      if (session != null) {
        return Right(session);
      }
      return Left(StorageFailure('Sesi pengeditan untuk $photoId tidak ditemukan.'));
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportImage(
    EditSession session, {
    required String outputPath,
    required int quality,
    String format = 'jpeg',
    double scale = 1.0,
  }) async {
    try {
      // 1. Muat bytes gambar asli
      final Uint8List originalBytes;
      if (session.photoId == 'sample' || session.imagePath.startsWith('assets/')) {
        final ByteData data = await rootBundle.load('assets/images/mountain_lake.png');
        originalBytes = data.buffer.asUint8List();
      } else {
        final pathLower = session.imagePath.toLowerCase();
        final isRaw = pathLower.endsWith('.dng') ||
            pathLower.endsWith('.cr2') ||
            pathLower.endsWith('.nef') ||
            pathLower.endsWith('.arw');

        String pathToLoad = session.imagePath;
        if (isRaw) {
          try {
            final db = sl<AppDatabase>();
            final dbPhoto = await (db.select(db.photosTable)
                  ..where((t) => t.id.equals(session.photoId)))
                .getSingleOrNull();
            if (dbPhoto != null && dbPhoto.thumbnailPath != null) {
              pathToLoad = dbPhoto.thumbnailPath!;
            }
          } catch (e) {
            debugPrint('Gagal membaca database saat mengekspor RAW: $e');
          }
        }

        final file = File(pathToLoad);
        if (!await file.exists()) {
          return Left(StorageFailure('Berkas asli tidak ditemukan di $pathToLoad'));
        }
        originalBytes = await file.readAsBytes();
      }

      // 2. Dekode gambar asli ke ui.Image
      final ui.Codec codec = await ui.instantiateImageCodec(originalBytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image rawImage = fi.image;

      // 3. Buat LUT dari data kurva warna
      final lutImage = await _generateLutImage(session.currentParameters.curveData);

      // 4. Muat fragment program komposit
      final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
        'lib/shaders/composite.frag',
      );
      final shader = program.fragmentShader();

      // 5. Tentukan ukuran target berdasarkan skala
      final double targetWidth = rawImage.width * scale;
      final double targetHeight = rawImage.height * scale;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetWidth, targetHeight));

      // 6. Bind parameter shader
      shader.setFloat(0, targetWidth);
      shader.setFloat(1, targetHeight);

      final params = session.currentParameters;
      shader.setFloat(2, params.exposure);
      shader.setFloat(3, params.contrast);
      shader.setFloat(4, params.highlights);
      shader.setFloat(5, params.shadows);
      shader.setFloat(6, params.whites);
      shader.setFloat(7, params.blacks);

      shader.setFloat(8, params.temperature);
      shader.setFloat(9, params.tint);
      shader.setFloat(10, params.vibrance);
      shader.setFloat(11, params.saturation);

      final hsl = params.hslAdjustments;
      shader.setFloat(12, hsl.red.hue);
      shader.setFloat(13, hsl.red.saturation);
      shader.setFloat(14, hsl.red.lightness);
      shader.setFloat(15, hsl.orange.hue);
      shader.setFloat(16, hsl.orange.saturation);
      shader.setFloat(17, hsl.orange.lightness);
      shader.setFloat(18, hsl.yellow.hue);
      shader.setFloat(19, hsl.yellow.saturation);
      shader.setFloat(20, hsl.yellow.lightness);
      shader.setFloat(21, hsl.green.hue);
      shader.setFloat(22, hsl.green.saturation);
      shader.setFloat(23, hsl.green.lightness);
      shader.setFloat(24, hsl.aqua.hue);
      shader.setFloat(25, hsl.aqua.saturation);
      shader.setFloat(26, hsl.aqua.lightness);
      shader.setFloat(27, hsl.blue.hue);
      shader.setFloat(28, hsl.blue.saturation);
      shader.setFloat(29, hsl.blue.lightness);
      shader.setFloat(30, hsl.purple.hue);
      shader.setFloat(31, hsl.purple.saturation);
      shader.setFloat(32, hsl.purple.lightness);
      shader.setFloat(33, hsl.magenta.hue);
      shader.setFloat(34, hsl.magenta.saturation);
      shader.setFloat(35, hsl.magenta.lightness);

      shader.setFloat(36, params.texture);
      shader.setFloat(37, params.clarity);
      shader.setFloat(38, params.dehaze);
      shader.setFloat(39, params.vignette);
      shader.setFloat(40, params.grain);

      List<double> hueToRgb(double hue) {
        final h = hue / 60.0;
        final x = 1.0 - (h % 2.0 - 1.0).abs();
        if (h < 1) return [1.0, x, 0.0];
        if (h < 2) return [x, 1.0, 0.0];
        if (h < 3) return [0.0, 1.0, x];
        if (h < 4) return [0.0, x, 1.0];
        if (h < 5) return [x, 0.0, 1.0];
        return [1.0, 0.0, x];
      }
      List<double> hueSatToRgbVec3(double hue, double sat) {
        final rgb = hueToRgb(hue);
        final s = sat / 100.0;
        return [rgb[0] * s, rgb[1] * s, rgb[2] * s];
      }

      final sColor = hueSatToRgbVec3(params.shadowsHue, params.shadowsSat);
      final mColor = hueSatToRgbVec3(params.midtonesHue, params.midtonesSat);
      final hColor = hueSatToRgbVec3(params.highlightsHue, params.highlightsSat);

      shader.setFloat(41, sColor[0]);
      shader.setFloat(42, sColor[1]);
      shader.setFloat(43, sColor[2]);
      shader.setFloat(44, mColor[0]);
      shader.setFloat(45, mColor[1]);
      shader.setFloat(46, mColor[2]);
      shader.setFloat(47, hColor[0]);
      shader.setFloat(48, hColor[1]);
      shader.setFloat(49, hColor[2]);
      shader.setFloat(50, params.cgBlending / 100.0);
      shader.setFloat(51, params.cgBalance / 100.0);

      shader.setFloat(52, params.sharpeningAmount);
      shader.setFloat(53, params.sharpeningRadius);
      shader.setFloat(54, params.sharpeningDetail);
      shader.setFloat(55, params.sharpeningMasking);
      shader.setFloat(56, params.luminanceNR);
      shader.setFloat(57, params.colorNR);
      shader.setFloat(58, params.removeChromaticAberration ? 1.0 : 0.0);
      shader.setFloat(59, params.enableLensCorrection ? 1.0 : 0.0);

      shader.setImageSampler(0, rawImage);
      shader.setImageSampler(1, lutImage);

      // Terapkan matriks transformasi geometri
      final double tiltX = params.perspectiveVertical * 0.005;
      final double tiltY = params.perspectiveHorizontal * 0.005;

      final matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(targetWidth / 2.0, targetHeight / 2.0)
        ..rotateX(tiltX)
        ..rotateY(tiltY)
        ..rotateZ(params.rotation * math.pi / 180.0)
        ..scale(params.flipHorizontal ? -1.0 : 1.0, params.flipVertical ? -1.0 : 1.0)
        ..translate(-targetWidth / 2.0, -targetHeight / 2.0);

      canvas.transform(matrix.storage);

      final paint = Paint()..shader = shader;
      canvas.drawRect(Rect.fromLTWH(0, 0, targetWidth, targetHeight), paint);

      final picture = recorder.endRecording();
      final renderedImage = await picture.toImage(targetWidth.toInt(), targetHeight.toInt());

      // Terapkan crop
      ui.Image finalImage = renderedImage;
      if (params.cropLeft != 0.0 || params.cropTop != 0.0 || params.cropRight != 1.0 || params.cropBottom != 1.0) {
        final double cropX = params.cropLeft * targetWidth;
        final double cropY = params.cropTop * targetHeight;
        final double cropW = (params.cropRight - params.cropLeft) * targetWidth;
        final double cropH = (params.cropBottom - params.cropTop) * targetHeight;

        final cropRecorder = ui.PictureRecorder();
        final cropCanvas = Canvas(cropRecorder, Rect.fromLTWH(0, 0, cropW, cropH));
        cropCanvas.drawImageRect(
          renderedImage,
          Rect.fromLTWH(cropX, cropY, cropW, cropH),
          Rect.fromLTWH(0, 0, cropW, cropH),
          Paint(),
        );
        final cropPicture = cropRecorder.endRecording();
        finalImage = await cropPicture.toImage(cropW.toInt(), cropH.toInt());
      }

      // Ambil bytes data pixel dan kompres menggunakan image package di background isolate
      final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        return Left(UnexpectedFailure(details: 'Gagal mengekstrak data pixel gambar ekspor.'));
      }

      final rgbaBytes = byteData.buffer.asUint8List();

      await compute(
        _encodeAndSaveImage,
        ImageEncodingParams(
          rgbaBytes: rgbaBytes,
          width: finalImage.width,
          height: finalImage.height,
          format: format,
          quality: quality,
          outputPath: outputPath,
        ),
      );

      return Right(outputPath);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }

  Future<ui.Image> _generateLutImage(CurveData curve) async {
    final redLut = MathUtils.catmullRomSplineLut(curve.red);
    final greenLut = MathUtils.catmullRomSplineLut(curve.green);
    final blueLut = MathUtils.catmullRomSplineLut(curve.blue);
    final rgbLut = MathUtils.catmullRomSplineLut(curve.rgb);

    final bytes = Uint8List(256 * 4);
    for (int i = 0; i < 256; i++) {
      bytes[i * 4 + 0] = (redLut[i] * 255).clamp(0, 255).round();
      bytes[i * 4 + 1] = (greenLut[i] * 255).clamp(0, 255).round();
      bytes[i * 4 + 2] = (blueLut[i] * 255).clamp(0, 255).round();
      bytes[i * 4 + 3] = (rgbLut[i] * 255).clamp(0, 255).round();
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      256,
      1,
      ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    return completer.future;
  }
}

class ImageEncodingParams {
  final Uint8List rgbaBytes;
  final int width;
  final int height;
  final String format;
  final int quality;
  final String outputPath;

  ImageEncodingParams({
    required this.rgbaBytes,
    required this.width,
    required this.height,
    required this.format,
    required this.quality,
    required this.outputPath,
  });
}

Future<void> _encodeAndSaveImage(ImageEncodingParams params) async {
  final imgImage = img.Image.fromBytes(
    width: params.width,
    height: params.height,
    bytes: params.rgbaBytes.buffer,
    order: img.ChannelOrder.rgba,
  );

  final List<int> encodedBytes;
  if (params.format.toLowerCase() == 'png') {
    encodedBytes = img.encodePng(imgImage);
  } else {
    encodedBytes = img.encodeJpg(imgImage, quality: params.quality);
  }

  final file = File(params.outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(encodedBytes);
}
