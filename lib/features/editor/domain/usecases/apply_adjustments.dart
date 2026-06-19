import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/edit_parameters.dart';
import '../entities/edit_session.dart';

/// 🌱 SeedColor — Apply Adjustments Use Case
///
/// Use case untuk menerapkan parameter penyesuaian (Light, Color, dll)
/// baru ke dalam sesi pengeditan aktif.
class ApplyAdjustments {
  Either<Failure, EditSession> call(
    EditSession session,
    EditParameters newParameters,
  ) {
    try {
      final updatedSession = session.copyWith(currentParameters: newParameters);
      return Right(updatedSession);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }
}
