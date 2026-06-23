import '../../features/editor/domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — Copied Settings Helper
///
/// Utility class to store copied edit parameters in memory.
/// This allows copying adjustments from one photo in the editor and pasting them
/// onto other photos in the library.
class CopiedSettingsHelper {
  static EditParameters? _copiedParameters;

  /// Gets the currently copied parameters.
  static EditParameters? get copiedParameters => _copiedParameters;

  /// Saves the given parameters as the copied settings.
  static void copy(EditParameters parameters) {
    _copiedParameters = parameters;
  }

  /// Clears the copied parameters.
  static void clear() {
    _copiedParameters = null;
  }

  /// Checks if there are copied parameters available.
  static bool get hasCopiedParameters => _copiedParameters != null;
}
