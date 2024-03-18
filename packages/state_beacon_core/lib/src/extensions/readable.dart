// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

part of 'extensions.dart';

extension ReadableBeaconUtils<T> on ReadableBeacon<T> {
  /// Listens for the next value emitted by this Beacon and returns it as a Future.
  ///
  /// This method subscribes to this Beacon and waits for the next value
  /// that matches the optional [filter] function. If [filter] is provided and
  /// returns `false` for a emitted value, the method continues waiting for the
  /// next value that matches the filter. If no [filter] is provided,
  /// the method completes with the first value received.
  ///
  /// If this is a lazy beacon and it's disposed before a value is emitted,
  /// the future will be completed with an error if a [fallback] value is not provided.
  ///
  ///
  /// Example:
  ///
  /// ```dart
  /// final age = Beacon.writable(20);
  ///
  /// Timer(Duration(seconds: 1), () => age.value = 21;);
  ///
  /// final nextAge = await age.next(); // returns 21 after 1 second
  /// ```
  ///
  /// Parameters:
  ///   - [filter]: An optional function that determines whether a value is accepted.
  ///   - [fallback]: An optional value to complete the future if the beacon is lazy and disposed before a value is emitted.
  ///
  /// Returns a Future that completes with the next emitted value.
  Future<T> next({
    bool Function(T)? filter,
    T? fallback,
  }) async {
    final completer = Completer<T>();

    final unsub = subscribe(
      (v) {
        if (filter?.call(v) ?? true) {
          completer.complete(v);
        }
      },
      startNow: false,
    );

    // if the beacon is disposed before a new value is emitted,
    // complete the future with the current value.
    // Without this, the future would hang indefinitely
    final rmCallback = onDispose(() {
      if (completer.isCompleted) return;

      final newValue = isEmpty ? fallback : peek();

      if (newValue != null) {
        completer.complete(newValue);
      } else {
        completer.completeError(
          Exception(
            '$name was disposed before a value was emitted. '
            'Provide a fallback value to avoid this error.',
          ),
        );
      }
    });

    final result = await completer.future;

    unsub();
    rmCallback(); // allow the completer to be garbage collected

    return result;
  }
}

extension ReadableAsyncBeaconUtils<T> on ReadableBeacon<AsyncValue<T>> {
  /// Returns the last data that was successfully loaded
  /// This is useful when you want to display old data when
  /// in [AsyncError] or [AsyncLoading] state.
  /// equivalent to `beacon.peek().lastData`
  T? get lastData => peek().lastData;

  /// If this beacon's value is [AsyncData], returns it's value.
  /// Otherwise throws an exception.
  /// equivalent to `beacon.peek().unwrap()`
  T unwrapValue() => peek().unwrap();

  /// If this beacon's value is [AsyncData], returns it's value.
  /// Otherwise returns `null`.
  /// equivalent to `beacon.peek().unwrapOrNull()`
  T? unwrapValueOrNull() => peek().unwrapOrNull();

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
}
