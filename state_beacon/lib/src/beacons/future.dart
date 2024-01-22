// ignore_for_file: inference_failure_on_function_invocation

part of '../base_beacon.dart';

typedef FutureCallback<T> = Future<T> Function();

abstract class FutureBeacon<T> extends AsyncBeacon<T> {
  var _executionID = 0;

  final bool _cancelRunning;

  /// Alias for peek().lastData. Returns the last data that was successfully loaded
  T? get lastData => _value.lastData;

  FutureCallback<T> _operation;

  FutureBeacon(
    this._operation, {
    bool cancelRunning = true,
    super.initialValue,
    super.debugLabel,
  }) : _cancelRunning = cancelRunning;

  /// Casts its value to [AsyncData] and return it's value or throws [CastError] if this is not [AsyncData].
  T unwrapValue() => _value.unwrap();

  /// Returns `true` if this is [AsyncLoading].
  bool get isLoading => _value.isLoading;

  /// Returns `true` if this is [AsyncIdle].
  bool get isIdle => _value.isIdle;

  /// Returns `true` if this is [AsyncIdle] or [AsyncLoading].
  bool get isIdleOrLoading => _value.isIdleOrLoading;

  /// Returns `true` if this is [AsyncData].
  bool get isData => _value.isData;

  /// Returns `true` if this is [AsyncError].
  bool get isError => _value.isError;

  /// Starts executing an idle [Future]
  ///
  /// NB: Must only be called once
  ///
  /// Use [reset] to restart the [Future]
  void start();

  int _startLoading() {
    _setValue(
      AsyncLoading()..setLastData(lastData),
    );
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

    _setValue(value, force: true);
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

class DefaultFutureBeacon<T> extends FutureBeacon<T> {
  DefaultFutureBeacon(
    super.operation, {
    bool manualStart = false,
    super.cancelRunning = true,
    super.debugLabel,
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
