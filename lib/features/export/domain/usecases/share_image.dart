import 'package:share_plus/share_plus.dart';

/// 🌱 SeedColor — Share Image Use Case
///
/// Use case untuk membagikan berkas gambar ke aplikasi eksternal.
class ShareImage {
  const ShareImage();

  Future<void> call(String filePath, {String? text}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: text ?? 'Check out my edited photo from SeedColor! 🌱',
    );
  }
}
