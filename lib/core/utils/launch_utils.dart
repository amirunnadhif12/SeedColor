import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LaunchUtils {
  static Future<bool> isFirstLaunch() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/first_launch_completed.txt');
      return !await file.exists();
    } catch (e) {
      return true; // Fallback aman
    }
  }

  static Future<void> markFirstLaunchCompleted() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/first_launch_completed.txt');
      await file.writeAsString('completed');
    } catch (_) {}
  }

  // Digunakan untuk testing
  static Future<void> resetFirstLaunch() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/first_launch_completed.txt');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
