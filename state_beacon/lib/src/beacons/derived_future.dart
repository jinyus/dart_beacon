part of '../base_beacon.dart';

enum DerivedFutureStatus {
  idle,
  running,
  restarted,
}

class DerivedFutureBeacon<T> extends FutureBeacon<T>
    with DerivedMixin<AsyncValue<T>> {
  DerivedFutureBeacon({bool manualStart = false, super.cancelRunning = true}) {
    if (manualStart) {
      _status.set(DerivedFutureStatus.idle);
      _setValue(AsyncIdle());
    } else {
      _status.set(DerivedFutureStatus.running);
      _setValue(AsyncLoading());
    }
  }
  final _status = WritableBeacon<DerivedFutureStatus>();
  ReadableBeacon<DerivedFutureStatus> get status => _status;

  /// Starts executing an idle [Future]
  ///
  /// NB: Must only be called once
  ///
  /// Use [reset] to restart the [Future]
  @override
  void start() {
    // can only start once
    if (_status.peek() != DerivedFutureStatus.idle) return;
    _status.value = DerivedFutureStatus.running;
  }

  /// Resets the beacon by calling the [Future] again
  ///
  /// NB: This will not reset its dependencies
  @override
  void reset() {
    _status.value = _status.peek() == DerivedFutureStatus.running
        ? DerivedFutureStatus.restarted
        : DerivedFutureStatus.running;
  }

  @override
  void dispose() {
    _status.dispose();
    super.dispose();
  }
}
