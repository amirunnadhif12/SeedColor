import 'dart:math' as math;
import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/curve_data.dart';
import '../entities/edit_session.dart';

/// 🌱 SeedColor — Apply Curves Use Case
///
/// Use case untuk memperbarui data titik kontrol kurva pada saluran tertentu
/// (RGB, Red, Green, atau Blue) dalam sesi pengeditan aktif.
class ApplyCurves {
  Either<Failure, EditSession> call(
    EditSession session, {
    required String channel,
    required List<math.Point<double>> points,
  }) {
    try {
      final currentParams = session.currentParameters;
      final currentCurve = currentParams.curveData;

      CurveData updatedCurve;
      switch (channel.toLowerCase()) {
        case 'red':
          updatedCurve = CurveData(
            rgb: currentCurve.rgb,
            red: points,
            green: currentCurve.green,
            blue: currentCurve.blue,
          );
          break;
        case 'green':
          updatedCurve = CurveData(
            rgb: currentCurve.rgb,
            red: currentCurve.red,
            green: points,
            blue: currentCurve.blue,
          );
          break;
        case 'blue':
          updatedCurve = CurveData(
            rgb: currentCurve.rgb,
            red: currentCurve.red,
            green: currentCurve.green,
            blue: points,
          );
          break;
        case 'rgb':
        default:
          updatedCurve = CurveData(
            rgb: points,
            red: currentCurve.red,
            green: currentCurve.green,
            blue: currentCurve.blue,
          );
          break;
      }

      final updatedParams = currentParams.copyWith(curveData: updatedCurve);
      final updatedSession = session.copyWith(currentParameters: updatedParams);
      return Right(updatedSession);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }
}
