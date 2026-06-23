import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:replay_bloc/replay_bloc.dart';
import '../../domain/entities/edit_parameters.dart';
import '../../domain/entities/hsl_adjustments.dart';
import 'editor_state.dart';

/// 🌱 SeedColor — Editor Events
///
/// Seluruh aksi interaksi pengguna yang dikirimkan ke EditorBloc.
/// Harus mewarisi [ReplayEvent] untuk kompatibilitas riwayat state ReplayBloc.
abstract class EditorEvent extends ReplayEvent with EquatableMixin {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

/// Memulai sesi edit baru untuk foto tertentu
class StartSession extends EditorEvent {
  final String photoId;
  final String imagePath;

  const StartSession({
    required this.photoId,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [photoId, imagePath];
}

/// Memperbarui parameter pencahayaan (Light)
class UpdateLight extends EditorEvent {
  final EditParameters parameters;

  const UpdateLight(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Memperbarui parameter warna (Color)
class UpdateColor extends EditorEvent {
  final EditParameters parameters;

  const UpdateColor(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Memperbarui penyesuaian HSL mixer saluran warna tertentu
class UpdateHSL extends EditorEvent {
  final String colorChannel;
  final HslColorAdjustment adjustment;

  const UpdateHSL({
    required this.colorChannel,
    required this.adjustment,
  });

  @override
  List<Object?> get props => [colorChannel, adjustment];
}

/// Memperbarui kurva warna saluran tertentu
class UpdateCurves extends EditorEvent {
  final String channel;
  final List<math.Point<double>> points;

  const UpdateCurves({
    required this.channel,
    required this.points,
  });

  @override
  List<Object?> get props => [channel, points];
}

/// Memperbarui parameter efek (Effects)
class UpdateEffects extends EditorEvent {
  final EditParameters parameters;

  const UpdateEffects(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Memperbarui parameter color grading (Split toning)
class UpdateColorGrading extends EditorEvent {
  final EditParameters parameters;

  const UpdateColorGrading(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Memperbarui parameter detail (Sharpening & Noise Reduction)
class UpdateDetail extends EditorEvent {
  final EditParameters parameters;

  const UpdateDetail(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Memperbarui parameter optik (Chromatic Aberration & Lens Correction)
class UpdateOptics extends EditorEvent {
  final EditParameters parameters;

  const UpdateOptics(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Memperbarui parameter geometri (Crop, Rotate, Flip, Perspektif)
class UpdateGeometry extends EditorEvent {
  final EditParameters parameters;

  const UpdateGeometry(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Memperbarui parameter LUT (Path, Intensity, Size)
class UpdateLut extends EditorEvent {
  final String? lutPath;
  final double lutIntensity;
  final double lutSize;

  const UpdateLut({
    this.lutPath,
    this.lutIntensity = 1.0,
    this.lutSize = 0.0,
  });

  @override
  List<Object?> get props => [lutPath, lutIntensity, lutSize];
}

/// Mengatur ulang seluruh parameter edit ke awal (identity)
class ResetAll extends EditorEvent {
  const ResetAll();
}

/// Mengekspor hasil edit gambar resolusi penuh ke penyimpanan lokal
class Export extends EditorEvent {
  final String outputPath;
  final int quality;
  final String format;
  final double scale;

  const Export({
    required this.outputPath,
    required this.quality,
    this.format = 'jpeg',
    this.scale = 1.0,
  });

  @override
  List<Object?> get props => [outputPath, quality, format, scale];
}

/// Menerapkan parameter preset pada sesi edit aktif
class ApplyPreset extends EditorEvent {
  final EditParameters parameters;

  const ApplyPreset(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

/// Navigasi ke indeks riwayat edit tertentu
class NavigateHistory extends EditorEvent {
  final int index;

  const NavigateHistory(this.index);

  @override
  List<Object?> get props => [index];
}

/// Membuat snapshot baru dengan nama kustom
class CreateSnapshot extends EditorEvent {
  final String name;

  const CreateSnapshot(this.name);

  @override
  List<Object?> get props => [name];
}

/// Menerapkan pengaturan dari snapshot kustom
class ApplySnapshot extends EditorEvent {
  final NamedSnapshot snapshot;

  const ApplySnapshot(this.snapshot);

  @override
  List<Object?> get props => [snapshot];
}

/// Menghapus snapshot kustom berdasarkan ID
class DeleteSnapshot extends EditorEvent {
  final String id;

  const DeleteSnapshot(this.id);

  @override
  List<Object?> get props => [id];
}
