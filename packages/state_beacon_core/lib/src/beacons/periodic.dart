part of '../producer.dart';

/// A beacon that emits values periodically.
class PeriodicBeacon<T> extends ReadableBeacon<T> {
  /// Creates a [PeriodicBeacon] that emits values periodically.
  PeriodicBeacon(
    this._period,
    this._compute, {
    super.initialValue,
    super.name,
  }) {
    _setValue(_compute(_count));
    _start();
  }

  final Duration _period;
  final T Function(int count) _compute;

  StreamSubscription<dynamic>? _subscription;
  var _count = 0;

  void _start() {
    _subscription = Stream<dynamic>.periodic(_period).listen((_) {
      if (_isDisposed) return;
      _setValue(_compute(++_count));
    });
  }

  /// Pauses emition of values.
  void pause() => _subscription?.pause();

  /// Resumes emition of values.
  void resume() => _subscription?.resume();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
