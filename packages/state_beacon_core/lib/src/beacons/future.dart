// ignore_for_file: inference_failure_on_function_invocation

part of '../base_beacon.dart';

// ignore: public_member_api_docs
typedef FutureCallback<T> = Future<T> Function();

/// A beacon that executes a [Future] and updates its value accordingly.
abstract class FutureBeacon<T> extends AsyncBeacon<T> {
  /// @macro [FutureBeacon]
  FutureBeacon(
    this._operation, {
    bool cancelRunning = true,
    super.initialValue,
    super.name,
  }) : _cancelRunning = cancelRunning;
  var _executionID = 0;

  final bool _cancelRunning;

  FutureCallback<T> _operation;

  /// Starts executing an idle [Future]
  /// Calling more than once has no effect
  ///
  /// Use [reset] to restart the [Future]
  void start();

  int _startLoading() {
    _setLoadingWithLastData();
    return ++_executionID;
  }

  void _setAsyncValue(int exeID, AsyncValue<T> value) {
    // If the execution ID is not the same as the current one,
    // then this is an old execution and we should ignore it
    // if cancelRunning is true
    if (_cancelRunning && exeID != _executionID) return;

    if (value.isError) {
      // If the value is an error, we want to keep the last data
      value.setLastData(lastData);
    }

    _setValue(value);
  }

  Future<void> _run() async {
    final currentExeID = _startLoading();

    try {
      final result = await _operation();
      return _setAsyncValue(currentExeID, AsyncData(result));
    } catch (e, s) {
      return _setAsyncValue(currentExeID, AsyncError(e, s));
    }
  }

  /// Replaces the current callback and resets the beacon
  void overrideWith(FutureCallback<T> compute) {
    _operation = compute;
    reset();
  }

  /// Resets the beacon by calling the [Future] again
  void reset();
}

/// A beacon that executes a [Future] and updates its value accordingly.
class DefaultFutureBeacon<T> extends FutureBeacon<T> {
  /// @macro [FutureBeacon]
  DefaultFutureBeacon(
    super.operation, {
    bool manualStart = false,
    super.cancelRunning = true,
    super.name,
  }) : super(initialValue: manualStart ? AsyncIdle() : AsyncLoading()) {
    if (!manualStart) _run();
  }

  /// Resets the beacon by calling the [Future] again
  @override
  void reset() {
    _executionID++; // ignore any running futures
    _run();
  }

  @override
  void start() {
    // can only start once
    if (peek() is! AsyncIdle) return;
    _run();
  }
}
