import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/edit_session.dart';
import '../entities/hsl_adjustments.dart';

/// 🌱 SeedColor — Apply HSL Use Case
///
/// Use case untuk memperbarui penyesuaian HSL pada saluran warna tertentu
/// (Red, Orange, Yellow, Green, Aqua, Blue, Purple, Magenta) dalam sesi pengeditan aktif.
class ApplyHsl {
  Either<Failure, EditSession> call(
    EditSession session, {
    required String colorChannel,
    required HslColorAdjustment adjustment,
  }) {
    try {
      final currentParams = session.currentParameters;
      final currentHsl = currentParams.hslAdjustments;

      HslAdjustments updatedHsl;
      switch (colorChannel.toLowerCase()) {
        case 'red':
          updatedHsl = currentHsl.copyWith(red: adjustment);
          break;
        case 'orange':
          updatedHsl = currentHsl.copyWith(orange: adjustment);
          break;
        case 'yellow':
          updatedHsl = currentHsl.copyWith(yellow: adjustment);
          break;
        case 'green':
          updatedHsl = currentHsl.copyWith(green: adjustment);
          break;
        case 'aqua':
          updatedHsl = currentHsl.copyWith(aqua: adjustment);
          break;
        case 'blue':
          updatedHsl = currentHsl.copyWith(blue: adjustment);
          break;
        case 'purple':
          updatedHsl = currentHsl.copyWith(purple: adjustment);
          break;
        case 'magenta':
          updatedHsl = currentHsl.copyWith(magenta: adjustment);
          break;
        default:
          return Left(UnexpectedFailure(
            details: 'Saluran warna HSL tidak dikenal: $colorChannel',
          ));
      }

      final updatedParams = currentParams.copyWith(hslAdjustments: updatedHsl);
      final updatedSession = session.copyWith(currentParameters: updatedParams);
      return Right(updatedSession);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }
}
