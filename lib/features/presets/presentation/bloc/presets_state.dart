import 'package:equatable/equatable.dart';
import '../../domain/entities/preset.dart';

abstract class PresetsState extends Equatable {
  const PresetsState();

  @override
  List<Object?> get props => [];
}

class PresetsInitial extends PresetsState {}

class PresetsLoading extends PresetsState {}

class PresetsLoaded extends PresetsState {
  final List<Preset> recommended;
  final List<Preset> premium;
  final List<Preset> yours;
  final String? message;

  const PresetsLoaded({
    required this.recommended,
    required this.premium,
    required this.yours,
    this.message,
  });

  PresetsLoaded copyWith({
    List<Preset>? recommended,
    List<Preset>? premium,
    List<Preset>? yours,
    String? message,
  }) {
    return PresetsLoaded(
      recommended: recommended ?? this.recommended,
      premium: premium ?? this.premium,
      yours: yours ?? this.yours,
      message: message,
    );
  }

  @override
  List<Object?> get props => [recommended, premium, yours, message];
}

class PresetsError extends PresetsState {
  final String errorMessage;

  const PresetsError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
