// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

part of 'extensions.dart';

const _k10seconds = Duration(seconds: 10);

extension ReadableBeaconUtils<T> on ReadableBeacon<T> {
  /// Converts a [ReadableBeacon] to [Stream]
  /// The stream can only be canceled by calling [dispose]
  Stream<T> toStream({
    FutureOr<void> Function()? onCancel,
    bool broadcast = false,
  }) {
    final controller = StreamController<T>();

    if (!isEmpty) controller.add(peek());

    final unsub = subscribe(controller.add);

    void cancel() {
      unsub();
      controller.close();
      onCancel?.call();
    }

    onDispose(cancel);

    return broadcast
        ? controller.stream.asBroadcastStream()
        : controller.stream;
  }

  /// Listens for the next value emitted by this Beacon and returns it as a Future.
  ///
  /// This method subscribes to this Beacon and waits for the next value
  /// that matches the optional [filter] function. If [filter] is provided and
  /// returns `false` for a emitted value, the method continues waiting for the
  /// next value that matches the filter. If no [filter] is provided,
  /// the method completes with the first value received.
  ///
  /// If a value is not emitted within the specified [timeout] duration (default
  /// is 10 seconds), the method times out and returns the current value of the beacon.
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
  ///   - [timeout]: The maximum duration to wait for a value before timing out.
  ///
  /// Returns a Future that completes with the next emitted value.
  Future<T> next({
    bool Function(T)? filter,
    Duration timeout = _k10seconds,
  }) async {
    final completer = Completer<T>();

    final unsub = subscribe((v) {
      if (filter?.call(v) ?? true) {
        completer.complete(v);
      }
    });

    final result = await completer.future.timeout(
      timeout,
      onTimeout: peek,
    );

    unsub();

    return result;
  }
}
