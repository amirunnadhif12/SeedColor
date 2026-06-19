import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/edit_session.dart';

/// 🌱 SeedColor — Editor State
///
/// Status layar editor foto. Menggunakan Equatable untuk membandingkan
/// kesamaan state secara efisien dan memicu pembaruan UI.
class EditorState extends Equatable {
  final EditSession? session;
  final bool isProcessing;
  final Failure? failure;
  final String? exportedImagePath;

  const EditorState({
    this.session,
    this.isProcessing = false,
    this.failure,
    this.exportedImagePath,
  });

  /// Status awal saat layar editor pertama kali dibuka.
  factory EditorState.initial() {
    return const EditorState(
      session: null,
      isProcessing: false,
      failure: null,
      exportedImagePath: null,
    );
  }

  EditorState copyWith({
    EditSession? session,
    bool? isProcessing,
    Failure? failure,
    String? exportedImagePath,
    bool clearFailure = false,
    bool clearExportPath = false,
  }) {
    return EditorState(
      session: session ?? this.session,
      isProcessing: isProcessing ?? this.isProcessing,
      failure: clearFailure ? null : (failure ?? this.failure),
      exportedImagePath: clearExportPath ? null : (exportedImagePath ?? this.exportedImagePath),
    );
  }

  @override
  List<Object?> get props => [
        session,
        isProcessing,
        failure,
        exportedImagePath,
      ];
}
