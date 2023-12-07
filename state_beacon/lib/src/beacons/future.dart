part of '../base_beacon.dart';

class FutureBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  var _executionID = 0;

  FutureBeacon(
    this._operation, {
    bool manualStart = false,
    this.cancelRunning = true,
  }) : super(manualStart ? AsyncIdle() : AsyncLoading()) {
    if (!manualStart) _init();
  }

  final bool cancelRunning;
  final Future<T> Function() _operation;

  AsyncValue<T>? _previousAsyncValue;
  T? _lastData;

  @override
  AsyncValue<T>? get previousValue => _previousAsyncValue;

  /// The last data that was successfully loaded
  /// This is useful when the current state is [AsyncError] or [AsyncLoading]
  T? get lastData => _lastData;

  /// Resets the beacon by calling the [Future] again
  @override
  void reset() {
    _executionID++; // ignore any running futures
    _init();
  }

  /// Starts executing an idle [Future]
  ///
  /// NB: Must only be called once
  ///
  /// Use [reset] to restart the [Future]
  void start() {
    // can only start once
    if (peek() is! AsyncIdle) return;
    _init();
  }

  Future<void> _init() async {
    final currentTracker = ++_executionID;
    if (peek() is! AsyncLoading) {
      _setValue(AsyncLoading());
    }

    void updateOrIgnore(AsyncValue<T> value) {
      // if currentTacker != _tracker, another call to
      // init has been made so we should ignore this result
      if (cancelRunning && currentTracker != _executionID) {
        return;
      }

      if (value is AsyncData) {
        if (_lastData != null) {
          // first time we get data, we don't have a previous value

          // ignore: null_check_on_nullable_type_parameter
          _previousAsyncValue = AsyncData(_lastData!);
        }

        _lastData = value.unwrapValue();
      }

      _setValue(value);
    }

    try {
      final result = await _operation();
      return updateOrIgnore(AsyncData(result));
    } catch (e, s) {
      return updateOrIgnore(AsyncError(e, s));
    }
  }

  @override
  void dispose() {
    _lastData = null;
    _previousAsyncValue = null;
    super.dispose();
  }
}
