part of '../producer.dart';

/// A callback that returns a [Future].
typedef FutureCallback<T> = Future<T> Function();

/// Represents the status of a [FutureBeacon].
enum FutureStatus {
  /// The future has not yet started.
  idle,

  /// The future is currently running.
  running,

  /// The future has been restarted.
  restarted,
}

/// See `Beacon.future`
class FutureBeacon<T> extends AsyncBeacon<T> {
  /// See `Beacon.future`
  FutureBeacon(
    this._compute, {
    super.name,
    this.shouldSleep = true,
    bool manualStart = false,
  }) {
    if (manualStart) {
      _status.set(FutureStatus.idle);
      _setValue(AsyncIdle());
    } else {
      _status.set(FutureStatus.running);
      _setValue(AsyncLoading());
    }

    _isEmpty = false;
    _wakeUp();
  }

  late VoidCallback _effectDispose;
  var _executionID = 0;
  var _sleeping = false;

  /// Whether the future should sleep when there are no observers.
  final bool shouldSleep;
  FutureCallback<T> _compute;
  late final _status = Beacon.lazyWritable<FutureStatus>(
    name: "$name's status",
  );

  /// The status of the future.
  ReadableBeacon<FutureStatus> get status => _status;

  void _goToSleep() {
    _sleeping = true;
    _status.value = FutureStatus.idle;
    _effectDispose();
  }

  void _wakeUp() {
    if (_sleeping) {
      _sleeping = false;
      _status.value = FutureStatus.running;
      _setLoadingWithLastData();
    }

    _effectDispose = Beacon.effect(
      () async {
        // beacon is manually triggered if in idle state
        if (_status.value == FutureStatus.idle) {
          return;
        }

        final currentExeID = _startLoading();

        try {
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

  void _setAsyncValue(int exeID, AsyncValue<T> value) {
    // If the execution ID is not the same as the current one,
    // then this is an old execution and we should ignore it
    if (exeID != _executionID) return;

    if (value.isError) {
      // If the value is an error, we want to keep the last data
      value.setLastData(lastData);
    }

    _setValue(value);
  }

  /// Starts executiong the future.
  void start() {
    // can only start once
    if (_status.peek() != FutureStatus.idle) return;
    _status.value = FutureStatus.running;
    _value = AsyncLoading();
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
      // setting status to idle will short-curcuit the internal effect
      // print('sleeping $name after removing ${observer.name}');
      _goToSleep();
    }
  }

  /// Resets the beacon by executing the future again.
  void reset() {
    _setLoadingWithLastData();
    _status.value = _status.peek() == FutureStatus.running
        ? FutureStatus.restarted
        : FutureStatus.running;
  }

  @override
  void dispose() {
    _status.dispose();
    _effectDispose();
    super.dispose();
  }
}
