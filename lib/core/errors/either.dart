/// 🌱 SeedColor — Either Type
///
/// Implementasi sederhana dari tipe Either untuk pemrograman fungsional.
/// Mewakili nilai dari salah satu dari dua jenis: Left (biasanya untuk Failure)
/// atau Right (biasanya untuk Success).
abstract class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => fold((l) => l, (r) => null);
  R? get rightOrNull => fold((l) => null, (r) => r);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return leftFn(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return rightFn(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}
