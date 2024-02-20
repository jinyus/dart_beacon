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

    // if the beacon is disposed before the value is emitted,
    // complete the future with the current value
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
