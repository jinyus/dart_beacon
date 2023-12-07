part of '../base_beacon.dart';

enum DerivedFutureStatus {
  idle,
  running,
  restarted,
}

class DerivedFutureBeacon<T> extends DerivedBeaconBase<AsyncValue<T>> {
  DerivedFutureBeacon({bool manualStart = false, this.cancelRunning = true}) {
    if (manualStart) {
      _status = WritableBeacon(DerivedFutureStatus.idle);
      super.forceSetValue(AsyncIdle());
    } else {
      _status = WritableBeacon(DerivedFutureStatus.running);
    }
  }

  final bool cancelRunning;
  AsyncValue<T>? _previousAsyncValue;
  T? _lastData;

  @override
  AsyncValue<T>? get previousValue => _previousAsyncValue;

  /// The last data that was successfully loaded
  /// This is useful when the current state is [AsyncError] or [AsyncLoading]
  T? get lastData => _lastData;

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
    if (cancelRunning && exeID != _executionID) return;

    if (value is AsyncData) {
      if (_lastData != null) {
        // first time we get data, we don't have a previous value

        // ignore: null_check_on_nullable_type_parameter
        _previousAsyncValue = AsyncData(_lastData!);
      }

      _lastData = value.unwrapValue();
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
    _status.value = _status.peek() == DerivedFutureStatus.running
        ? DerivedFutureStatus.restarted
        : DerivedFutureStatus.running;
  }

  @override
  void dispose() {
    _status.dispose();
    _lastData = null;
    _previousAsyncValue = null;
    super.dispose();
  }
}
