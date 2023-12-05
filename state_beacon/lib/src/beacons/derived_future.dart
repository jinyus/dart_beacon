part of '../base_beacon.dart';

enum DerivedFutureStatus {
  idle,
  running,
  restarted,
}

class DerivedFutureBeacon<T> extends DerivedBeaconBase<AsyncValue<T>> {
  DerivedFutureBeacon({bool manualStart = false}) {
    if (manualStart) {
      _status = WritableBeacon(DerivedFutureStatus.idle);
      super.forceSetValue(AsyncIdle());
    } else {
      _status = WritableBeacon(DerivedFutureStatus.running);
    }
  }

  AsyncValue<T>? _previousAsyncValue;
  @override
  AsyncValue<T>? get previousValue => _previousAsyncValue;

  late final WritableBeacon<DerivedFutureStatus> _status;
  ReadableBeacon<DerivedFutureStatus> get status => _status;

  var _executionID = 0;

  int startLoading() {
    super.forceSetValue(AsyncLoading());
    return ++_executionID;
  }

  void setAsyncValue(int exeID, AsyncValue<T> value) {
    // If the execution ID is not the same as the current one,
    // then this is an old execution and we should ignore it
    if (exeID != _executionID) return;

    // the current value would be loading so we need the previous AsyncData
    if (value is AsyncData && _previousValue is AsyncData) {
      _previousAsyncValue = _previousValue;
    }

    super.forceSetValue(value);
  }

  /// Starts executing an idle [Future]
  ///
  /// NB: Must only be called once
  ///
  /// Use [reset] to restart the [Future]
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
    _status.value = DerivedFutureStatus.restarted;
  }

  @override
  void dispose() {
    _status.dispose();
    super.dispose();
  }
}
