part of '../producer.dart';

/// A beacon that exposes an [AsyncValue].
abstract class AsyncBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  /// @macro [AsyncBeacon]
  AsyncBeacon({super.initialValue, super.name});

  /// Exposes this as a [Future] that can be awaited in a derived future beacon.
  /// This will trigger a re-run of the derived beacon when its state changes.
  ///
  /// var count = Beacon.writable(0);
  /// var firstName = Beacon.derivedFuture(() async => 'Sally ${count.value}');
  ///
  /// var lastName = Beacon.derivedFuture(() async => 'Smith ${count.value}');
  ///
  /// var fullName = Beacon.derivedFuture(() async {
  ///
  ///    // no need for a manual switch expression
  ///   final fnameFuture = firstName.toFuture();
  ///   final lnameFuture = lastName.toFuture();

  ///   final fname = await fnameFuture;
  ///   final lname = await lnameFuture;
  ///
  ///   return '$fname $lname';
  /// });
  Future<T> toFuture() {
    final awaitedBeacon = _Awaited.findOrCreate(this);

    return awaitedBeacon.future;
  }

  @override
  void dispose() {
    _Awaited.remove(this);
    super.dispose();
  }

  /// Alias for peek().lastData.
  /// Returns the last data that was successfully loaded
  /// equivalent to `beacon.peek().lastData`
  T? get lastData => peek().lastData;

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

  void _setLoadingWithLastData() {
    _setValue(AsyncLoading()..setLastData(lastData));
  }

  void _setErrorWithLastData(Object error, [StackTrace? stackTrace]) {
    _setValue(AsyncError(error, stackTrace)..setLastData(lastData));
  }
}
