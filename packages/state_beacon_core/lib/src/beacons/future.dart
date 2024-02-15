part of '../producer.dart';

/// A callback that returns a [Future].
typedef FutureCallback<T> = Future<T> Function();

/// See `Beacon.future`
class FutureBeacon<T> extends AsyncBeacon<T> {
  /// See `Beacon.future`
  FutureBeacon(
    FutureCallback<T> compute, {
    super.name,
    this.shouldSleep = true,
    super.manualStart,
  }) : super(() => compute().asStream());

  var _sleeping = false;

  /// Whether the future should sleep when there are no observers.
  final bool shouldSleep;

  void _wakeUp() {
    if (_sleeping) {
      _sleeping = false;
      // needs to be in loading state instantly when waking up
      // so beacon.value.isLoading is true
      _setLoadingWithLastData();
    }

    start();
  }

  @override
  AsyncValue<T> peek() {
    if (_sleeping) {
      _wakeUp();
    }
    return super.peek();
  }

  /// Replaces the current callback and resets the beacon
  void overrideWith(FutureCallback<T> compute) {
    _compute = () => compute().asStream();
    reset();
  }

  @override
  AsyncValue<T> get value {
    if (_sleeping) {
      _wakeUp();
    }
    return super.value;
  }

  void _goToSleep() {
    _sleeping = true;
    _cancel();
  }

  @override
  void _removeObserver(Consumer observer) {
    super._removeObserver(observer);
    if (!shouldSleep) return;
    if (_observers.isEmpty) {
      _goToSleep();
    }
  }

  /// Resets the beacon by executing the future again.
  void reset() {
    _cancel();
    _wakeUp();
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
