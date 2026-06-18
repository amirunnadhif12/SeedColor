import 'dart:async';

/// 🌱 SeedColor — Debounce & Throttle Utilities
///
/// Digunakan untuk mengontrol frekuensi callback:
/// - **Debouncer**: Menunda eksekusi sampai tidak ada update selama [duration]
/// - **Throttler**: Eksekusi maksimal sekali per [duration]

/// Debouncer — menunda eksekusi callback.
///
/// Ideal untuk slider yang terus berubah: hanya emit state
/// setelah user berhenti menggeser selama [milliseconds] ms.
///
/// ```dart
/// final debouncer = Debouncer(milliseconds: 16);
///
/// slider.onChanged = (value) {
///   debouncer.run(() {
///     bloc.add(UpdateExposure(value));
///   });
/// };
///
/// // Jangan lupa dispose
/// @override
/// void dispose() {
///   debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 16});

  /// Jalankan [action] setelah delay.
  /// Jika dipanggil lagi sebelum delay selesai, timer di-reset.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cek apakah debouncer sedang aktif (ada timer pending).
  bool get isActive => _timer?.isActive ?? false;

  /// Cancel timer yang pending tanpa menjalankan callback.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose debouncer — wajib dipanggil di widget dispose().
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler — membatasi frekuensi eksekusi callback.
///
/// Ideal untuk scroll events atau operasi yang berat:
/// callback hanya dieksekusi sekali per [milliseconds] ms,
/// meskipun dipanggil berkali-kali.
///
/// ```dart
/// final throttler = Throttler(milliseconds: 100);
///
/// scrollController.addListener(() {
///   throttler.run(() {
///     loadMorePhotos();
///   });
/// });
/// ```
class Throttler {
  final int milliseconds;
  DateTime? _lastRun;
  Timer? _timer;

  Throttler({this.milliseconds = 100});

  /// Jalankan [action] jika sudah melewati interval throttle.
  /// Jika belum, jadwalkan eksekusi di akhir interval.
  void run(void Function() action) {
    final now = DateTime.now();

    if (_lastRun == null ||
        now.difference(_lastRun!).inMilliseconds >= milliseconds) {
      // Sudah cukup lama — langsung jalankan
      _lastRun = now;
      action();
    } else {
      // Belum waktunya — jadwalkan untuk dijalankan nanti
      _timer?.cancel();
      final remaining =
          milliseconds - now.difference(_lastRun!).inMilliseconds;
      _timer = Timer(Duration(milliseconds: remaining), () {
        _lastRun = DateTime.now();
        action();
      });
    }
  }

  /// Cancel pending throttle timer.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose throttler — wajib dipanggil di widget dispose().
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _lastRun = null;
  }
}
