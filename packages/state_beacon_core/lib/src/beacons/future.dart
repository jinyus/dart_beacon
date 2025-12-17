part of '../producer.dart';

/// A callback that returns a [Future].
typedef FutureCallback<T> = Future<T> Function();

/// See `Beacon.future`
class FutureBeacon<T> extends AsyncBeacon<T> {
  /// See `Beacon.future`
  FutureBeacon(
    FutureCallback<T> compute, {
    required super.shouldSleep,
    super.manualStart,
    super.name,
  }) : super(() => compute().asStream());

  /// Replaces the current callback and resets the beacon
  void overrideWith(FutureCallback<T> compute) {
    _compute = () => compute().asStream();
    reset();
  }

  /// Resets the beacon by executing the future again.
  void reset() {
    _cancel();
    _wakeUp();
  }

  /// Updates the beacon with the result of the [compute].
  ///
  /// If the beacon is reset before [compute] finishes,
  /// the result of [compute] will be ignored.
  ///
  /// If multiple calls to updateWith is made, they will be
  /// queued and execute in FIFO order.
  ///
  /// If the beacon is set to idle with `.idle()` before [compute] finishes,
  /// the result of [compute] will be ignored.
  ///
  /// If [optimisticResult] is provided, it will be set immediately instead of
  /// setting the loading state. If an error occurs, the `.lastData` of the
  /// error will be set to the previous state before the optimistic update.
  Future<void> updateWith(
    FutureCallback<T> compute, {
    T? optimisticResult,
  }) async {
    final completer = Completer<void>();
    final previousQueue = _updateQueue;
    _updateQueue = completer.future;

    final loadCount = _loadCount;

    try {
      await previousQueue;
      if (loadCount == _loadCount) {
        await _performUpdate(compute, optimisticResult: optimisticResult);
      }
    } finally {
      completer.complete();
    }
  }

  Future<void> _performUpdate(
    FutureCallback<T> compute, {
    T? optimisticResult,
  }) async {
    final loadCount = _loadCount;
    late final T? previousState;
    if (optimisticResult != null) {
      previousState = lastData;
      _setValue(AsyncData(optimisticResult));
    } else {
      _setLoadingWithLastData();
    }
    try {
      final result = await compute();

      // this means that the beacon was reset/retriggered while we were waiting
      // so we ignore this result
      if (loadCount != _loadCount || _isDisposed) {
        return;
      }

      _setValue(AsyncData(result));
    } catch (error, stackTrace) {
      if (loadCount != _loadCount || _isDisposed) {
        return;
      }

      if (optimisticResult != null) {
        _setValue(AsyncError(error, stackTrace)..setLastData(previousState));
        return;
      } else {
        _setErrorWithLastData(error, stackTrace);
      }
    }
  }

  /// Sets the beacon to the [AsyncIdle] state.
  /// The `lastData` will be set to the current value.
  /// The beacon will have to be started manually to resume.
  void idle() {
    _loadCount++;
    _setValue(AsyncIdle()..setLastData(lastData));
    _cancel();
  }

  /// Exposes this as a [Future] that can be awaited in a future beacon.
  /// This will trigger a re-run of the derived beacon when its state changes.
  ///
  /// If `resetIfError` is `true` and the beacon is **currently** in an error
  /// state, the beacon will be reset before the future is returned.
  ///
  /// Example:
  /// ```dart
  /// var count = Beacon.writable(0);
  ///
  /// var count = Beacon.writable(0);
  /// var firstName = Beacon.future(() async => 'Sally ${count.value}');
  ///
  /// var lastName = Beacon.future(() async => 'Smith ${count.value}');
  ///
  /// var fullName = Beacon.future(() async {
  ///
  ///    // no need for a manual switch expression
  ///   final fnameFuture = firstName.toFuture();
  ///   final lnameFuture = lastName.toFuture();

  ///   final fname = await fnameFuture;
  ///   final lname = await lnameFuture;
  ///
  ///   return '$fname $lname';
  /// });
  Future<T> toFuture({bool resetIfError = true}) {
    if (_completer == null) {
      // first time
      final completer = Completer<T>();
      _completer = Beacon.writable(completer, name: "$name's future");

      if (peek() case final AsyncData<T> data) {
        completer.complete(data.value);
      } else if (!resetIfError && isError) {
        final error = peek() as AsyncError<T>;
        completer.completeError(error.error, error.stackTrace);
      }
    }

    if (resetIfError && isError) {
      reset();
    }

    return _completer!.value.future;
  }
}
