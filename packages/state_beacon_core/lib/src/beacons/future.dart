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
