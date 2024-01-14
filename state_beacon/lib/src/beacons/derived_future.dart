part of '../base_beacon.dart';

enum DerivedFutureStatus {
  idle,
  running,
  restarted,
}

class DerivedFutureBeacon<T> extends FutureBeacon<T>
    with DerivedMixin<AsyncValue<T>> {
  DerivedFutureBeacon(
    super._operation, {
    bool manualStart = false,
    super.cancelRunning = true,
    super.debugLabel,
  }) {
    if (manualStart) {
      _status.set(DerivedFutureStatus.idle);
      _setValue(AsyncIdle());
    } else {
      _status.set(DerivedFutureStatus.running);
      _setValue(AsyncLoading());
    }
  }

  Future<void> run() => _run();

  final _status = WritableBeacon<DerivedFutureStatus>();
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
