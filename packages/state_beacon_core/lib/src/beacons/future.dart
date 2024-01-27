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

  /// Alias for peek().lastData.
  /// Returns the last data that was successfully loaded
  /// equivalent to `beacon.peek().lastData`
  T? get lastData => peek().lastData;

  FutureCallback<T> _operation;

  /// Casts its value to [AsyncData] and return
  /// it's value or throws `CastError` if this is not [AsyncData].
  /// equivalent to `beacon.peek().unwrap()`
  T unwrapValue() => peek().unwrap();

  /// Returns `true` if this is [AsyncLoading].
  /// This is equivalent to `beacon.peek().isLoading`.
  bool get isLoading => peek().isLoading;

  /// Returns `true` if this is [AsyncIdle].
  /// This is equivalent to `beacon.peek().isIdle`.
  bool get isIdle => peek().isIdle;

  /// Returns `true` if this is [AsyncIdle] or [AsyncLoading].
  /// This is equivalent to `beacon.peek().isIdleOrLoading`.
  bool get isIdleOrLoading => peek().isIdleOrLoading;

  /// Returns `true` if this is [AsyncData].
  /// This is equivalent to `beacon.peek().isData`.
  bool get isData => peek().isData;

  /// Returns `true` if this is [AsyncError].
  /// This is equivalent to `beacon.peek().isError`.
  bool get isError => peek().isError;

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
