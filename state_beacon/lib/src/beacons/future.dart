part of '../base_beacon.dart';

class FutureBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  var _executionID = 0;

  final bool cancelRunning;
  AsyncValue<T>? _previousAsyncValue;
  T? _lastData;

  /// The last data that was successfully loaded
  /// This is useful when the current state is [AsyncError] or [AsyncLoading]
  T? get lastData => _lastData;

  @override
  AsyncValue<T>? get previousValue => _previousAsyncValue;

  FutureBeacon({this.cancelRunning = true, AsyncValue<T>? initialValue})
      : super(initialValue);

  void start() {}

  /// Internal method to start loading
  @protected
  int $startLoading() {
    _setValue(AsyncLoading());
    return ++_executionID;
  }

  Future<T> get asFuture {
    //value; // register dependency
    if (_value case AsyncData<T>(:final value)) {
      return Future.value(value);
    } else if (_value case AsyncError<T>(:final error, :final stackTrace)) {
      return Future.error(error, stackTrace);
    }

    _futureCompleter = Completer<T>();
    return _futureCompleter!.future;
  }

  Completer<T>? _futureCompleter;

  /// Internal method to set the value
  @protected
  void $setAsyncValue(int exeID, AsyncValue<T> value) {
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
    _setValue(value, force: true);

    if (_futureCompleter != null) {
      switch (value) {
        case AsyncData<T>(value: final v):
          _futureCompleter?.complete(v);
          break;
        case AsyncError<T>(error: final e, stackTrace: final s):
          _futureCompleter?.completeError(e, s);
          break;
        default:
          break;
      }

      _futureCompleter = null;
    }
  }

  @override
  void dispose() {
    _lastData = null;
    _previousAsyncValue = null;
    super.dispose();
  }
}

class DefaultFutureBeacon<T> extends FutureBeacon<T> {
  DefaultFutureBeacon(
    this._operation, {
    bool manualStart = false,
    super.cancelRunning = true,
  }) : super(initialValue: manualStart ? AsyncIdle() : AsyncLoading()) {
    if (!manualStart) _init();
  }

  final Future<T> Function() _operation;

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
  @override
  void start() {
    // can only start once
    if (peek() is! AsyncIdle) return;
    _init();
  }

  Future<void> _init() async {
    final currentExeID = $startLoading();

    try {
      final result = await _operation();
      return $setAsyncValue(currentExeID, AsyncData(result));
    } catch (e, s) {
      return $setAsyncValue(currentExeID, AsyncError(e, s));
    }
  }
}
