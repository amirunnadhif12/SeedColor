import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/edit_session.dart';
import '../../domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — History Entry
///
/// Menyimpan satu langkah dalam riwayat pengeditan foto.
class HistoryEntry extends Equatable {
  final String id;
  final String label;
  final EditParameters parameters;
  final DateTime timestamp;

  const HistoryEntry({
    required this.id,
    required this.label,
    required this.parameters,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, label, parameters, timestamp];
}

/// 🌱 SeedColor — Named Snapshot
///
/// Menyimpan snapshot pengaturan penyesuaian kustom yang diberi nama oleh pengguna.
class NamedSnapshot extends Equatable {
  final String id;
  final String name;
  final EditParameters parameters;
  final DateTime createdAt;

  const NamedSnapshot({
    required this.id,
    required this.name,
    required this.parameters,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, parameters, createdAt];
}

/// 🌱 SeedColor — Editor State
///
/// Status layar editor foto. Menggunakan Equatable untuk membandingkan
/// kesamaan state secara efisien dan memicu pembaruan UI.
class EditorState extends Equatable {
  final EditSession? session;
  final bool isProcessing;
  final Failure? failure;
  final String? exportedImagePath;
  final List<HistoryEntry> history;
  final int currentHistoryIndex;
  final List<NamedSnapshot> snapshots;

  const EditorState({
    this.session,
    this.isProcessing = false,
    this.failure,
    this.exportedImagePath,
    this.history = const [],
    this.currentHistoryIndex = -1,
    this.snapshots = const [],
  });

  /// Status awal saat layar editor pertama kali dibuka.
  factory EditorState.initial() {
    return const EditorState(
      session: null,
      isProcessing: false,
      failure: null,
      exportedImagePath: null,
      history: [],
      currentHistoryIndex: -1,
      snapshots: [],
    );
  }

  EditorState copyWith({
    EditSession? session,
    bool? isProcessing,
    Failure? failure,
    String? exportedImagePath,
    List<HistoryEntry>? history,
    int? currentHistoryIndex,
    List<NamedSnapshot>? snapshots,
    bool clearFailure = false,
    bool clearExportPath = false,
  }) {
    return EditorState(
      session: session ?? this.session,
      isProcessing: isProcessing ?? this.isProcessing,
      failure: clearFailure ? null : (failure ?? this.failure),
      exportedImagePath: clearExportPath ? null : (exportedImagePath ?? this.exportedImagePath),
      history: history ?? this.history,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
      snapshots: snapshots ?? this.snapshots,
    );
  }

  @override
  List<Object?> get props => [
        session,
        isProcessing,
        failure,
        exportedImagePath,
        history,
        currentHistoryIndex,
        snapshots,
      ];
}
