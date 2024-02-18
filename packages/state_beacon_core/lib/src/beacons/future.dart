part of '../producer.dart';

/// A callback that returns a [Future].
typedef FutureCallback<T> = Future<T> Function();

/// See `Beacon.future`
class FutureBeacon<T> extends AsyncBeacon<T> {
  /// See `Beacon.future`
  FutureBeacon(
    FutureCallback<T> compute, {
    required super.shouldSleep,
    super.manualStart,
    super.name,
  }) : super(() => compute().asStream());

  /// Replaces the current callback and resets the beacon
  void overrideWith(FutureCallback<T> compute) {
    _compute = () => compute().asStream();
    reset();
  }

  /// Resets the beacon by executing the future again.
  void reset() {
    _cancel();
    _wakeUp();
  }
}
