part of '../producer.dart';

/// A callback that returns a [Future].
typedef FutureCallback<T> = Future<T> Function();

/// Represents the status of a [FutureBeacon].
enum FutureStatus {
  /// The future has not yet started.
  idle,

  /// The future is currently running.
  running,
}

/// See `Beacon.future`
class FutureBeacon<T> extends AsyncBeacon<T> {
  /// See `Beacon.future`
  FutureBeacon(
    this._compute, {
    super.name,
    this.shouldSleep = true,
    bool manualStart = false,
  }) : super(initialValue: manualStart ? AsyncIdle() : AsyncLoading()) {
    _isEmpty = false;

    if (!manualStart) start();
  }

  VoidCallback? _effectDispose;
  var _executionID = 0;
  var _sleeping = false;

  /// Whether the future should sleep when there are no observers.
  final bool shouldSleep;
  FutureCallback<T> _compute;
  var _status = FutureStatus.idle;

  /// The current status of the future.
  FutureStatus get status => _status;

  void _goToSleep() {
    _sleeping = true;
    _effectDispose?.call();
  }

  void _wakeUp() {
    if (_sleeping) {
      _sleeping = false;
      _status = FutureStatus.running;
      // needs to be in loading state instantly when waking up
      // so beacon.value.isLoading is true
      _setLoadingWithLastData();
    }

    _effectDispose = Beacon.effect(
      () async {
        final currentExeID = _startLoading();

        try {
          // asStream() isn't used because an exception can
          // be thrown before the async gap.
          final result = await _compute();
          return _setAsyncValue(currentExeID, AsyncData(result));
        } catch (e, s) {
          return _setAsyncValue(currentExeID, AsyncError(e, s));
        }
      },
      name: name,
    );
  }

  int _startLoading() {
    _setLoadingWithLastData();
    return ++_executionID;
  }

  void _setAsyncValue(int exeID, AsyncValue<T> newValue) {
    // If the execution ID is not the same as the current one,
    // then this is an old execution and we should ignore it
    if (exeID != _executionID) return;

    if (newValue.isError) {
      // If the value is an error, we want to keep the last data
      newValue.setLastData(lastData);
    }

    _setValue(newValue);
  }

  /// Starts executiong the future.
  void start() {
    // can only start once
    if (_status != FutureStatus.idle) return;
    _status = FutureStatus.running;
    _wakeUp();
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
    _compute = compute;
    reset();
  }

  @override
  AsyncValue<T> get value {
    if (_sleeping) {
      _wakeUp();
    }
    currentConsumer?.startWatching(this);
    return _value;
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
    _effectDispose?.call();
    _wakeUp();
  }

  @override
  void dispose() {
    _effectDispose?.call();
    _effectDispose = null;
    super.dispose();
  }
}
