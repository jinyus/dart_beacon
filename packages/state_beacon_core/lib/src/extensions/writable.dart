part of 'extensions.dart';

extension BoolUtils on WritableBeacon<bool> {
  void toggle() {
    value = !peek();
  }
}

extension IntUtils<T extends num> on WritableBeacon<T> {
  void increment() {
    value = value + 1 as T;
  }

  void decrement() {
    value = value - 1 as T;
  }
}

extension WritableBeaconUtils<T> on WritableBeacon<T> {
  ReadableBeacon<T> freeze() => this;
}

extension WritableAsyncBeacon<T> on WritableBeacon<AsyncValue<T>> {
  /// Executes the future provided and automatically sets the beacon to the appropriate state.
  ///
  /// ie. [AsyncLoading] while the future is running, [AsyncData] if the future completes successfully or [AsyncError] if the future throws an error.
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
  /// Without `tryCatch`, handling the potential error requires more boilerplate code:
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
