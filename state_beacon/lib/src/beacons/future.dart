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
    AsyncValue<T>? initialValue,
  })  : _cancelRunning = cancelRunning,
        super(initialValue);

  /// Casts its value to [AsyncData] and return it's value or throws [CastError] if this is not [AsyncData].
  T unwrapValue() => _value.unwrap();

  /// Returns `true` if this is [AsyncLoading] or [AsyncIdle].
  bool get isLoading => _value.isLoading;

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

  VoidCallback? _cancelAwaitedSubscription;

  /// Exposes this as a [Future] that can be awaited inside another [BaseFutureBeacon].
  /// var count = Beacon.writable(0);
  /// var firstName = Beacon.derivedFuture(() async => 'Sally ${count.value}');
  ///
  /// var lastName = Beacon.derivedFuture(() async => 'Smith ${count.value}');
  ///
  /// var fullName = Beacon.derivedFuture(() async {
  ///
  ///    // no need for a manual switch expression
  ///   final fname = await firstName.toFuture();
  ///   final lname = await lastName.toFuture();
  ///
  ///   return '$fname $lname';
  /// });
  @override
  Future<T> toFuture() {
    final existing = Awaited.find<T, FutureBeacon<T>>(this);
    if (existing != null) {
      return existing.future;
    }

    final newAwaited = Awaited<T, FutureBeacon<T>>(this);
    Awaited.put(this, newAwaited);

    _cancelAwaitedSubscription = newAwaited.cancel;

    return newAwaited.future;
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

  @override
  void dispose() {
    _cancelAwaitedSubscription?.call();
    Awaited.remove(this);
    super.dispose();
  }
}

class DefaultFutureBeacon<T> extends FutureBeacon<T> {
  DefaultFutureBeacon(
    super.operation, {
    bool manualStart = false,
    super.cancelRunning = true,
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
