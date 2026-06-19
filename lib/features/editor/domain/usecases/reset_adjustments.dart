import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/edit_parameters.dart';
import '../entities/edit_session.dart';

/// 🌱 SeedColor — Reset Adjustments Use Case
///
/// Use case untuk mengembalikan seluruh parameter edit
/// ke keadaan default / kosong (identity) pada sesi aktif.
class ResetAdjustments {
  Either<Failure, EditSession> call(EditSession session) {
    try {
      final updatedSession = session.copyWith(
        currentParameters: EditParameters.identity(),
      );
      return Right(updatedSession);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }
}
