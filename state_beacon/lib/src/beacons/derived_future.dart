part of '../base_beacon.dart';

enum DerivedFutureStatus {
  idle,
  running,
  restarted,
}

class DerivedFutureBeacon<T> extends DerivedBeaconBase<AsyncValue<T>> {
  DerivedFutureBeacon({bool startNow = true}) {
    if (startNow) {
      _status = WritableBeacon(DerivedFutureStatus.running);
    } else {
      _status = WritableBeacon(DerivedFutureStatus.idle);
      super.forceSetValue(AsyncIdle());
    }
  }

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

    super.forceSetValue(value);
  }

  /// Starts executing an idle [Future]
  ///
  /// NB: Must only be called once
  ///
  /// Use [reset] to restart the [Future]
  void start() {
    // can only start once
    if (_status.peek() != DerivedFutureStatus.idle) {
      throw FutureStartedTwiceException();
    }
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
