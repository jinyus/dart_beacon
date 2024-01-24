part of 'extensions.dart';

// ignore: public_member_api_docs
extension BoolUtils on WritableBeacon<bool> {
  /// Toggles the value of this beacon.
  void toggle() {
    value = !peek();
  }
}

// ignore: public_member_api_docs
extension IntUtils<T extends num> on WritableBeacon<T> {
  /// Increments the value of this beacon.
  void increment() {
    value = value + 1 as T;
  }

  /// Decrements the value of this beacon.
  void decrement() {
    value = value - 1 as T;
  }
}

// ignore: public_member_api_docs
extension WritableBeaconUtils<T> on WritableBeacon<T> {
  /// Returns a [ReadableBeacon] that is not writable.
  ReadableBeacon<T> freeze() => this;
}

// ignore: public_member_api_docs
extension WritableAsyncBeacon<T> on WritableBeacon<AsyncValue<T>> {
  /// Executes the future provided and automatically sets
  /// the beacon to the appropriate state.
  ///
  /// ie. [AsyncLoading] while the future is running, [AsyncData] if
  /// the future completes successfully or [AsyncError] if
  /// the future throws an error.
  ///
  /// /// Example:
  /// ```dart
  /// Future<String> fetchUserData() {
  ///   // Imagine this is a network request that might throw an error
  ///   return Future.delayed(Duration(seconds: 1), () => 'User data');
  /// }
  ///
  /// await beacon.tryCatch(fetchUserData);
  ///```
  ///
  /// Without `tryCatch`, handling the potential error requires
  /// more boilerplate code:
  /// ```dart
  ///   beacon.value = AsyncLoading();
  ///   try {
  ///     beacon.value = AsyncData(await fetchUserData());
  ///   } catch (err,stacktrace) {
  ///     beacon.value = AsyncError(err, stacktrace);
  ///   }
  /// ```
  Future<void> tryCatch(Future<T> Function() future) async {
    await AsyncValue.tryCatch(future, beacon: this);
  }
}
