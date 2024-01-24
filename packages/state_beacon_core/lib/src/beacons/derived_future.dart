part of '../base_beacon.dart';

/// Represents the status of a [DerivedFutureBeacon].
enum DerivedFutureStatus {
  /// The future has not yet started.
  idle,

  /// The future is currently running.
  running,

  /// The future has been restarted.
  restarted,
}

/// A beacon that reruns a future when its dependencies change.
class DerivedFutureBeacon<T> extends FutureBeacon<T>
    with DerivedMixin<AsyncValue<T>> {
  /// @macro [DerivedFutureBeacon]
  DerivedFutureBeacon(
    super._operation, {
    bool manualStart = false,
    super.cancelRunning = true,
    super.name,
  }) {
    if (manualStart) {
      _status.set(DerivedFutureStatus.idle);
      _setValue(AsyncIdle());
    } else {
      _status.set(DerivedFutureStatus.running);
      _setValue(AsyncLoading());
    }
  }

  /// Runs the future.
  Future<void> run() => _run();

  final _status = Beacon.lazyWritable<DerivedFutureStatus>();

  /// The status of the future.
  ReadableBeacon<DerivedFutureStatus> get status => _status;

  @override
  void start() {
    // can only start once
    if (_status.peek() != DerivedFutureStatus.idle) return;
    _status.value = DerivedFutureStatus.running;
  }

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
