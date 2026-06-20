import 'package:equatable/equatable.dart';
import '../../../editor/domain/entities/edit_parameters.dart';

class Preset extends Equatable {
  final String id;
  final String name;
  final String category; // 'recommended', 'premium', 'yours'
  final EditParameters parameters;
  final bool isBookmarked;
  final DateTime createdAt;

  const Preset({
    required this.id,
    required this.name,
    required this.category,
    required this.parameters,
    this.isBookmarked = false,
    required this.createdAt,
  });

  Preset copyWith({
    String? id,
    String? name,
    String? category,
    EditParameters? parameters,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      parameters: parameters ?? this.parameters,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, category, parameters, isBookmarked, createdAt];
}
