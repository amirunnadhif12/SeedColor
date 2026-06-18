// 🌱 SeedColor — Custom Failure Classes
//
// Hierarki error yang digunakan di seluruh aplikasi.
// Mengikuti pola Clean Architecture: domain layer menggunakan
// Failure objects, bukan exception mentah.

/// Base failure class — semua failure extend dari sini.
abstract class Failure {
  final String message;
  final String? details;

  const Failure(this.message, {this.details});

  @override
  String toString() => 'Failure: $message${details != null ? ' ($details)' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// ─── Image Failures ───────────────────────────────────────

/// Gagal memuat gambar dari storage
class ImageLoadFailure extends Failure {
  final String? filePath;

  const ImageLoadFailure(super.message, {this.filePath, super.details});
}

/// Format gambar tidak didukung
class UnsupportedFormatFailure extends Failure {
  final String format;

  const UnsupportedFormatFailure(this.format, {super.details})
      : super('Format tidak didukung: $format');
}

/// Gambar melebihi batas ukuran
class ImageTooLargeFailure extends Failure {
  final int width;
  final int height;

  const ImageTooLargeFailure(this.width, this.height, {super.details})
      : super('Gambar terlalu besar: ${width}x$height');
}

// ─── Shader Failures ──────────────────────────────────────

/// Gagal compile/load fragment shader
class ShaderCompileFailure extends Failure {
  final String shaderName;

  const ShaderCompileFailure(this.shaderName, {super.details})
      : super('Gagal compile shader: $shaderName');
}

// ─── Export Failures ──────────────────────────────────────

/// Gagal mengekspor gambar
class ExportFailure extends Failure {
  final String? outputPath;

  const ExportFailure(super.message, {this.outputPath, super.details});
}

// ─── Storage Failures ─────────────────────────────────────

/// Gagal operasi read/write file system
class StorageFailure extends Failure {
  final String? path;

  const StorageFailure(super.message, {this.path, super.details});
}

/// Storage penuh
class InsufficientStorageFailure extends Failure {
  const InsufficientStorageFailure({super.details})
      : super('Penyimpanan tidak cukup');
}

// ─── Permission Failures ──────────────────────────────────

/// Permission ditolak oleh user
class PermissionFailure extends Failure {
  final String permissionType;

  const PermissionFailure(this.permissionType, {super.details})
      : super('Izin $permissionType ditolak');
}

// ─── Database Failures ────────────────────────────────────

/// Gagal operasi database
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.details});
}

// ─── Preset Failures ──────────────────────────────────────

/// Gagal parsing/loading preset
class PresetParseFailure extends Failure {
  final String presetName;

  const PresetParseFailure(this.presetName, {super.details})
      : super('Gagal memuat preset: $presetName');
}

/// Preset .xmp tidak valid
class InvalidXmpFailure extends Failure {
  const InvalidXmpFailure({super.details})
      : super('File XMP tidak valid');
}

// ─── Generic Failures ─────────────────────────────────────

/// Unexpected/unknown error
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.details})
      : super('Terjadi kesalahan yang tidak terduga');
}

/// Network error (untuk fitur masa depan)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.details});
}
