part of '../base_beacon.dart';

abstract class AsyncBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
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
    final awaitedBeacon = Awaited.findOrCreate(this);

    return awaitedBeacon.future;
  }

  @override
  void dispose() {
    Awaited.remove(this);
    super.dispose();
  }
}
